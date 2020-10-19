# frozen_string_literal: true

require 'metadata'

# Automatically-configured attribute for location
class Region
  include ActiveModel::Model
  include KeyPrefixable
  include Saveable
  extend KeyPrefixable

  attr_accessor :cloud_framework, :region
  attr_reader :set_by_metadata

  def initialize(*args)
    super
    @metadata = Metadata.new(@cloud_framework)
    return unless (location = @metadata.location)

    @region ||= location
    @set_by_metadata = true
  end

  def self.load
    new(
      cloud_framework: Rails.configuration.x.cloud_framework,
      region:          prefixed_get(:region)
    )
  end

  def self.variable_handlers
    ['region']
  end

  def to_s
    @region
  end

  def save!
    prefixed_set(:region, @region)
  end
end
