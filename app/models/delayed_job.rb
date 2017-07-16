# == Schema Information
#
# Table name: delayed_jobs
#
#  id         :integer          not null, primary key
#  priority   :integer          default(0), not null
#  attempts   :integer          default(0), not null
#  handler    :text(65535)      not null
#  last_error :text(65535)
#  run_at     :datetime
#  locked_at  :datetime
#  failed_at  :datetime
#  locked_by  :string(255)
#  queue      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class DelayedJob < ActiveRecord::Base
  
end
