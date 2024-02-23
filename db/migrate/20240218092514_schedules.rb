class Schedules < ActiveRecord::Migration[7.0]
  def change
    create_table "schedules" do |p|
      p.string :name
      p.string :description
    end
    add_index :schedules, :name, unique: true
  end
end
