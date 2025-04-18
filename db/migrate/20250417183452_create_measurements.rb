class CreateMeasurements < ActiveRecord::Migration[8.0]
  def change
    create_table :measurements do |t|
      t.references :member, null: false, foreign_key: true
      t.integer :value, null: false
      t.datetime :tested_at, null: false

      t.timestamps
    end
  end
end
