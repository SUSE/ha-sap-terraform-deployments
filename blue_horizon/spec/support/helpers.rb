# frozen_string_literal: true

require 'ruby_terraform'

module Helpers
  def populate_sources(auth_plan=false, include_mocks=true)
    sources_dir =
      if auth_plan
        'sources_auth'
      else
        'sources'
      end
    source_path = Rails.root.join('spec', 'fixtures', sources_dir)
    Dir.glob(source_path.join('**/*')).each do |filepath|
      next if !include_mocks && filepath.include?('mocks')

      relative_path = filepath.to_s.sub("#{source_path}/", '')
      Source.import(source_path, relative_path, validate: false)
    end
    Source.all
  end

  def current_plan_fixture
    # place the binary plan file
    source_path =
      Rails.root.join('spec', 'fixtures', 'current_plan')
    dest_path =
      Rails.configuration.x.source_export_dir.join('current_plan')
    FileUtils.cp source_path, dest_path

    current_plan_fixture_json
  end

  def current_plan_fixture_json
    plan = File.read(Rails.root.join('spec', 'fixtures', 'current_plan.json'))
    terraform_version = `terraform --version`.match(/v([0-9.]+)/)[1]
    plan.gsub('$VERSION', terraform_version)
  end

  def metadata_fixture(name)
    File.read(Rails.root.join('spec', 'fixtures', 'metadata', name))
  end

  def collect_variable_names
    source_path =
      Rails.root.join('spec', 'fixtures', 'sources', 'variable*.tf.json')
    Dir.glob(source_path).collect do |variables_source|
      JSON.parse(File.read(variables_source))['variable'].keys
    end.flatten
  end

  def random_export_path
    random_path = Rails.root.join('tmp', Faker::File.dir(segment_count: 1))
    Rails.configuration.x.source_export_dir = random_path
    FileUtils.mkdir_p(random_path)
    return random_path
  end

  def cleanup_random_export_path
    FileUtils.rm_rf(Rails.configuration.x.source_export_dir)
  end

  def working_path
    Rails.configuration.x.source_export_dir
  end

  def mock_metadata_location(location)
    allow_any_instance_of(Metadata).to receive(:location).and_return(location)
  end
end

RSpec.configure do |config|
  config.include Helpers

  config.before do
    random_export_path
  end

  config.after do
    cleanup_random_export_path
  end
end
