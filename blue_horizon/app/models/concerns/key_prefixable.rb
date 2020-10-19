# frozen_string_literal: true

# common module for shared key prefixing
module KeyPrefixable
  PREFIX = 'tfvars.'

  def storage_key(key)
    PREFIX + key.to_s
  end

  def prefixed_get(key, default=nil)
    KeyValue.get(storage_key(key), default)
  end

  def prefixed_set(key, value)
    KeyValue.set(storage_key(key), value)
  end
end
