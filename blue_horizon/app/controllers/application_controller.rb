# frozen_string_literal: true

# Abstract class for centralizing ActionController customization
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authorize

  def authorize
    active_session = helpers.active_session?
    @active_session_ip = KeyValue.get(:active_session_ip) unless active_session
    return if helpers.check_and_alert(request.path)

    redirect_to(welcome_path)
  end
end
