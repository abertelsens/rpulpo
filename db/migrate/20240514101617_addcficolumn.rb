class Addcficolumn < ActiveRecord::Migration[7.1]
  def change
    add_column :crs, :cfi, :integer
  end
end
