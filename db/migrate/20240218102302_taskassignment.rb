class Taskassignment < ActiveRecord::Migration[7.0]
  def change
    create_table :task_assignments do |p|
      p.integer :person_id
      p.integer :task_id
      p.integer :date_type_id
    end
  end
end
