class Renamecrs < ActiveRecord::Migration[7.1]
  def change
    rename_table :crs, :crs_records
    #rename_column :people, :pulpo_module_id, :pulpomodule_id
  end
end
