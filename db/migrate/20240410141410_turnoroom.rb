class Turnoroom < ActiveRecord::Migration[7.1]
  def change
    create_table "turno_rooms" do |p|
      p.integer     :turno_id
      p.integer     :room_id
    end
  end
end
