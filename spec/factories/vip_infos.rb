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

FactoryGirl.define do
  factory :vip_info, :class => 'VipInfo' do
    company_id 1
vip_type 1
valid_date "2015-03-07"
  end

end
