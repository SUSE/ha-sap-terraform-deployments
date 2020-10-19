# frozen_string_literal: true

# View helpers for working with variables
module VariablesHelper
  def required
    content_tag(
      :span,
      '*',
      title: t(:required),
      data:  { toggle: 'tooltip' }
    )
  end

  def formatted_description(description)
    return nil unless description

    content_tag(
      :small,
      markdown(description, false),
      class: ['form-text', 'text-muted']
    )
  end

  def string_input_type(description)
    if description.to_s.downcase.match?('.*' + t('options_key') + '=\[(.*)\].*')
      'select'
    elsif description.to_s.downcase.include?(t('password_key'))
      'password'
    else
      'text'
    end
  end

  def get_select_options(description)
    # We cannot downcase the string as this would change the options string
    # The next operation converts the options_key in a lower/upper case regex
    key_regular_expression = t('options_key').split('').map do |char|
      format('[%<up>s|%<down>s]', up: char.upcase, down: char.downcase)
    end
    key_regular_expression = key_regular_expression.join('')
    options = description.to_s.match(
      '.*' + key_regular_expression + '=\[(.*)\].*'
    ).captures
    options[0].split(',').map { |option| option.tr('\'\"', '').strip }
  end
end
