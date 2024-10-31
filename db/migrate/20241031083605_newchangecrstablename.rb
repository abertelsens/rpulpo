class Newchangecrstablename < ActiveRecord::Migration[7.1]
  def change
    rename_table :crsrecords, :crs_records
  end
end
