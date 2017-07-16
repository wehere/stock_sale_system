# == Schema Information
#
# Table name: order_items
#
#  id          :integer          not null, primary key
#  order_id    :integer
#  product_id  :integer
#  price_id    :integer
#  plan_weight :string(255)
#  real_weight :float(24)
#  money       :float(24)
#  created_at  :datetime
#  updated_at  :datetime
#  delete_flag :boolean
#

FactoryGirl.define do
  factory :order_item do
    order_id 1
product_id 1
price_id 1
plan_weight "MyString"
real_weight 1.5
money 1.5
  end

end
