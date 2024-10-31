class Renamecrs < ActiveRecord::Migration[7.1]
  def change
    rename_table :crs, :crs_records
  end
end
