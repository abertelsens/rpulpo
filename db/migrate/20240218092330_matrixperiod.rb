class Matrixperiod < ActiveRecord::Migration[7.0]
  def change
    create_table :periods do |p|
      p.string :name
      p.date :s_date
      p.date :e_date
    end
    add_index :periods, [:s_date, :e_date], unique: true
  end
end
