# == Schema Information
#
# Table name: comments
#
#  id          :integer          not null, primary key
#  order_id    :integer
#  user_id     :integer
#  content     :text(65535)
#  delete_flag :boolean
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryGirl.define do
  factory :comment do
    order_id 1
user_id 1
content "MyText"
delete_flag false
  end

end
