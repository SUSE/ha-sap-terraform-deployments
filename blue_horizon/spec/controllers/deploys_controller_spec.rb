# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeploysController, type: :controller do
  render_views

  context 'when deploying terraform plan' do
    let(:ruby_terraform) { RubyTerraform }
    let(:terra_stderr) { ruby_terraform.configuration.stderr }
    let(:variable_instance) { Variable.new('') }

    let(:terraform_tfvars) { 'terraform.tfvars' }
    let(:terra) { Terraform }
    let(:instance_terra) { instance_doube(terra) }

    it 'deploys a plan successfully' do
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:read)
      allow(JSON).to receive(:parse).and_return(foo: 'bar')
      allow(ruby_terraform).to receive(:apply)

      get :update, format: :json

      expect(ruby_terraform).to(
        have_received(:apply)
          .with(
            directory:    working_path,
            auto_approve: true,
            no_color:     true
          )
      )
    end

    it 'raise exception' do
      allow(ruby_terraform).to(
        receive(:apply)
          .and_raise(RubyTerraform::Errors::ExecutionError)
      )

      get :update, format: :json
    end

    it 'writes error in the log' do
      allow(ruby_terraform.configuration).to(
        receive(:stderr)
          .and_return(StringIO.new('Something went wrong'))
      )

      get :send_current_status, format: :json

      filename = Rails.configuration.x.terraform_log_filename
      expect(File).to exist(filename)
      file_content = File.read(filename)
      expect(
        file_content.include?('Something went wrong')
      ).to be true
    end

    it 'can show deploy output' do
      allow(Terraform).to(
        receive(:stdout)
          .and_return(
            StringIO.new('hello world! Apply complete!')
          )
      )

      expected_html = "<code id='output'>hello world! " \
                      "Apply complete!</code>\n<i class=" \
                      "'eos-icon-loading md-48 centered hide'></i>\n"
      expected_json = { new_html: expected_html, success: true, error: nil }
      allow(controller).to receive(:render).with(json: expected_json)
      allow(ruby_terraform).to receive(:apply)

      get :send_current_status, format: :json

      expect(response).to be_success
    end

    it 'can show error output when deploy fails' do
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:read)
      allow(JSON).to receive(:parse).and_return(foo: 'bar')

      expected_html = "<code id='output'></code>\n<i class=" \
                      "'eos-icon-loading md-48 centered hide'></i>\n"
      expected_json = { new_html: expected_html, success: false,
                        error: "Error\n" }

      allow(controller).to receive(:render).with(json: expected_json)
      allow(Terraform).to receive(:stderr).and_return(StringIO.new("Error\n"))
      allow(Terraform).to receive(:stdout).and_return(StringIO.new)

      get :send_current_status, format: :json

      expect(response).to be_success
    end
  end

  context 'when destroying terraform resources' do
    let(:ruby_terraform) { RubyTerraform }

    it 'destroys the resources deployed' do
      allow(ruby_terraform).to receive(:destroy)
      allow(File).to receive(:exist?).and_return(true)
      allow(controller).to receive(:render)

      delete :destroy

      expect(response).to be_success
      expect(flash[:notice]).to(
        include('Terraform resources have been destroyed.')
      )
    end

    it 'shows error when destroying resources' do
      allow(ruby_terraform).to(
        receive(:destroy)
          .and_raise(RubyTerraform::Errors::ExecutionError)
      )
      allow(File).to receive(:exist?).and_return(true)
      allow(controller).to receive(:render)

      delete :destroy

      expect(response).to be_success
      expect(flash[:error]).to(
        include('Error: Terraform destroy has failed.')
      )
    end
  end
end
