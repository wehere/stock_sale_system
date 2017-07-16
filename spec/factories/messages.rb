# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  customer_id     :integer
#  supplier_id     :integer
#  content         :text(65535)
#  need_reach_date :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

FactoryGirl.define do
  factory :message do
    customer_id 1
supplier_id 1
content "MyText"
send_date "2015-01-02 16:11:23"
  end

end
