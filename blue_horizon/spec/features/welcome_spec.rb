# frozen_string_literal: true

require 'rails_helper'

describe 'welcome', type: :feature do
  let(:cloud_framework) { 'azure' }
  let(:terra) { Terraform }
  let(:instance_terra) { instance_double(Terraform) }

  before do
    allow(terra).to receive(:new).and_return(instance_terra)
    allow(instance_terra).to receive(:validate)
    populate_sources
    Rails.configuration.x.cloud_framework = cloud_framework
  end

  it 'exists' do
    expect { visit('/welcome') }.not_to raise_error
  end

  it 'is redirected to from the root path' do
    visit('/')
    expect(page).to have_current_path(welcome_path)
  end

  describe 'on the simple path' do
    before do
      visit('/welcome')
      within('#content') do
        click_on('Start setup')
      end
    end

    it 'has a trigger link' do
      expect(Rails.configuration.x.advanced_mode).to be_falsey
    end

    it 'redirects to the next step' do
      expect(page).to have_current_path(cluster_path)
    end
  end

  describe 'on the advanced path' do
    before do
      visit('/welcome')
      within('#content') do
        click_on('Edit sources')
      end
    end

    it 'has a trigger link' do
      expect(Rails.configuration.x.advanced_mode).to be_truthy
    end

    it 'redirects to the next step' do
      expect(page).to have_current_path(sources_path)
    end
  end
end
