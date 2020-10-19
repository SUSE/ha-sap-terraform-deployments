# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DownloadController, type: :controller do
  let(:ruby_terraform) { RubyTerraform }
  let!(:sources) { populate_sources }

  context 'when getting and sending files' do
    before do
      mock_member = double
      allow(mock_member).to receive(:read)
      allow(controller).to receive(:zip_files).and_return(mock_member)
      allow(controller).to receive(:send_data)
      Variable.load.export
      Source.all.each(&:export)
    end

    it 'send zip data' do
      get :download, format: :zip

      zip_name = controller.instance_variable_get(:@zip_name)
      expect(controller).to(
        have_received(:send_data)
          .with(nil, filename: zip_name)
      )
      index = zip_name.index('-') - 1
      zip_name = zip_name[0..index]
      expect(zip_name).to eq('terraform_scripts_and_log')
    end

    it 'gets source files' do
      expected_files = sources.pluck(:filename)
      prefix = working_path

      expected_files.map! do |expected_file|
        Pathname.new(prefix + expected_file)
      end
      expected_files.push Rails.configuration.x.terraform_log_filename
      expected_files = expected_files.collect(&:to_s)
      allow(File).to receive(:exist?).and_return(true)

      files = controller.files
      expected_files.each do |expected_file|
        expect(files).to be_include(expected_file)
      end
    end

    it 'gets files without extensions' do
      test_file = working_path.join('test_file')
      File.write(test_file, 'w') { |_f| '' }

      expect(controller.files).to be_include(test_file.to_s)
    end
  end

  context 'when creating zip files' do
    it 'zips files' do
      files = sources.map(&:filename)
      allow(Zip::OutputStream).to receive(:write_buffer).and_call_original

      compressed_filestream = controller.zip_files(files)

      expect(Zip::OutputStream).to have_received(:write_buffer)
      expect(compressed_filestream).to be_a(StringIO)
      expect(compressed_filestream.length).to be > 0
    end
  end
end
