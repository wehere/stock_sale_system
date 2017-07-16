# == Schema Information
#
# Table name: order_items
#
#  id          :integer          not null, primary key
#  order_id    :integer
#  product_id  :integer
#  price_id    :integer
#  plan_weight :string(255)
#  real_weight :float(24)
#  money       :float(24)
#  created_at  :datetime
#  updated_at  :datetime
#  delete_flag :boolean
#

require 'rails_helper'

RSpec.describe OrderItem, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
