class Daydaytype < ActiveRecord::Migration[7.0]
  def change
    create_table :date_types do |p|
      p.integer :day_type_id
      p.date    :date
      p.integer :period_id
    end
    add_index :date_types, [:day_type_id, :date], unique: true
  end
end
