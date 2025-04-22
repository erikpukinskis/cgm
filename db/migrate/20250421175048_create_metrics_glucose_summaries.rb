class CreateMetricsGlucoseSummaries < ActiveRecord::Migration[8.0]
  def change
    create_enum :timescale, [ :week, :month ]

    create_table :metrics_glucose_summaries do |t|
      t.references :member, null: false, foreign_key: true
      t.datetime :preceding_timestamp, null: false
      t.integer :period, null: false
      t.integer :num_measurements, null: false
      t.float :average_glucose_level
      t.float :time_below_range
      t.float :time_above_range
      t.timestamps
    end
  end
end
