# == Schema Information
#
# Table name: check_items
#
#  id                 :integer          not null, primary key
#  check_id           :integer
#  general_product_id :integer
#  product_name       :string(255)
#  unit               :string(255)
#  storage_quantity   :float(24)
#  quantity           :float(24)
#  profit_or_loss     :float(24)
#  check_item_type    :integer
#  note               :string(255)
#  deleted_at         :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

RSpec.describe CheckItem, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
