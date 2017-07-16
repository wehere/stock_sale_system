# == Schema Information
#
# Table name: order_types
#
#  id          :integer          not null, primary key
#  customer_id :integer
#  name        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  supplier_id :integer
#  delete_flag :boolean
#

require 'rails_helper'

RSpec.describe OrderType, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
