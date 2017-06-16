class Ding::Score < ApplicationRecord
  self.table_name = 'ding_scores'

  validates :uploaded_at, presence: true
  #, :rank, :health, :performance, :average_load_time, :business, :quality, :security, :response_time, :rpm

  validates :uploaded_at, uniqueness: true
end
