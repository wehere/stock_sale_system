class AddAverageLoadTimeToScores < ActiveRecord::Migration[5.0]
  def change
    add_column :ding_scores, :average_load_time, :float, after: :performance
  end
end
