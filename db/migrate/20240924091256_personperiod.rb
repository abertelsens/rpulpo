class Personperiod < ActiveRecord::Migration[7.1]
  def change
    create_table "person_periods" do |p|
      p.integer     :person_id
      p.date        :s_date
      p.date        :e_date
    end

    create_table "days_available" do |p|
      p.integer     :person_period_id
      p.integer     :day
      p.integer     :AM
      p.integer     :PM1
      p.integer     :PM2
    end

    create_table "tasks_available" do |p|
      p.integer     :matrix_id
      p.integer     :task_id
    end
  end
end
