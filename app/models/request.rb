class Request < ApplicationRecord
  belongs_to :website, optional: false

  def as_json(options = {})
    super(options.merge(except: :id))
  end

end
