# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Region, type: :model do
  let!(:cloud_framework) { Rails.configuration.x.cloud_framework = 'azure' }
  let(:example) { described_class.load }
  let(:mock_location) { Faker::Internet.slug }
  let(:mock_stored_location) { Faker::Internet.slug }

  before do
    allow_any_instance_of(Metadata).to receive(:location)
      .and_return(mock_location)
  end

  context 'when loading' do
    it 'fetches metadata location as region' do
      expect(example.region).to eq(mock_location)
    end

    it 'returns stored values' do
      described_class.prefixed_set(:region, mock_stored_location)
      expect(example.region).to eq(mock_stored_location)
    end
  end

  it 'is represented as a string by region' do
    expect(example.to_s).to eq(mock_location)
  end

  context 'when saving, behave like ActiveRecord#save' do
    let(:handled_exceptions) do
      [
        ActiveRecord::ActiveRecordError.new("Didn't work!")
      ]
    end

    it 'returns true' do
      allow(example).to receive(:save!)
      expect(example.save).to be(true)
    end

    it 'returns false when there is an exception' do
      handled_exceptions.each do |exception|
        allow(example).to receive(:save!).and_raise(exception)
        expect(example.save).to be(false)
      end
    end

    it 'captures downstream messages to the errors collection' do
      handled_exceptions.each do |exception|
        allow(example).to receive(:save!).and_raise(exception)
        example.save
        expect(example.errors[:base]).to include(exception.message)
      end
    end
  end
end
