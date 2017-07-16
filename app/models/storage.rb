# == Schema Information
#
# Table name: storages
#
#  id         :integer          not null, primary key
#  store_id   :integer
#  name       :string(255)
#  describe   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Storage < ActiveRecord::Base
  belongs_to :store

  has_many :stocks

  has_many :month_inventories

  def self.create_storage options
    storage = new store_id: options[:store_id],
                  name: options[:name]
    storage.save!
    storage
  end
end
