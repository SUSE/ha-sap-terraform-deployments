# frozen_string_literal: true

require 'fileutils'

namespace :sources do
  desc 'Update sources in spec/fixtures/sources from vendor/sources'
  task 'spec-to-vendor' => :environment do
    FileUtils.rm(
      Dir.glob(Rails.root.join('vendor', 'sources', '*'))
    )
    FileUtils.cp(
      Dir.glob(Rails.root.join('spec', 'fixtures', 'sources', '*')),
      Rails.root.join('vendor', 'sources')
    )
  end

  desc 'Update sources in vendor/sources from spec/fixtures/sources'
  task 'vendor-to-spec' => :environment do
    FileUtils.rm(
      Dir.glob(Rails.root.join('spec', 'fixtures', 'sources', '*'))
    )
    FileUtils.cp(
      Dir.glob(Rails.root.join('vendor', 'sources', '*')),
      Rails.root.join('spec', 'fixtures', 'sources')
    )
  end
end
