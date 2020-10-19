# frozen_string_literal: true

# General view helpers
module ApplicationHelper
  def sidebar_menu_items(advanced=Rails.configuration.x.advanced_mode)
    Rails.configuration.x.menu_items[advanced]
  end

  def sidebar_menu_item(path_key)
    text = t("sidebar.#{path_key}")
    icon = Rails.configuration.x.sidebar_icons[path_key]
    url = "/#{path_key}"

    content = [
      content_tag(:i, icon, class: ['eos-icons', 'md-18']),
      content_tag(:span, text, class: 'collapse')
    ].join(' ').html_safe

    classes = 'list-group-item'
    classes += ' disabled' unless can(url)

    active_link_to(content, url,
      class: classes,
      data:  { toggle: 'tooltip', placement: 'right', original_title: text }
    )
  end

  def bootstrap_flash
    flash.collect do |type, message|
      # Skip empty messages
      next if message.blank?

      context = case type.to_sym
      when :notice
        :success
      when :alert
        :warning
      when :error
        :danger
      else
        :secondary
      end
      render 'layouts/flash', context: context, message: message
    end.join.html_safe
  end

  def custom_image_exists?(filename)
    base_path = Rails.root.join('vendor', 'assets', 'images')
    File.exist?(File.join(base_path, "#{filename}.svg"))   ||
      File.exist?(File.join(base_path, "#{filename}.png")) ||
      File.exist?(File.join(base_path, "#{filename}.jpg"))
  end

  def tip_icon
    content_tag(
      :i,
      'lightbulb_outline',
      class: ['eos-icons', 'text-warning', 'align-middle'],
      title: 'Tip',
      data:  { toggle: 'tooltip' }
    )
  end

  def markdown(text, escape_html=true)
    return '' if text.blank?

    markdown_options = {
      autolink:            true,
      space_after_headers: true,
      no_intra_emphasis:   true,
      fenced_code_blocks:  true,
      strikethrough:       true,
      superscript:         true,
      underline:           true,
      highlight:           true,
      quote:               true
    }
    render_options = {
      filter_html: true,
      no_images:   true,
      no_styles:   true
    }
    render_options[:escape_html] = true if escape_html

    # Redcarpet doesn't remove HTML comments even with `filter_html: true`
    # https://github.com/vmg/redcarpet/issues/692
    uncommented_text = text.gsub(/<!--(.*?)-->/, '')

    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(render_options),
      markdown_options
    )
    markdown.render(uncommented_text).html_safe
  end
end
