class PublicController < ApplicationController
  layout 'public'
  before_action :authenticate_user!, except: [:index]

  def index
    redirect_to dashboard_path if user_signed_in?
  end

end
