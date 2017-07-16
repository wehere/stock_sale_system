class RenameTypeToCheckItemTypeOfCheckItems < ActiveRecord::Migration[5.0]
  def change
    rename_column :check_items, :type, :check_item_type
  end
end
