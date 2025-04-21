class CreateMetricsGlucoseSummaries < ActiveRecord::Migration[8.0]
  def change
    create_table :metrics_glucose_summaries do |t|
      t.references :member, null: false, foreign_key: true
      t.datetime :preceding_timestamp, null: false
      t.integer :num_measurements, null: false
      t.float :average_glucose_level, null: false
      t.float :time_below_range, null: false
      t.float :time_above_range, null: false
      t.timestamps
    end
  end
end
