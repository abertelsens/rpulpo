class Addmailtousers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :mail, :boolean
  end
end
