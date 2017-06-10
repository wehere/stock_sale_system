class Ding::Score < ApplicationRecord
  self.table_name = 'ding_scores'

  validates :uploaded_at, :rank, :health, :performance, :business, :quality, :security, :response_time, :rpm, presence: true

  validates :uploaded_at, uniqueness: true
end
