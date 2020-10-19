# frozen_string_literal: true

require 'rails_helper'
require 'fileutils'

RSpec.describe Terraform, type: :service do
  let(:ruby_terraform) { RubyTerraform }
  let(:error_message) do
    'Either a JSON object or a JSON array is required,'\
    "representing stuff of\none or more \"variable\""\
    "blocks.\nError: Missing attribute seperator comma\n"\
    "on #{working_path}/foo.tf.json line 42, in foo.tf.json:\n"\
    "42:     }\nThis error is highly illogical."
  end

  it 'raise terraform exception when validating' do
    allow(RubyTerraform).to(
      receive(:validate)
        .and_raise(RubyTerraform::Errors::ExecutionError)
    )
    allow(RubyTerraform.configuration).to(
      receive(:stderr)
        .and_return(StringIO.new(error_message))
    )
    allow(File).to receive(:basename).and_return("#{working_path}/foo.tf.json")
    described_class.new.validate(true, true)

    filename = Rails.configuration.x.terraform_log_filename
    expect(File).to exist(filename)
    file_content = File.read(filename)
    expect(
      file_content.include?('Missing attribute')
    ).to be true
    expect(
      file_content.include?('highly illogical')
    ).to be true
  end

  it 'raise terraform exception when init because of wrong sources' do
    allow(RubyTerraform).to(
      receive(:init)
        .and_raise(RubyTerraform::Errors::ExecutionError)
    )
    allow(File).to receive(:basename).and_return("#{working_path}/foo.tf.json")
    described_class.new

    filename = Rails.configuration.x.terraform_log_filename
    expect(File).to exist(filename)
    file_content = File.read(filename)
    expect(
      file_content.include?('Error calling terraform init.')
    ).to be true
  end
end
