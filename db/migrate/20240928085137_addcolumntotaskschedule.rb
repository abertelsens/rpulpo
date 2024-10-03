class Addcolumntotaskschedule < ActiveRecord::Migration[7.1]
  def change
    add_column :task_schedules, :points, :integer
  end
end
