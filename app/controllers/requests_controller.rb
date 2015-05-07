class RequestsController < ApplicationController
  protect_from_forgery except: :create
  before_action :authenticate_user!, :set_user_time_zone, except: [:create] 

  def create
    website = Website.find_by(api_key: params[:api_key])
    status = :unauthorized
    if website
      begin
        objects = ActiveSupport::JSON.decode(params[:requests])
        objects.each do |obj|
          obj['view_runtime'] ||= 0
          begin
            website.requests.create!(obj)
          rescue
            logger.warn('INVALID OBJECT: ' + obj.to_s)
            raise
          end
        end
        status = :ok
      rescue Exception => e
        status = :bad_request
        logger.warn e.inspect
      end
    end
    render nothing: true, status: status
  end

end
