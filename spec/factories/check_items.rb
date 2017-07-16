# == Schema Information
#
# Table name: check_items
#
#  id                 :integer          not null, primary key
#  check_id           :integer
#  general_product_id :integer
#  product_name       :string(255)
#  unit               :string(255)
#  storage_quantity   :float(24)
#  quantity           :float(24)
#  profit_or_loss     :float(24)
#  check_item_type    :integer
#  note               :string(255)
#  deleted_at         :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

FactoryGirl.define do
  factory :check_item do
    check_id 1
    general_product_id 1
    product_name "MyString"
    unit "MyString"
    storage_quantity 1.5
    quantity 1.5
    profit_or_loss 1.5
    type 1
    note "MyString"
    deleted_at "2017-07-05 23:07:16"
  end
end
