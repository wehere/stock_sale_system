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

require 'rails_helper'

RSpec.describe VipAuthority, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
