class Velas < ActiveRecord::Migration[7.0]
  def change
    create_table :velas do |p|
      p.date      :date
      p.datetime  :start_time
      p.datetime  :start_time2
      p.datetime  :end_time
      p.string    :start1_message
      p.string    :start2_message
      p.string    :end_message
      p.string    :order
    end
  end
end
