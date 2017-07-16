# == Schema Information
#
# Table name: vip_infos
#
#  id         :integer          not null, primary key
#  company_id :integer
#  vip_type   :integer
#  valid_date :date
#  created_at :datetime
#  updated_at :datetime
#

class VipInfo < ActiveRecord::Base
  belongs_to :company

  def expired?
    return false if valid_date >= Time.now.to_date
    true
  end
end
