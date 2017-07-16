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

require 'rails_helper'

RSpec.describe Comment, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
