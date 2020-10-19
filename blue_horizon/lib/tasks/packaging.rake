# frozen_string_literal: true

require 'bundler'
require 'net/http'
require 'uri'
require 'fileutils'

namespace :gems do
  desc 'generate a list of rpm dependencies from the Gemfile.[ENV].lock files'
  task :rpmlist, [:ruby_version, :env] do |_task, args|
    ruby_version = args.ruby_version || RUBY_VERSION.split('.')[0, 2].join('.')
    filenames = if args.env
      ["Gemfile.#{args.env}.lock"]
    else
      Dir.glob('Gemfile.*.lock')
    end
    filenames.each do |filename|
      puts "#{filename}:"
      gemspecs(filename).each do |gemspec|
        puts "\truby#{ruby_version}-rubygem-#{gemspec}"
      end
    end
  end

  namespace :rpmspec do
    desc 'Generate specfile build requirements from Gemfile.[ENV].lock files'
    task :requires do |_task|
      puts 'BuildRequires:  ruby-macros >= 5'
      puts 'BuildRequires: %{rubygem bundler}'
      puts 'BuildRequires:  %{ruby}'
      gemspecs('Gemfile.production.lock').each do |gemspec|
        puts "BuildRequires:  %{rubygem #{gemspec}}"
      end
      puts 'Requires:  %{ruby}'
      puts 'Requires: %{rubygem bundler}'
      gemspecs('Gemfile.production.lock').each do |gemspec|
        puts "Requires:  %{rubygem #{gemspec}}"
      end
    end
  end
end

namespace :obs do
  desc 'Create a source tarball suitable for packaging in an OBS instance'
  task :tar do |_task|
    app = [
      'app',
      'bin',
      'config',
      'config.ru',
      'Gemfile.production',
      'lib',
      'public',
      'Rakefile'
    ]
    docs = ['LICENSE', 'README.md']
    db_setup = ['db/schema.rb', 'db/seeds.rb']
    rm_rf name_version
    mkdir_p "#{name_version}/db/"
    cp_r (app + docs), "#{name_version}/"
    cp db_setup, "#{name_version}/db/"
    # Use the production Gemfile
    mv "#{name_version}/Gemfile.production", "#{name_version}/Gemfile"
    system "tar cjvf packaging/#{tarball_filename} #{name_version}"
    rm_rf name_version
    system "ls -la packaging/#{tarball_filename}"
  end
end

def gemspecs(gemfile)
  ENV['BUNDLE_GEMFILE'] = gemfile
  lockfile = Bundler::LockfileParser.new(Bundler.read_file(gemfile))
  lockfile.specs.collect(&:name).sort
end

def name_version
  "blue-horizon-#{version}"
end

def version
  File.read('.bumpversion.cfg').match(/^current_version = (?<v>[0-9.]+)$/)[:v]
end

def tarball_filename
  "#{name_version}.tar.bz2"
end
