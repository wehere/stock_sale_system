# == Schema Information
#
# Table name: checks
#
#  id                :integer          not null, primary key
#  supplier_id       :integer
#  storage_id        :integer
#  category          :string(255)
#  creator_id        :integer
#  check_items_count :integer
#  status            :integer
#  checked_at        :date
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryGirl.define do
  factory :check do
    storage_id 1
    creator_id 1
    check_items_count 1
    status 1
  end
end
