# == Schema Information
#
# Table name: price_change_histories
#
#  id          :integer          not null, primary key
#  price_id    :integer
#  from_price  :float(24)
#  to_price    :float(24)
#  change_time :datetime
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe PriceChangeHistories, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
