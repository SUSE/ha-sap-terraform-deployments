# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rails db:seed command
# (or created alongside the database with db:setup).

Rails.logger = Logger.new(STDOUT)
Rails.logger.level = Logger::INFO

# Populate editable sources from the static documents
sources_path = ENV['TERRAFORM_SOURCES_PATH']
sources_path ||= Rails.root.join('vendor', 'sources')
Source.import_dir(sources_path, validate: false)
