class AppSession < ActiveRecord::Base
  belongs_to :app
  has_many :videos

  def record?
    true
  end

  def wifi_transmission_only?
    true
  end

  # TODO: should do this in view
  def to_json options={}
    {
      id: id,
      record: record?,
      wifi_transmission_only: wifi_transmission_only?
    }.to_json
  end
end
