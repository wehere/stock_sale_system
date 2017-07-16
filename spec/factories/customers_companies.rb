# == Schema Information
#
# Table name: customers_companies
#
#  customer_id :integer
#  company_id  :integer
#  created_at  :datetime
#  updated_at  :datetime
#  delete_flag :boolean
#

FactoryGirl.define do
  factory :customers_company, :class => 'CustomersCompanies' do
    customer_id 1
company_id 1
  end

end
