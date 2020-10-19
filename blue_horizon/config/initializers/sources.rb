# frozen_string_literal: true

Rails.application.configure do
  # file types supported as sources,
  # and the ace editor highlighter for each file type
  config.x.supported_source_extensions = {
    '.json' => 'json',
    '.sh'   => 'sh',
    '.tf'   => 'terraform',
    '.tmpl' => 'terraform',
    '.yaml' => 'yaml',
    '.yml'  => 'yaml'
  }
end
