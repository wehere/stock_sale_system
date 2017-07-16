# == Schema Information
#
# Table name: stores
#
#  id         :integer          not null, primary key
#  company_id :integer
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Store < ActiveRecord::Base
  has_many :orders
  belongs_to :company
  has_many :users
  has_one :storage
  validates_presence_of :company, message: "没有指定门店属于哪个公司。"
  validates_presence_of :name, message: "门店名称不可以为空。"
  validates_uniqueness_of :name, scope: :company_id, message: "门店名称不能重复。"

  def self.create_store options
    store = self.new company_id: options[:company_id], name: options[:name]
    store.save!
    store.reload
    store
  end
end
