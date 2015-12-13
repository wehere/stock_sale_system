class PurchaseOrder < ActiveRecord::Base
  scope :valid, "delete_flag is null or delete_flag = 0"
end