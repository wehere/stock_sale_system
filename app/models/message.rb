# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  customer_id     :integer
#  supplier_id     :integer
#  content         :text(65535)
#  need_reach_date :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

class Message < ActiveRecord::Base

end
