class Addphasecolumntopeople < ActiveRecord::Migration[7.0]
  def change
    add_column :crs, :phase, :integer
    add_column :people, :student, :boolean
  end
end
