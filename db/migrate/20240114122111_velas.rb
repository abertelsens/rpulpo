class Velas < ActiveRecord::Migration[7.0]
  def change
    create_table :velas do |p|
      p.date      :date
      p.datetime  :start_time
      p.datetime  :end_time
      p.string    :order
    end
  end
end
