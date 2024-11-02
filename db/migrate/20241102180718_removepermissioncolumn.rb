class Removepermissioncolumn < ActiveRecord::Migration[7.1]
  def change
    remove_column :module_users, :modulepermission
  end
end
