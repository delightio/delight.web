class AppSession < ActiveRecord::Base
  belongs_to :app
  has_one :video

  def record?
    true
  end

  def wifi_transmission_only?
    true
  end
end
