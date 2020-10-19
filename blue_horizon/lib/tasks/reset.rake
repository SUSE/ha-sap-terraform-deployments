# frozen_string_literal: true

desc 'Reset database and working directory'
task 'reset' => :environment do
  exports = Rails.configuration.x.source_export_dir.join('*')
  puts("cleaning up #{exports}")
  rm_r(Dir.glob(exports), secure: true)

  Rake::Task['db:reset'].invoke
end
