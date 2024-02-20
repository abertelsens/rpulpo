class Daytypes < ActiveRecord::Migration[7.0]
  def change
    create_table :day_types do |p|
      p.string :name
      p.string :description
    end
    add_index :day_types, :name, unique: true
  end
end
