class Changeclotestoint < ActiveRecord::Migration[7.0]
  def change
    change_column :people, :clothes, 'integer USING CAST(clothes AS integer)'
  end
end
