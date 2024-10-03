class Taskassignment < ActiveRecord::Migration[7.0]
  def change
    create_table :task_assignments do |p|
      p.integer :person_id
      p.integer :task_schedule_id
      p.integer :day_schedule_id
    end
  end
end
