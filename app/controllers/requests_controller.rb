class RequestsController < ApplicationController
  protect_from_forgery except: :create
  before_action :authenticate_user!, :set_user_time_zone, except: [:create]

  def create
    website = Website.find_by(api_key: params[:api_key])
    status = :unauthorized
    if website
      begin
        bad_request = false
        objects = ActiveSupport::JSON.decode(params[:requests])
        objects.each do |obj|
          obj['view_runtime'] ||= 0
          obj['format'] ||= 'html'
          begin
            website.requests.create!(obj)
          rescue
            logger.warn('INVALID OBJECT: ' + obj.to_s)
            bad_request = true
          end
        end
        status = bad_request ? :bad_request : :ok
      rescue Exception => e
        status = :bad_request
        logger.warn e.inspect
      end
    end
    head status
  end

end
