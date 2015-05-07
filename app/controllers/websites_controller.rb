class WebsitesController < ApplicationController
  layout 'reports', except: [:index, :new, :create]
  before_action :set_website, only: [:edit, :update, :regenerate_api_key, :confirm_delete, :destroy]

  def new
    @website = Website.new
  end

  def create
    @website = @current_user.websites.create website_params
    unless @website.new_record?
      redirect_to overview_website_reports_path(@website), notice: 'New website created. Nice!'
    else
      render action: :new
    end
  end

  def update
    if @website.update website_params
      flash.now.notice = 'Website settings changed!'
    end
    render 'edit'
  end

  def regenerate_api_key
    @website.generate_new_api_key
    @website.save(validate: false)
    redirect_to edit_website_path(@website), notice: 'API key successfully regenerated!'
  end

  def destroy
    @website.destroy
    redirect_to dashboard_path, notice: '%s successfully deleted.' % @website.name
  end

private

  def website_params
    params.require(:website).permit(:name, :url)
  end

  def set_website
    @website = @current_user.websites.find(params[:id])
  end

end
