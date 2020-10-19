# frozen_string_literal: true

# Helpers specific to editing sources
module SourcesHelper
  # Return an ace highlighter mode, based on filename.
  # Default to "ace/mode/terraform".
  def ace_highlighter_for(filename)
    mode = Rails.configuration.x.supported_source_extensions[
      File.extname(filename)
    ]
    mode ||= 'terraform'
    return "ace/mode/#{mode}"
  end
end
