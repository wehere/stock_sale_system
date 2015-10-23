FactoryGirl.define do
  factory :price_change_history, :class => 'PriceChangeHistories' do
    price_id 1
from_price 1.5
to_price 1.5
change_time "2014-12-13 17:55:59"
user_id 1
  end

end
