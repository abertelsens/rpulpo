class Pulpomodules < ActiveRecord::Migration[7.0]
  def change
    create_table :pulpo_modules do |p|
      p.string :name, unique: true
      p.string :identifier, unique: true
      p.string :description, unique: true
    end
  end
end
