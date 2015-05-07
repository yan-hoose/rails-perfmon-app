class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!, :set_user_time_zone
  before_action :configure_permitted_parameters, if: :devise_controller?

protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) << :time_zone
  end

private

  def set_user_time_zone
    Time.zone = current_user.time_zone if current_user && current_user.time_zone.present?
  end

end
