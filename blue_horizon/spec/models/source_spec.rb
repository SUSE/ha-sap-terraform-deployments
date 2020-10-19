# frozen_string_literal: true

require 'rails_helper'
require 'fileutils'

RSpec.describe Source, type: :model do
  let(:terra) { Terraform }
  let(:instance_terra) { instance_double(Terraform) }

  before do
    allow(terra).to receive(:new).and_return(instance_terra)
    allow(instance_terra).to receive(:validate)
  end

  it 'has unique filenames' do
    static_filename = 'static'
    create(:source, filename: static_filename)
    expect do
      create(:source, filename: static_filename)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  context 'when importing' do
    let(:source_dir) { Faker::File.dir(root: '/') }
    let(:subdir) { Faker::File.dir(segment_count: 1) }
    let(:filename) { Faker::File.file_name(dir: nil) }
    let(:relative_path) { File.join(subdir, filename) }
    let(:short_path) { File.join(source_dir, filename) }
    let(:long_path) { File.join(source_dir, subdir, filename) }
    let(:content) { Faker::Lorem.paragraph }

    before do
      allow_any_instance_of(described_class)
        .to receive(:terraform_validation).and_return(true)
    end

    it 'stores the filename without any path if no additional path specified' do
      allow(File).to receive(:read).with(short_path).and_return(content)

      source = described_class.import(source_dir, filename)

      expect(source.filename).not_to include(source_dir)
      expect(source.content).to eq(content)
    end

    it 'stores relative path in filename' do
      allow(File).to receive(:read).with(long_path).and_return(content)

      source = described_class.import(source_dir, relative_path)

      expect(source.filename).not_to include(source_dir)
      expect(source.filename).to eq(relative_path)
      expect(source.content).to eq(content)
    end

    it 'imports only accepted files in a directory tree' do
      source_dir = Rails.root.join('spec', 'fixtures', 'sources_nested')
      accepted_files = [
        'main.tf',
        'modules/hello/hello.tf',
        'modules/hello/variables.tf',
        'variables.tf.json'
      ]
      rejected_files = [
        'excluded.md',
        'modules/hello/excluded.txt'
      ]
      described_class.import_dir(source_dir)
      accepted_files.each do |file|
        relative_path = file.sub("#{source_dir}/", '')
        expect(described_class.where(filename: relative_path).count).to eq(1)
      end
      rejected_files.each do |file|
        relative_path = file.sub("#{source_dir}/", '')
        expect(described_class.where(filename: relative_path).count).to eq(0)
      end
    end
  end

  context 'when exporting' do
    let(:source) { create(:source) }
    let(:expected_export_path) { File.join(working_path, source.filename) }

    it 'writes to a file' do
      source.export_into(working_path)
      expect(File).to exist(expected_export_path)
      file_content = File.read(expected_export_path)
      expect(file_content).to eq(source.content)
    end

    it 'writes to the config path unless otherwise specified' do
      source.export
      expect(File).to exist(expected_export_path)
    end
  end
end
