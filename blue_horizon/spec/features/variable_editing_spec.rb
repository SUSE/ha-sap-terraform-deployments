# frozen_string_literal: true

require 'rails_helper'

describe 'variable editing', type: :feature do
  let(:exclusions) do
    [
      *Cluster.variable_handlers,
      *Region.variable_handlers,
      'test_options'
    ]
  end
  let(:fake_data) { Faker::Crypto.sha256 }
  let(:terra) { Terraform }
  let(:instance_terra) { instance_double(Terraform) }
  let(:mock_location) { Faker::Internet.slug }

  before { mock_metadata_location(mock_location) }

  context 'with sources' do
    let(:variable_names) { collect_variable_names }
    let(:variables) { Variable.new(Source.variables.pluck(:content)) }

    before do
      allow(terra).to receive(:new).and_return(instance_terra)
      allow(instance_terra).to receive(:validate)
      populate_sources
      visit('/variables')
    end

    it 'has a form entry for each variable' do
      (variable_names - exclusions).each do |key|
        expect(page)
          .to have_selector("[name|='variables[#{key}]']")
          .or have_selector("##{key}_new_value")
      end
    end

    it 'stores form data for variables' do
      random_variable_key = nil
      until random_variable_key &&
            variables.type(random_variable_key) == 'string' &&
            (variables.description(random_variable_key).nil? ||
            !variables.description(random_variable_key).include?('options'))
        random_variable_key = (variable_names - exclusions).sample
      end
      fill_in("variables[#{random_variable_key}]", with: fake_data)
      click_on('Save')

      expect(KeyValue.get(variables.storage_key(random_variable_key)))
        .to eq(fake_data)
      expect(page).to have_content('Variables were successfully updated.')
    end

    it 'stores form data for variables in multi options input' do
      expect(page).to have_select 'variables[test_options]',
        with_options: ['option1', 'option2']
      ['option1', 'option2'].each do |option_value|
        select(option_value, from: 'variables[test_options]')
        click_on('Save')

        expect(KeyValue.get(variables.storage_key('test_options')))
          .to eq(option_value)
        expect(page).to have_content('Variables were successfully updated.')
      end
    end

    it 'does not display description comments' do
      expect(page).to have_content 'Some things'
      expect(page).not_to have_content 'are best left unsaid'
    end

    it 'fails to update and shows error' do
      random_variable_key = nil
      until random_variable_key &&
            variables.type(random_variable_key) == 'string' &&
            (variables.description(random_variable_key).nil? ||
            !variables.description(random_variable_key).include?('options'))
        random_variable_key = (variable_names - exclusions).sample
      end
      fill_in("variables[#{random_variable_key}]", with: fake_data)
      allow(Variable).to receive(:new).and_return(variables)
      allow(variables).to receive(:save).and_return(false)
      active_model_errors = ActiveModel::Errors.new(variables).tap do |e|
        e.add(:variable, 'is wrong')
      end
      allow(variables).to receive(:errors).and_return(active_model_errors)
      click_on('Save')

      expect(page).not_to have_content('Variables were successfully updated.')
      expect(page).to have_content('Variable is wrong')
    end
  end

  context 'with sources visit plan' do
    let(:variable_names) { collect_variable_names }
    let(:variables) { Variable.new(Source.variables.pluck(:content)) }
    let(:instance_var) { instance_double(Variable) }
    let(:instance_var_controller) { instance_double(VariablesController) }

    before do
      populate_sources(true)
      visit('/variables')
    end

    it 'stores form data for variables and redirects to plan' do
      allow(Variable).to receive(:load).and_return(variables)
      fill_in('variables[test_password]', with: fake_data)
      find('#next').click
      expect(KeyValue.get(variables.storage_key('test_password')))
        .to eq(fake_data)

      expect(page).not_to have_content('Variables were successfully updated.')
      expect(page).to have_current_path(plan_path)
    end
  end

  it 'notifies that no variables are defined' do
    allow(terra).to receive(:new).and_return(instance_terra)
    allow(instance_terra).to receive(:validate)

    visit('/variables')
    expect(page).to have_content('No variables are defined!')
  end

  it 'shows script error on page' do
    allow(Variable).to receive(:load).and_return(error: 'wrong')
    warning_message = 'Please, edit the scripts'
    visit('/variables')
    expect(page).not_to have_content('No variables are defined!')
    expect(page).to have_content('wrong').and have_content(warning_message)
    expect(page).to have_current_path(sources_path)
  end
end
