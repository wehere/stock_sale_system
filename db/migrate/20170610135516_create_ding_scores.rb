class CreateDingScores < ActiveRecord::Migration[5.0]
  def change
    create_table :ding_scores do |t|
      t.date :uploaded_at
      t.integer :rank
      t.float :health
      t.float :performance
      t.float :business
      t.float :quality
      t.float :security
      t.float :response_time
      t.float :rpm

      t.timestamps
    end
  end
end
