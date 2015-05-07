class Request < ActiveRecord::Base
  belongs_to :website

  def as_json(options = {})
    super(options.merge(except: :id))
  end

end
