# == Schema Information
#
# Table name: checks
#
#  id                :integer          not null, primary key
#  supplier_id       :integer
#  storage_id        :integer
#  category          :string(255)
#  creator_id        :integer
#  check_items_count :integer
#  status            :integer
#  checked_at        :date
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

RSpec.describe Check, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
