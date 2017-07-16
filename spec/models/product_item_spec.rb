# == Schema Information
#
# Table name: product_items
#
#  id                 :integer          not null, primary key
#  supplier_id        :integer
#  other_order_id     :integer
#  product_id         :integer
#  general_product_id :integer
#  quantity           :float(24)
#  unit               :string(255)
#  price              :float(24)
#  amount             :float(24)
#  deleted_at         :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

RSpec.describe ProductItem, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
