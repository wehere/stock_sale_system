# == Schema Information
#
# Table name: other_orders
#
#  id          :integer          not null, primary key
#  supplier_id :integer
#  storage_id  :integer
#  io_at       :datetime
#  creator_id  :integer
#  category    :integer
#  deleted_at  :datetime
#  note        :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :other_order do
    storage_id 1
    io_at ""
    user_id 1
    supplier_id 1
    category 1
    deleted_at "2017-07-14 00:06:10"
    note "MyText"
  end
end
