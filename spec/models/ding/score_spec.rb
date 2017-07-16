# == Schema Information
#
# Table name: ding_scores
#
#  id                :integer          not null, primary key
#  uploaded_at       :date
#  rank              :integer
#  health            :float(24)
#  performance       :float(24)
#  average_load_time :float(24)
#  business          :float(24)
#  quality           :float(24)
#  security          :float(24)
#  response_time     :float(24)
#  rpm               :float(24)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

RSpec.describe Ding::Score, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
