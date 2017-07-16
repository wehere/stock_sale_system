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

class VipAuthority < ActiveRecord::Base
end
