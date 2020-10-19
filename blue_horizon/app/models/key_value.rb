# frozen_string_literal: true

# Key/Value store on ActiveRecord
class KeyValue < ApplicationRecord
  self.primary_key = 'key'
  serialize :value

  def self.set(key, value)
    kv =
      begin
        find(key.to_s)
      rescue ActiveRecord::RecordNotFound
        new(key: key)
      end
    kv.value = value
    kv.save
  end

  def self.get(key, default_value=nil)
    find(key.to_s).value
  rescue ActiveRecord::RecordNotFound
    default_value
  end
end
