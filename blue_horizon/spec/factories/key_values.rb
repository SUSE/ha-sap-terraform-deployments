# frozen_string_literal: true

FactoryBot.define do
  factory :key_value do
    key { Faker::Lorem.unique.word }

    factory :string_value do
      value { Faker::String.random }
    end
  end
end
