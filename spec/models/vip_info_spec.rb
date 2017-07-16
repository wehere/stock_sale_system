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

require 'rails_helper'

RSpec.describe VipInfo, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
