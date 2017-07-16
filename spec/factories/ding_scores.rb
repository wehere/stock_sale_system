# == Schema Information
#
# Table name: ding_scores
#
#  id                :integer          not null, primary key
#  uploaded_at       :date
#  rank              :integer
#  health            :float(24)
#  performance       :float(24)
#  average_load_time :float(24)
#  business          :float(24)
#  quality           :float(24)
#  security          :float(24)
#  response_time     :float(24)
#  rpm               :float(24)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

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
