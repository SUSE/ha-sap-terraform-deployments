# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cluster, type: :model do
  let(:custom_instance_type) { Faker::Lorem.word }
  let(:cluster_size_config) { Rails.configuration.x.cluster_size }
  let(:instance_count) do
    Faker::Number.within(
      range: cluster_size_config.min..cluster_size_config.max
    )
  end
  let(:cluster) do
    described_class.new(instance_type_custom: custom_instance_type)
  end

  it 'can implicitly represent a custom instance type' do
    expect(cluster.instance_type).to be(custom_instance_type)
  end

  it 'can explicity represent a custom instance type' do
    cluster = described_class.new(
      instance_type:        'CUSTOM',
      instance_type_custom: custom_instance_type
    )
    expect(cluster.instance_type).to be(custom_instance_type)
  end

  it 'has a configured minimum cluster size' do
    expect(cluster).to respond_to(:min_cluster_size)
    expect(cluster.min_cluster_size).to eq(cluster_size_config.min)
  end

  it 'has a configured maximum cluster size' do
    expect(cluster).to respond_to(:max_cluster_size)
    expect(cluster.max_cluster_size).to eq(cluster_size_config.max)
  end

  it 'calculates the minimum number of nodes required for a cluster' do
    expect(described_class.new.min_nodes_required)
      .to eq(described_class.new.min_cluster_size)
  end

  it 'calculates maximum cluster growth' do
    expect(described_class.new.max_nodes_allowed)
      .to eq(described_class.new.max_cluster_size)
  end

  context 'when loading' do
    before do
      described_class.prefixed_set(:instance_type, custom_instance_type)
      described_class.prefixed_set(:instance_count, instance_count)
    end

    it 'returns stored values' do
      cluster = described_class.load
      expect(cluster.instance_type).to eq(custom_instance_type)
      expect(cluster.instance_count).to eq(instance_count)
    end
  end

  context 'when represented as a string' do
    let(:cluster) do
      described_class.new(
        instance_type:  custom_instance_type,
        instance_count: instance_count
      )
    end

    it 'counts out the instances' do
      substring =
        "a cluster of #{instance_count} #{custom_instance_type} instances"
      expect(cluster.to_s).to match(substring)
    end
  end

  context 'when saving, behave like ActiveRecord#save' do
    let(:cluster) { described_class.new }
    let(:handled_exceptions) do
      [
        ActiveRecord::ActiveRecordError.new("Didn't work!")
      ]
    end

    it 'returns true' do
      allow(cluster).to receive(:save!)
      expect(cluster.save).to be(true)
    end

    it 'returns false when there is an exception' do
      handled_exceptions.each do |exception|
        allow(cluster).to receive(:save!).and_raise(exception)
        expect(cluster.save).to be(false)
      end
    end

    it 'captures downstream messages to the errors collection' do
      handled_exceptions.each do |exception|
        allow(cluster).to receive(:save!).and_raise(exception)
        cluster.save
        expect(cluster.errors[:base]).to include(exception.message)
      end
    end
  end

  context 'when framework is Amazon' do
    let(:framework) { 'aws' }
    let(:cluster) do
      described_class.new(
        cloud_framework: framework,
        instance_type:   custom_instance_type
      )
    end

    it 'stores instance type as prefixed :instance_type KeyValue' do
      expect(cluster.save).to be(true)
      expect(KeyValue.get(KeyPrefixable::PREFIX + 'instance_type'))
        .to eq(custom_instance_type)
    end

    it 'describes the framework in string representation' do
      substring = 'in AWS'
      expect(cluster.to_s).to match(substring)
    end
  end

  context 'when framework is Azure' do
    let(:framework) { 'azure' }
    let(:cluster) do
      described_class.new(
        cloud_framework: framework,
        instance_type:   custom_instance_type
      )
    end

    it 'describes the framework in string representation' do
      substring = 'in Azure'
      expect(cluster.to_s).to match(substring)
    end
  end

  context 'when framework is Google' do
    let(:framework) { 'gcp' }
    let(:cluster) do
      described_class.new(
        cloud_framework: framework,
        instance_type:   custom_instance_type
      )
    end

    it 'describes the framework in string representation' do
      substring = 'in GCP'
      expect(cluster.to_s).to match(substring)
    end
  end
end
