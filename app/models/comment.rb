# == Schema Information
#
# Table name: comments
#
#  id          :integer          not null, primary key
#  order_id    :integer
#  user_id     :integer
#  content     :text(65535)
#  delete_flag :boolean
#  created_at  :datetime
#  updated_at  :datetime
#

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :order
  scope :valid, -> {where("delete_flag is null or delete_flag = 0 ")}
end
