class Task < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |p|
      p.string :name
    end
    add_index :tasks, :name, unique: true
  end
end
