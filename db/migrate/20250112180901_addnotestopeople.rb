class Addnotestopeople < ActiveRecord::Migration[8.0]
  def change
    add_column :people, :notes_ao_room, :string, default: ""
    add_column :people, :celebration, :date
    add_column :people, :dinning_room, :integer
    add_column :people, :meal, :integer
    add_column :people, :notes_ao_meal, :string, default: ""
  end
end
