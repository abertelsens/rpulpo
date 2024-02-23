class DaySchedules < ActiveRecord::Migration[7.0]
  def change
    create_table "day_schedules" do |p|
      p.integer :schedule_id
      p.date    :date
      p.integer :period_id
    end
    add_index :day_schedules, [:schedule_id, :date], unique: true
  end
end
