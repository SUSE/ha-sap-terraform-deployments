# frozen_string_literal: true

Rails.application.configure do
  custom_locale_load_path = ENV['BLUE_HORIZON_LOCALIZERS']
  custom_locale_load_path ||= Rails.root.join('vendor', 'locales')
  config.i18n.load_path += Dir[File.join(custom_locale_load_path, '*.{rb,yml}')]
end
