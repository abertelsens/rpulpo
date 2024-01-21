class Addvelatopeople < ActiveRecord::Migration[7.0]
  def change
        add_column :people, :vela, :integer
  end
end
