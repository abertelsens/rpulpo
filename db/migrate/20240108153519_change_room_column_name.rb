class ChangeRoomColumnName < ActiveRecord::Migration[7.0]
  def change
    change_table :rooms do |t|
      t.rename :name, :room
    end
  end
end
