class Turno < ActiveRecord::Migration[7.1]
  def change
    create_table "turnos" do |p|
      p.integer     :vela_id
      p.timestamp   :start_time
      p.timestamp   :end_time
    end
  end
end
