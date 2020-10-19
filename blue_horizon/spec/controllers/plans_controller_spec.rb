# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlansController, type: :controller do
  let(:json_instance) { JSON }
  let(:ruby_terraform) { RubyTerraform }
  let(:terra) { Terraform }
  let(:instance_terra) { instance_double(Terraform) }

  context 'when preparing terraform' do
    let(:variable_instance) { Variable.new('{}') }
    let(:variables) { Variable.load }
    let(:log_file) do
      Logger::LogDevice.new(Rails.configuration.x.terraform_log_filename)
    end

    before do
      allow(terra).to receive(:new).and_return(instance_terra)
    end

    it 'sets the configuration' do
      allow(instance_terra).to receive(:validate).and_return('')
      allow(instance_terra).to receive(:plan).and_return(error: 'error')
      allow(controller.instance_variable_set(:@exported_vars, 'foo'))
      allow(File).to receive(:exist?).and_return(true)

      put :update

      ruby_terraform.configure do |config|
        config.logger do |log_device|
          expect(log_device.targets).to eq([IO::STDOUT, log_file])
        end
      end
      expect(File).to exist(Rails.configuration.x.terraform_log_filename)
    end

    it 'exports variables' do
      allow(variable_instance).to receive(:load)
      allow(controller).to receive(:read_exported_sources)
      allow(json_instance).to receive(:parse)
      allow(instance_terra).to receive(:validate).with(true, true)

      put :update

      expect(json_instance).to have_received(:parse).at_least(:once)
    end
  end

  context 'when not exporting' do
    let(:ruby_terraform) { RubyTerraform }
    let(:terra) { Terraform }
    let(:instance_terra) { instance_double(Terraform) }

    before do
      allow(File).to receive(:exist?).and_return(false)
      allow(terra).to receive(:new).and_return(instance_terra)
      allow(instance_terra).to receive(:validate).with(true, true)
    end

    it 'no exported variables' do
      put :update

      expect(flash[:error]).to match(I18n.t('flash.export_failure'))
    end
  end

  context 'when showing the plan' do
    let(:file) { File }
    let(:file_write) { File }
    let(:plan_file) { Rails.root.join(random_path, 'current_plan') }
    let(:terra) { Terraform }
    let(:instance_terra) { instance_double(Terraform) }
    let(:tfvars_file) { Variable.load.export_path }

    before do
      allow(Logger::LogDevice).to receive(:new)
      allow(controller).to receive(:cleanup)
      allow(JSON).to receive(:pretty_generate)
      allow(JSON).to receive(:parse).and_return(blue: 'horizon')
    end

    it 'allows to download the plan' do
      allow(controller.helpers).to receive(:can).and_return(true)
      allow(instance_terra).to receive(:show)
      allow(ruby_terraform).to receive(:show)
      expected_content = 'attachment; filename="terraform_plan.json"'

      get :show, format: :json

      expect(response.header['Content-Disposition']).to eq(expected_content)
    end

    it 'handles rubyterraform exception' do
      allow(ruby_terraform).to(
        receive(:plan)
          .and_raise(
            RubyTerraform::Errors::ExecutionError,
            'Failed while running \'plan\'.'
          )
      )
      allow(ruby_terraform.configuration).to(
        receive(:stderr)
          .and_return(
            StringIO.new('foo')
          )
      )

      put :update, format: :js

      expect(flash[:error]).to(
        match(
          message: /Failed while running 'plan'./,
          output:  'foo'
        )
      )
    end
  end
end
