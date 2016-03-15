class Storage < ActiveRecord::Base
  belongs_to :store
  has_many :stocks

  def self.create_storage options
    storage = new store_id: options[:store_id],
                  name: options[:name]
    storage.save!
    storage
  end
end