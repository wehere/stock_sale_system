# == Schema Information
#
# Table name: stores
#
#  id         :integer          not null, primary key
#  company_id :integer
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :store do
    company_id 1
name "MyString"
  end

end
