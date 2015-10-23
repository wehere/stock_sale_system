class RemoveColumnParentIdFromCompanies < ActiveRecord::Migration
  def change
    remove_column :companies, :parent_id, :integer
  end
end