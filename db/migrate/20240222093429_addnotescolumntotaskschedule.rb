class Addnotescolumntotaskschedule < ActiveRecord::Migration[7.0]
  def change
    add_column :task_schedules, :notes, :string
    add_column :task_schedules, :number, :integer
  end
end
