class YearMonth < ActiveRecord::Base
  has_many :orders
  has_many :order_items, through: :orders
  scope :current_year_month, -> { where(val: self.chinese_month_format(Time.now.to_date)).first }
  scope :next_year_month, -> { where(val: self.chinese_month_format(Time.now.to_date.next_month)).first }
  scope :pre_year_month, -> { where(val: self.chinese_month_format(Time.now.to_date.last_month)).first }
  scope :specified_year_month, ->(true_date) { where(val: self.chinese_month_format(true_date)).first }

  def self.generate_recent_year_months
    1.upto(5).each do |t|
      year_month = t.month.ago.to_date.to_s(:db)[0..-4].gsub('-','年')+'月'
      next if self.exists?(val: year_month)
      self.create! val: year_month
    end
    0.upto(5).each do |t|
      year_month = (Time.now.to_date + t.month).to_s(:db)[0..-4].gsub('-','年')+'月'
      next if self.exists?(val: year_month)
      self.create! val: year_month
    end
  end

  def self.recent_months
    arr = []
    0.upto(5).each do |i|
      arr << Time.now.to_date - i.months
    end
    arr
  end

  def self.chinese_month_format date
    date.to_date.to_s(:db)[0..-4].gsub('-','年')+'月'
  end
end
