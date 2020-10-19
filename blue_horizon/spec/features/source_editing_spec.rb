# frozen_string_literal: true

require 'rails_helper'

describe 'source editing', type: :feature do
  let(:terra) { Terraform }
  let(:instance_terra) { instance_double(Terraform) }
  let(:instance_sources_controller) { instance_double(SourcesController) }
  let!(:sources) do
    allow(terra).to receive(:new).and_return(instance_terra)
    allow(instance_terra).to receive(:validate)
    populate_sources
  end

  it 'lists all sources' do
    visit('/sources')
    sources.each do |source|
      expect(page).to have_content(source.filename)
    end
  end

  it 'edits sources' do
    allow(FileUtils).to receive(:chmod)
    allow(File).to receive(:write)
    source = Source.find_by(filename: 'dummy.sh')
    random_content = "# #{Faker::Lorem.paragraph}"
    expect(source.content).not_to eq(random_content)
    visit('/sources')

    click_on(source.filename)
    fill_in_hidden('#source_content', random_content)
    click_on(id: 'submit-source')

    expect(page).to have_content('Source was successfully updated.')
    source.reload
    expect(source.content).to eq(random_content)
  end

  it 'edits sources with wrong syntax does not validate on save' do
    allow(FileUtils).to receive(:chmod)
    allow(File).to receive(:write)
    source = Source.find_by(filename: 'dummy.sh')
    random_content = "# #{Faker::Lorem.paragraph}"
    expect(source.content).not_to eq(random_content)

    visit('/sources')

    click_on(source.filename)
    fill_in_hidden('#source_content', random_content)
    click_on(id: 'submit-source')

    expect(page).to have_content('Source was successfully updated.')
  end

  it 'validates sources' do
    allow(File).to receive(:write)
    allow(FileUtils).to receive(:chmod)
    allow(Rails.configuration.x).to receive(:advanced_mode).and_return(true)

    allow(instance_terra).to(
      receive(:validate)
        .and_return(
          'Reference to undeclared input variable on' \
          'script \'dummy.sh\' in line 2: value = "Hello, '\
          '${var.names}."'
        )
    )

    visit('/sources')
    within('.float-right.btn-group.steps-container') do
      click_link('Plan')
    end

    expect(page).to(
      have_content(
        'Reference to undeclared input variable on' \
        'script \'dummy.sh\' in line 2: value = "Hello, '\
        '${var.names}."'
      )
    )
    visit('/sources')

    click_link('Check Sources')

    expect(page).to(
      have_content(
        'Reference to undeclared input variable on' \
        'script \'dummy.sh\' in line 2: value = "Hello, '\
        '${var.names}."'
      )
    )
    allow(instance_terra).to(
      receive(:validate)
        .and_return(nil)
    )

    click_link('Check Sources')

    expect(page).to have_content('All sources are valid.')
  end

  it 'creates new sources' do
    allow(FileUtils).to receive(:chmod)
    allow(File).to receive(:write)
    random_content = Faker::Lorem.paragraph
    filename = Faker::File.file_name(ext: 'sh')
    visit('/sources')

    click_on('New Source')
    fill_in('source[filename]', with: filename)
    click_on(id: 'submit-source')
    expect(page).to have_content('Source was successfully created.')
    fill_in_hidden('#source_content', random_content)
    click_on(id: 'submit-source')
    expect(page).to have_content('Source was successfully updated.')

    source = Source.last
    expect(source).to be_a(Source)
    expect(filename).to include(source.filename)
    expect(source.content).to eq(random_content)

    click_on('New Source')
    click_on(id: 'submit-source')
  end

  it 'does not create new sources' do
    filename = Faker::File.file_name(ext: 'foo')

    source_instance = Source.new(filename: filename)
    allow(Source).to receive(:new).and_return(source_instance)
    allow(source_instance).to receive(:save).and_return(false)

    visit('/sources')

    click_on('New Source')
    fill_in('source[filename]', with: filename)
    click_on(id: 'submit-source')
    expect(page).not_to have_content('Source was successfully created.')
  end

  it 'does not update new sources' do
    source = Source.find_by(filename: 'dummy.sh')
    random_content = "# #{Faker::Lorem.paragraph}"
    allow(Source).to receive(:find).and_return(source)
    allow(source).to receive(:update).and_return(false)

    expect(source.content).not_to eq(random_content)

    visit("/sources/#{source.id}/edit")
    fill_in_hidden('#source_content', random_content)
    click_on(id: 'submit-source')

    expect(page).not_to have_content('Source was successfully updated.')
    expect(source.content).not_to eq(random_content)
  end

  it 'deletes sources' do
    source = create(:source)
    visit('/sources')

    click_on(source.filename)
    click_on 'Delete'
    expect(page).to have_content('Source was successfully destroyed.')

    expect { Source.find(source.id) }
      .to raise_exception(ActiveRecord::RecordNotFound)
  end

  private

  # the textarea is "hidden behind" the JS editor
  def fill_in_hidden(findable, content)
    first(findable, visible: false).set(content)
  end
end
