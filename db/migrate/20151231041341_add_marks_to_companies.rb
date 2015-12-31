class AddMarksToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :marks, :string, default: '未分类', limit: 1000
  end
end
