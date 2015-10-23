class VipInfo < ActiveRecord::Base
  belongs_to :company

  def expired?
    return false if valid_date >= Time.now.to_date
    true
  end
end
