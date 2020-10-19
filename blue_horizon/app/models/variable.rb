# frozen_string_literal: true

require 'ruby_terraform'
# Terraform variable collection built dynamically from variables in a Source
# Supported types: string, number, boolean, list, map.
# Non-string lists, non-string maps, and objects are not supported at this time.
class Variable
  include ActiveModel::Model
  include Exportable
  include KeyPrefixable
  include Saveable

  DEFAULT_EXPORT_FILENAME = 'terraform.tfvars.json'
  UNGROUPED = 'ungrouped'

  def initialize(source_contents)
    source_contents = [source_contents].flatten
    @plan ||= {}
    source_contents.each do |source_content|
      variables = JSON.parse(source_content)['variable']
      @plan.merge!(variables) if variables
    end
    @plan.keys.each do |key|
      self.class.send(:attr_accessor, key)
      instance_variable_set(
        "@#{key}",
        prefixed_get(key, default(key))
      )
    end
  end

  def self.load
    terra = Terraform.new
    validation = terra.validate(true, true)
    return { error: validation } if validation

    new(Source.variables.pluck(:content))
  end

  def keys
    @plan.keys
  end

  def type(key)
    @plan[key]['type'] || 'string'
  end

  def default(key)
    @plan[key]['default'] || case type(key)
    when 'number'
      0
    when 'bool'
      false
    when 'list'
      []
    when 'map'
      {}
    else
      ''
    end
  end

  def description(key)
    @plan[key]['description']
  end

  def required?(key)
    !(/optional/i =~ @plan[key]['description'])
  end

  def group(key)
    /\[group:(?<group>.+)?\]/.match(@plan[key]['description'])[:group]
  rescue StandardError
    UNGROUPED
  end

  def by_groups
    result = {}
    attributes.each do |key, value|
      group = self.group(key)
      result[group] ||= {}
      result[group][key] = value
    end
    return result
  end

  def attributes
    Hash[
      @plan.keys.collect do |key|
        [key, instance_variable_get("@#{key}")]
      end
    ] || {}
  end

  def attributes=(hash)
    hash.to_hash.each do |key, value|
      key = key.to_s
      if @plan.keys.include?(key)
        instance_variable_set(
          "@#{key}",
          cast_value_for_key_type(key, value)
        )
      else
        Rails.logger.warn("'#{key}' is not a valid variable name")
      end
    end
  end

  def strong_params
    @plan.keys.collect do |key|
      case type(key)
      when 'list'
        { key => [] }
      when 'map'
        { key => {} }
      else
        key
      end
    end
  end

  def save!
    @plan.keys.each do |key|
      prefixed_set(key, instance_variable_get("@#{key}"))
    end
  end

  def content
    attributes.to_json
  end

  def filename
    DEFAULT_EXPORT_FILENAME
  end

  private

  def cast_value_for_key_type(key, value)
    case type(key)
    when 'number'
      BigDecimal(value)
    when 'bool'
      ActiveModel::Type::Boolean.new.cast(value)
    when 'list'
      value.collect(&:to_s)
    when 'map'
      Hash[value.collect { |k, v| [k.to_s, v.to_s] }]
    else
      value.to_s
    end
  end
end
