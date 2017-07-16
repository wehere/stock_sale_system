# == Schema Information
#
# Table name: orders
#
#  id               :integer          not null, primary key
#  customer_id      :integer
#  store_id         :integer
#  order_type_id    :integer
#  reach_order_date :date
#  send_order_date  :date
#  created_at       :datetime
#  updated_at       :datetime
#  user_id          :integer
#  delete_flag      :boolean
#  supplier_id      :integer
#  not_input_number :integer
#  return_flag      :boolean
#  is_confirm       :boolean
#

require 'rails_helper'

RSpec.describe Order, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
