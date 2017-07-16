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

class PriceChangeHistories < ActiveRecord::Base
  belongs_to :price
end
