class Storage < ActiveRecord::Base
  belongs_to :store
  has_many :stocks
end