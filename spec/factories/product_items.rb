# == Schema Information
#
# Table name: product_items
#
#  id                 :integer          not null, primary key
#  supplier_id        :integer
#  other_order_id     :integer
#  product_id         :integer
#  general_product_id :integer
#  quantity           :float(24)
#  unit               :string(255)
#  price              :float(24)
#  amount             :float(24)
#  deleted_at         :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

FactoryGirl.define do
  factory :product_item do
    supplier_id 1
    other_order_id 1
    product_id 1
    general_product_id 1
    quantity 1.5
    price 1.5
    amount 1.5
    unit "MyString"
    deleted_at "2017-07-14 00:12:11"
  end
end
