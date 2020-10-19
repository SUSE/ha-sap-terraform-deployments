# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Variable, type: :model do
  let(:source_contents) { Source.variables.pluck(:content) }
  let(:variables) { described_class.new(source_contents) }
  let(:variable_names) { collect_variable_names }
  let(:random_string) { Faker::Lorem.word }
  let(:random_number) { Faker::Number.number(digits: 3) }
  let(:attributes_hash) do
    {
      'test_description' => random_string,
      'empty_number'     => random_number.to_s,
      'are_you_sure'     => 'true',
      'test_list'        => ['one', 'two', 'three'],
      'test_map'         => { foo: 'bar' },
      'test_password'    => 'Superman123!',
      'test_options'     => 'option1',
      'fake_key'         => 'fake_value',
      'region'           => random_string
    }
  end
  let(:expected_keys) do
    [
      'name',
      'instance_count',
      'instance_type',
      'test_string',
      'are_you_sure',
      'test_list',
      'test_map',
      'empty_number',
      'test_description',
      'test_password',
      'test_options',
      'test_description_comment',
      'region'
    ]
  end
  let(:terra) { Terraform }
  let(:instance_terra) { instance_double(Terraform) }

  before do
    allow(terra).to receive(:new).and_return(instance_terra)
    allow(instance_terra).to receive(:validate)

    populate_sources
  end

  it 'builds attributes for each variable declaration' do
    variable_names.each do |key|
      expect(variables).to respond_to(key)
    end
  end

  it 'can be initialized with an empty variable set' do
    expect { described_class.new('{}') }.not_to raise_error
  end

  it 'uses defaults for attributes' do
    variable_names.each do |key|
      expect(variables.send(key)).to eq(variables.default(key))
    end
  end

  it 'has a list of variable keys' do
    expect(variables.keys).to be_an(Array)
    expect(variables.keys.sort).to eq(expected_keys.sort)
  end

  context 'when loading' do
    let(:fake_data) { Faker::Crypto.sha256 }
    let(:variables) { described_class.load }

    before do
      KeyValue.set('tfvars.test_string', fake_data)
    end

    it 'returns stored values' do
      expect(variables.test_string).to eq(fake_data)
    end
  end

  context 'when loading wrong formatted script' do
    let(:message) do
      { error: 'Incorrect JSON value type on script \'foo.tf.json\''\
               'in line 42: } This error is highly illogical.' }
    end

    it 'handles parsing errors from JSON' do
      allow(instance_terra).to(
        receive(:validate)
          .and_return(
            'Incorrect JSON value type on script \'foo.tf.json\''\
            'in line 42: } This error is highly illogical.'
          )
      )
      allow(Rails.logger).to receive(:error)
      allow(File).to receive(:open)
      allow(Logger::LogDevice).to receive(:new)
      expect(described_class.load).to eq(message)
    end
  end

  context 'with form handling' do
    let(:expected_params) do
      [
        'test_string',
        'are_you_sure',
        { 'test_list' => [] },
        { 'test_map' => {} },
        'empty_number',
        'test_description',
        'test_password',
        'test_options',
        'test_description_comment',
        'region',
        'name',
        'instance_count',
        'instance_type'
      ]
    end

    it 'presents an attributes hash' do
      expect(variables).to respond_to(:attributes)
      expect(variables.attributes.keys).to eq(variable_names)
      variable_names.each do |key|
        expect(variables.attributes[key]).to eq variables.default(key)
      end
    end

    it 'defines strong params from the variables' do
      # expect(variables.strong_params).to eq(expected_params)
      expect(variables.strong_params - expected_params).to be_empty
      expect(expected_params - variables.strong_params).to be_empty
    end

    it 'presents descriptions' do
      expect(variables.description('test_description')).to eq('test desc')
    end

    it 'assumes variables are required unless explicitly optional' do
      variables.attributes.keys.each do |key|
        if /optional/i =~ variables.description(key)
          expect(variables).not_to be_required(key)
        else
          expect(variables).to be_required(key)
        end
      end
    end

    context 'with form params' do
      before do
        allow(Rails.logger).to receive(:warn)
        variables.attributes = attributes_hash
      end

      it 'accepts values via attributes' do
        expect(variables.test_description).to eq(random_string)
      end

      it 'casts number from string' do
        expect(variables.empty_number).to be == random_number
      end

      it 'casts boolean from string' do
        expect(variables.are_you_sure).to be(true)
      end

      it 'accepts lists' do
        expect(variables.test_list.count).to eq(3)
      end

      it 'accepts hashes' do
        expect(variables.test_map.keys).to eq(['foo'])
      end

      it 'logs a warning for fake attributes' do
        expect(variables.instance_variable_names).not_to include('fake_key')
        expect(Rails.logger).to have_received(:warn) # for fake_key
      end
    end
  end

  context 'when saving, behave like ActiveRecord#save' do
    let(:random_string) { Faker::Lorem.word }
    let(:handled_exceptions) do
      [
        ActiveRecord::ActiveRecordError.new('Didn\'t work!')
      ]
    end

    it 'performs save!' do
      variables.test_string = random_string
      expect { variables.save! }.not_to raise_error
      expect(KeyValue.get('tfvars.test_string')).to eq(random_string)
    end

    it 'returns true' do
      allow(variables).to receive(:save!)
      expect(variables.save).to be(true)
    end

    it 'returns false when there is an exception' do
      handled_exceptions.each do |exception|
        allow(variables).to receive(:save!).and_raise(exception)
        expect(variables.save).to be(false)
      end
    end

    it 'captures downstream messages to the errors collection' do
      handled_exceptions.each do |exception|
        allow(variables).to receive(:save!).and_raise(exception)
        variables.save
        expect(variables.errors[:base]).to include(exception.message)
      end
    end
  end

  context 'when exporting' do
    let(:export_filename) { 'terraform.tfvars.json' }
    let(:random_path) do
      Rails.root.join('tmp', Faker::File.dir(segment_count: 1))
    end
    let(:expected_export) do
      File.join(working_path, export_filename)
    end
    let(:json) { JSON.dump(variables.attributes) }

    before do
      variables.attributes = attributes_hash
    end

    it 'writes to a file' do
      variables.export_into(working_path)
      expect(File).to exist(expected_export)
    end

    it 'writes variable values' do
      variables.export
      exported = File.read(expected_export)
      expect(exported).to eq(json)
    end

    it 'writes to the config path unless otherwise specified' do
      variables.export
      expect(File).to exist(expected_export)
    end
  end
end
