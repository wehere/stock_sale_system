# == Schema Information
#
# Table name: orders
#
#  id               :integer          not null, primary key
#  customer_id      :integer
#  store_id         :integer
#  order_type_id    :integer
#  reach_order_date :date
#  send_order_date  :date
#  created_at       :datetime
#  updated_at       :datetime
#  user_id          :integer
#  delete_flag      :boolean
#  supplier_id      :integer
#  not_input_number :integer
#  return_flag      :boolean
#  is_confirm       :boolean
#

FactoryGirl.define do
  factory :order do
    company_id 1
store_id 1
order_type_id 1
reach_order_date "2014-12-06"
send_order_date "2014-12-06"
  end

end
