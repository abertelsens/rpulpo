class Personset < ActiveRecord::Migration[7.0]
  def change
    create_table :personsets do |p|
      p.integer   :peopleset_id
      p.integer   :person_id
    end
    add_index :personsets, [:peopleset_id, :person_id], unique: true
  end
end
