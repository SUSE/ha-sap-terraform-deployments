# frozen_string_literal: true

require 'rails_helper'

describe 'cluster sizing', type: :feature do
  let(:terra) { Terraform }
  let(:instance_terra) { instance_double(Terraform) }
  let(:mock_location) { Faker::Internet.slug }

  before do
    allow(terra).to receive(:new).and_return(instance_terra)
    allow(instance_terra).to receive(:validate)
    populate_sources
  end

  describe 'in Azure' do
    let(:cloud_framework) { 'azure' }
    let(:instance_types) do
      Cloud::InstanceType.load(
        Rails.root.join('config', 'data', "#{cloud_framework}-types.json")
      )
    end
    let(:random_instance_type_key) { instance_types.sample.key }
    let(:cluster_size_config) { Rails.configuration.x.cluster_size }
    let(:random_cluster_size) do
      Faker::Number.within(
        range: cluster_size_config.min..cluster_size_config.max
      )
    end

    before do
      Rails.configuration.x.cloud_framework = cloud_framework
      Rails.configuration.x.allow_custom_instance_type = true
      Rails.configuration.x.show_instance_type_tip = true
      allow(Cloud::InstanceType)
        .to receive(:for)
        .with(cloud_framework)
        .and_return(instance_types)
      visit '/cluster'
    end

    it 'lists the instance types' do
      instance_types.each do |instance_type|
        expect(page).to have_content(instance_type.name)
      end
    end

    it 'stores cluster sizing' do
      mock_metadata_location(mock_location)

      choose(random_instance_type_key)
      fill_in('cluster_instance_count', with: random_cluster_size)
      click_on(id: 'submit-cluster')
      cluster = Cluster.load
      expect(cluster.instance_type).to eq(random_instance_type_key)
      expect(cluster.instance_count).to eq(random_cluster_size)
    end

    it 'does not stores cluster sizing and shows error' do
      choose(random_instance_type_key)
      fill_in('cluster_instance_count', with: random_cluster_size)
      cluster_instance = Cluster.new(
        cloud_framework: 'azure', instance_type: random_instance_type_key,
        instance_count: '173'
      )
      active_model_errors = ActiveModel::Errors.new(cluster_instance).tap do |e|
        e.add(:size, 'is wrong')
      end

      allow(Cluster).to receive(:new).and_return(cluster_instance)
      allow(cluster_instance).to receive(:save).and_return(false)
      allow(cluster_instance).to(
        receive(:errors)
          .and_return(active_model_errors)
      )
      click_on(id: 'submit-cluster')
      expect(page).to have_content('Size is wrong')
    end

    it 'consistently shows the cluster size' do
      KeyValue.set('tfvars.instance_count', random_cluster_size)
      visit '/cluster'
      expect(page).to have_selector(
        "input#count-display[value='#{random_cluster_size}']"
      )
      expect(page).to have_selector(
        "input#cluster_instance_count[value='#{random_cluster_size}']"
      )
    end
  end
end
