class Taskdaytype < ActiveRecord::Migration[7.0]
  def change
    create_table :task_types do |p|
      p.integer :day_type_id
      p.integer :task_id
      p.time   :s_time
      p.time   :e_time
    end
    add_index :task_types, [:day_type_id, :task_id], unique: true
  end
end
