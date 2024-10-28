class Addfilesmodtime < ActiveRecord::Migration[7.1]
  def change
    add_column :mail_files, :mod_time,  :timestamp
    add_column :mail_files, :html,      :string
  end
end
