# frozen_string_literal: true

# Abstract class for centralizing ActiveRecord customization
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
