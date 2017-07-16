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

class Ding::Score < ApplicationRecord
  self.table_name = 'ding_scores'

  validates :uploaded_at, presence: true
  #, :rank, :health, :performance, :average_load_time, :business, :quality, :security, :response_time, :rpm

  validates :uploaded_at, uniqueness: true
end
