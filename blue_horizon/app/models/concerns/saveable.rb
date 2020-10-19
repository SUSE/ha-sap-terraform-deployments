# frozen_string_literal: true

# common module for boolean 'save' method
module Saveable
  def save
    save!
    return true
  rescue ActiveRecord::ActiveRecordError => e
    errors[:base] << e.message
    return false
  end
end
