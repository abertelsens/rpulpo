class Renamepulpomodulestable < ActiveRecord::Migration[7.1]
  def change
    
    rename_table :pulpo_modules, :pulpomodules
    rename_column :module_users, :pulpo_module_id, :pulpomodule_id
    rename_column :documents, :pulpo_module_id, :pulpomodule_id
    
  end
end
