# == Schema Information
#
# Table name: other_orders
#
#  id          :integer          not null, primary key
#  supplier_id :integer
#  storage_id  :integer
#  io_at       :datetime
#  creator_id  :integer
#  category    :integer
#  deleted_at  :datetime
#  note        :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe OtherOrder, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
