# frozen_string_literal: true

# User-configured attributes for cluster size & instance type
class Cluster
  include ActiveModel::Model
  include KeyPrefixable
  include Saveable
  extend KeyPrefixable

  attr_accessor :cloud_framework,
    :instance_count, :instance_type_custom
  attr_writer :instance_type

  def initialize(*args)
    super
    @instance_count = if @instance_count.to_i < min_cluster_size
      min_cluster_size
    else
      @instance_count.to_i
    end
  end

  def self.load
    new(
      cloud_framework:      Rails.configuration.x.cloud_framework,
      instance_count:       prefixed_get(:instance_count),
      instance_type:        prefixed_get(:instance_type),
      instance_type_custom: prefixed_get(:instance_type_custom)
    )
  end

  def self.variable_handlers
    [
      'instance_type',
      'instance_count'
    ]
  end

  def instance_type
    if @instance_type.blank? || @instance_type == 'CUSTOM'
      @instance_type_custom
    else
      @instance_type
    end
  end

  def min_cluster_size
    Rails.configuration.x.cluster_size.min
  end

  def max_cluster_size
    Rails.configuration.x.cluster_size.max
  end

  def current_cluster_size
    0 # TODO: will we support resizing?
  end

  def min_nodes_required
    [0, min_cluster_size - current_cluster_size].max
  end

  def max_nodes_allowed
    max_cluster_size - current_cluster_size
  end

  def to_s
    parts = ["a cluster of #{@instance_count} #{@instance_type} instances"]
    case @cloud_framework
    when 'aws'
      parts.push('in AWS')
    when 'azure'
      parts.push('in Azure')
    when 'gcp'
      parts.push('in GCP')
    end
    parts.compact.join(' ')
  end

  def save!
    prefixed_set(:instance_type, @instance_type)
    prefixed_set(:instance_type_custom, @instance_type)
    prefixed_set(:instance_count, @instance_count)
  end
end
