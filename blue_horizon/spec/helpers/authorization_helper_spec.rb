# frozen_string_literal: true

require 'rails_helper'

describe AuthorizationHelper do
  let(:variables) { Variable.load }
  let(:random_name) { Faker::Name.first_name }
  let(:random_string) { Faker::Lorem.word }
  let(:random_number) { Faker::Number.number(digits: 3) }
  let(:attributes_hash) do
    {
      'name'             => random_name,
      'test_description' => random_string,
      'empty_number'     => random_number.to_s,
      'are_you_sure'     => 'true',
      'test_list'        => ['one', 'two', 'three'],
      'test_map'         => { foo: 'bar' },
      'test_string'      => random_string,
      'test_options'     => 'option2'
    }
  end
  let(:terra) { Terraform }
  let(:instance_terra) { instance_double(Terraform) }

  before do
    allow(terra).to receive(:new).and_return(instance_terra)
    allow(instance_terra).to receive(:validate)

    populate_sources
  end

  it 'accepts a false boolean as a set variable' do
    variables.attributes = attributes_hash
    variables.are_you_sure = false
    variables.save
    expect(helper.send(:all_variables_are_set?)).to be_truthy
  end
end
