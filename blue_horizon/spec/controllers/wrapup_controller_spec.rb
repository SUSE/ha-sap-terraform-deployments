# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WrapupController, type: :controller do
  context 'when getting and sending files' do
    it 'show page' do
      get :index
    end
  end
end
