# == Schema Information
#
# Table name: vip_authorities
#
#  id                       :integer          not null, primary key
#  vip_type                 :integer
#  customer_count           :integer
#  print_able_per_day_count :integer
#  product_count            :integer
#  created_at               :datetime
#  updated_at               :datetime
#

FactoryGirl.define do
  factory :vip_authority do
    vip_type 1
customer_count 1
print_able_per_day_count 1
product_count 1
  end

end
