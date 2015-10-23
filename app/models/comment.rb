class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :order
  scope :valid, -> {where("delete_flag is null or delete_flag = 0 ")}
end
