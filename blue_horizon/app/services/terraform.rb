# frozen_string_literal: true

# Class to wrap all Terraform operations
class Terraform
  def initialize
    config_terraform
    init_terraform
  end

  def init_terraform
    in_export_dir do
      RubyTerraform.init(backend: false, no_color: true)
    rescue RubyTerraform::Errors::ExecutionError
      @logger.error('Error calling terraform init.')
    end
  end

  def config_terraform
    @logger = Logger.new(
      RubyTerraform::MultiIO.new(STDOUT, log_file),
      level: :debug
    )
    RubyTerraform.configure do |config|
      config.binary = find_default_binary
      config.logger = @logger
      config.stdout = @logger
      config.stderr = @logger
    end
  end

  def log_file
    Logger::LogDevice.new(Rails.configuration.x.terraform_log_filename)
  end

  def saved_plan_path
    Rails.configuration.x.source_export_dir.join('current_plan')
  end

  def find_default_binary
    `which terraform`.strip
  end

  def in_export_dir(path=Rails.configuration.x.source_export_dir)
    current_working_dir = Dir.pwd
    Dir.chdir(path)
    Rails.logger.debug "Changed dir to '#{path}'"
    yield
  ensure
    Rails.logger.debug "Returning to '#{current_working_dir}'"
    Dir.chdir(current_working_dir)
  end

  def validate(parse_output, file=false)
    validate_params = {
      directory: Rails.configuration.x.source_export_dir
    }
    if parse_output
      RubyTerraform.configuration.stderr = StringIO.new
      validate_params[:no_color] = true
    end
    in_export_dir do
      RubyTerraform.validate(validate_params)
    end
  rescue RubyTerraform::Errors::ExecutionError
    if parse_output
      error_output = RubyTerraform.configuration.stderr.string
      Rails.logger.error error_output
      Terraform.write_log_output(error_output)
      return parse_error_output(error_output, file)
    end
  ensure
    RubyTerraform.configuration.stderr = RubyTerraform.configuration.logger if
      parse_output
  end

  def self.write_log_output(content)
    f = File.open(Rails.configuration.x.terraform_log_filename, 'a')
    f.write(content)
    f.flush
  end

  def parse_error_output(message, file=false)
    start = message.index('Error: ')
    start += 'Error: '.length
    limit = message[start, message.length].index("\n")
    parsed_message = message[start, limit]
    line = message =~ /line [0-9]+/

    parsed_message += add_filename(message) if file
    parsed_message += " in #{message[line, 6]}:"
    suggestion = message.rindex(':') + 1
    parsed_message += message[suggestion, message.length]
    return parsed_message
  end

  def add_filename(error_message)
    source_files = Dir[Rails.configuration.x.source_export_dir.to_s + '/*']
    i = 0
    i += 1 until error_message.index(File.basename(source_files[i])) ||
                 i >= error_message.length
    return " on script '#{File.basename(source_files[i])}'" if
      i < error_message.length
  end

  def self.statefilename
    Rails.configuration.x.source_export_dir.join('terraform.tfstate')
  end

  def plan(args)
    KeyValue.set(:active_terraform_action, 'plan')
    set_output
    in_export_dir do
      RubyTerraform.plan(args)
    end
  rescue RubyTerraform::Errors::ExecutionError => e
    plan_stderr = RubyTerraform.configuration.stderr.string
    plan_stderr ||= ''
    return {
      error: {
        message: e.to_s, output: plan_stderr
      }
    }
  ensure
    KeyValue.set(:active_terraform_action, nil)
  end

  def apply(args)
    KeyValue.set(:active_terraform_action, 'apply')
    set_output
    in_export_dir do
      RubyTerraform.apply(args)
    end
  rescue RubyTerraform::Errors::ExecutionError
    nil
  ensure
    KeyValue.set(:active_terraform_action, nil)
  end

  def show(plan_path=saved_plan_path)
    set_output
    in_export_dir do
      RubyTerraform.show(path: plan_path, json: true)
    end
  end

  def destroy
    KeyValue.set(:active_terraform_action, 'destroy')
    destroy_args = {
      directory:    Rails.configuration.x.source_export_dir,
      auto_approve: true
    }
    in_export_dir do
      RubyTerraform.destroy(destroy_args)
    end
  rescue RubyTerraform::Errors::ExecutionError
    return 'Error: Terraform destroy has failed.'
  ensure
    KeyValue.set(:active_terraform_action, nil)
  end

  def set_output(stdout=StringIO.new, stderr=StringIO.new)
    RubyTerraform.configuration.stdout = stdout
    RubyTerraform.configuration.stderr = stderr
  end

  def self.stdout
    RubyTerraform.configuration.stdout
  end

  def self.stderr
    RubyTerraform.configuration.stderr
  end
end
