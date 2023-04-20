class Peopleset < ActiveRecord::Migration[7.0]
  def change
    create_table :peoplesets do |p|
      p.integer   :status  # 0 PERSISTENT, 1 TEMPORAL
      p.string    :name   
    end
  end
end

