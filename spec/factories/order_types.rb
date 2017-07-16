# == Schema Information
#
# Table name: order_types
#
#  id          :integer          not null, primary key
#  customer_id :integer
#  name        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  supplier_id :integer
#  delete_flag :boolean
#

FactoryGirl.define do
  factory :order_type do
    company_id 1
name "MyString"
  end

end
