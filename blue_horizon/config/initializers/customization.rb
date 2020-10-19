# frozen_string_literal: true

Rails.application.configure do
  # Customization

  # Start with a config file
  custom_config_path = ENV['BLUE_HORIZON_CUSTOMIZER']
  custom_config_path ||= Rails.root.join('vendor', 'customization.json')

  config.x = if File.exist? custom_config_path
    JSON.parse(IO.read(custom_config_path), object_class: OpenStruct)
  else
    OpenStruct.new
  end

  # Export path for modified source files (where terraform will run)
  config.x.source_export_dir ||= Rails.root.join('tmp', 'terraform')

  # Terraform log path
  config.x.terraform_log_filename ||= config.x.source_export_dir.join('ruby-terraform.log')

  # cluster sizing
  config.x.cluster_size ||= OpenStruct.new
  config.x.cluster_size.min ||= 3
  config.x.cluster_size.max ||= 250
  # custom instance type option can be removed:
  # set `"allow_custom_instance_type": false` in customization.json
  config.x.allow_custom_instance_type = true if config.x.allow_custom_instance_type.nil?
  # Instance type tip can be removed (for example, when using non-standard cluster sizing)
  # set `"show_instance_type_tip": false` in customization.json
  config.x.show_instance_type_tip = true if config.x.show_instance_type_tip.nil?

  # fallback to ENV var if not defined in custom config
  # _cloud_framework_ should be one of "AWS", "Azure", "GCP"
  config.x.cloud_framework ||= ENV['CLOUD_FRAMEWORK']
  config.x.cloud_framework = config.x.cloud_framework.downcase if config.x.cloud_framework.present?
end

# The following performs required actions based on custom configuration above

require 'fileutils'

FileUtils.mkdir_p(Rails.configuration.x.source_export_dir)
