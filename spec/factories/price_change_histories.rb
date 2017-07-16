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

FactoryGirl.define do
  factory :price_change_history, :class => 'PriceChangeHistories' do
    price_id 1
from_price 1.5
to_price 1.5
change_time "2014-12-13 17:55:59"
user_id 1
  end

end
