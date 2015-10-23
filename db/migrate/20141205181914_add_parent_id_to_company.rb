class AddParentIdToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :parent_id, :integer
  end
end
