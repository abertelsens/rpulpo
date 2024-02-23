class TaskSchedules < ActiveRecord::Migration[7.0]
  def change
    create_table "task_schedules" do |p|
      p.integer :schedule_id
      p.integer :task_id
      p.time   :s_time
      p.time   :e_time
    end
    add_index :task_schedules, [:schedule_id, :task_id], unique: true
  end
end
