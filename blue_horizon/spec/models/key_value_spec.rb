# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KeyValue, type: :model do
  it 'has unique keys' do
    static_key = 'static'
    create(:key_value, key: static_key)
    expect do
      create(:key_value, key: static_key)
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it 'is accessible by key' do
    key = create(:key_value).key
    described_class.find(key)
  end

  context 'with different types of values' do
    shared_examples 'type-specifc storage' do |value|
      let(:key) { create(:key_value, value: value).key }

      it 'returns the same value' do
        expect(described_class.find(key).value).to eq value
      end

      it 'returns the same class of value' do
        expect(described_class.find(key).value).to be_a value.class
      end
    end

    it_behaves_like 'type-specifc storage', Faker::String.random
    it_behaves_like 'type-specifc storage', Faker::Number.decimal
    it_behaves_like 'type-specifc storage', Faker::Time.forward(days: 1)
    it_behaves_like 'type-specifc storage', Faker::Boolean.boolean
  end

  context 'with convenience functions' do
    let(:kv) { create(:string_value) }
    let(:new_value) { Faker::Number.decimal }
    let(:new_key) { Faker::Lorem.unique.word }

    it 'gets values' do
      expect(described_class.get(kv.key)).to eq kv.value
    end

    it 'returns a default value if not set' do
      expect(described_class.get(new_key, new_value)).to eq new_value
    end

    it 'sets values on existing keys' do
      described_class.set(kv.key, new_value)
      expect(described_class.get(kv.key)).to eq new_value
    end

    it 'sets values on new keys' do
      described_class.set(new_key, new_value)
      expect(described_class.get(new_key)).to eq new_value
    end
  end
end
