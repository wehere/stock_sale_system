FactoryGirl.define do
  factory :ding_score, class: 'Ding::Score' do
    uploaded_at "2017-06-10"
    rank 1
    health 1.5
    performance 1.5
    business 1.5
    quality 1.5
    security 1.5
    response_time 1.5
    rpm 1.5
  end
end
