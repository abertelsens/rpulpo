class ModuleUsers < ActiveRecord::Migration[7.0]
  def change 
    create_table :module_users do |p|
      p.integer :pulpo_module_id
      p.integer :user_id
      p.integer :modulepermission
    end
  end
end
