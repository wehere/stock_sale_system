class AddDeleteFlagToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :delete_flag, :boolean
  end
end
