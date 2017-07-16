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

require 'rails_helper'

RSpec.describe Store, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
