class CustomersCompanies < ActiveRecord::Base
  belongs_to :purchaser, class_name: 'Company', foreign_key: 'customer_id'
  belongs_to :supplier, class_name: 'Company', foreign_key: 'company_id'
  validates :customer_id, presence: true
  validates :company_id, presence: true
end
