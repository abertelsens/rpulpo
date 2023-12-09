class Rooms < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms do |r|
      r.integer   :house
      r.string    :name
      r.integer   :person_id
      r.integer   :bed
      r.string    :floor
      r.string    :matress
      r.integer   :bathroom
      r.integer   :phone
    end
  end
end
