# frozen_string_literal: true

require 'rails_helper'

describe 'authorization', type: :feature do
  let(:cloud_framework) { 'azure' }
  let(:auth_message) { I18n.t('flash.unauthorized') }
  let(:terra) { Terraform }
  let(:instance_terra) { instance_double(Terraform) }
  let(:session_lock_message) { I18n.t('non_active_session') }

  before do
    allow(terra).to receive(:new).and_return(instance_terra)
    allow(instance_terra).to receive(:validate)
    populate_sources
    Rails.configuration.x.cloud_framework = cloud_framework
  end

  it 'always allows access to the welcome page' do
    visit '/welcome'
    expect(page).not_to have_content(auth_message)
  end

  it 'initially blocks access to deploy' do
    allow(File).to receive(:exist?).and_return(false)

    visit '/deploy'

    expect(page).to have_current_path(welcome_path)
    expect(page).to have_content(auth_message)
  end

  it 'initially blocks access to download' do
    allow(File).to receive(:exist?).and_return(false)

    visit '/download'

    expect(page).to have_current_path(welcome_path)
    expect(page).to have_content(auth_message)
  end

  describe 'after planning' do
    before do
      artifact = working_path.join('current_plan')
      File.open(artifact, 'w') {}
    end

    it 'allows access to deploy' do
      visit '/deploy'
      expect(page).to have_current_path(deploy_path)
      expect(page).not_to have_content(auth_message)
    end

    it 'raises StandardError while checking access to deploy' do
      allow(working_path).to(
        receive(:join)
          .and_raise(StandardError)
      )
      visit '/deploy'
      expect(page).to have_current_path(welcome_path)
      expect(page).to have_content(auth_message)
    end

    describe 'after deploy' do
      before do
        File.open(Terraform.statefilename, 'w') {}
      end

      it 'allows access to download' do
        visit '/download'
        expect(page).to have_current_path(download_path)
      end
    end
  end

  describe 'with an active session' do
    let(:active_session_id) { Faker::Crypto.md5 }
    let(:active_session_ip) { Faker::Internet.ip_v4_address }
    let(:reset_session) { I18n.t('action.reset_session') }

    before do
      create(:key_value, key: 'active_session_id', value: active_session_id)
      create(:key_value, key: 'active_session_ip', value: active_session_ip)
    end

    it 'only allows access to welcome page' do
      Rails.configuration.x.simple_sidebar_menu_items.each do |path|
        visit("/#{path}")
        expect(page).to have_current_path(welcome_path)
        expect(page).to have_content(session_lock_message)
      end
    end

    it 'warns of additional session' do
      visit(welcome_path)
      expect(page).to have_content(session_lock_message)
    end

    it 'allows session lock to be reset' do
      visit(welcome_path)
      within('#locked-session') do
        click_on(reset_session)
      end
      expect(page).to have_current_path(welcome_path)
      expect(page).not_to have_content(session_lock_message)
    end
  end

  describe 'when terraform is running' do
    let(:terraform_lock_message) { I18n.t('flash.terraform_is_running') }

    before do
      KeyValue.set(:active_terraform_action, Faker::Verb.base)
    end

    after do
      KeyValue.set(:active_terraform_action, nil)
    end

    it 'only allows access to welcome page' do
      paths = Rails.configuration.x.simple_sidebar_menu_items.collect do |path|
        visit("/#{path}")
      end
      paths.each do |path|
        expect(page).to have_current_path(welcome_path)
        if path != welcome_path
          expect(page).to have_content(terraform_lock_message)
        end
      end
    end
  end
end
