class Situations < ActiveRecord::Migration[7.1]
  def change
    create_table "situations" do |p|
      p.string      :name
      p.integer     :points
    end

    create_table "time_situations" do |p|
      p.integer     :situation_id
      p.integer     :time
    end
  end
end
