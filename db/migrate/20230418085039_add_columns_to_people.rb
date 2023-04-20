class AddColumnsToPeople < ActiveRecord::Migration[7.0]
  def change
    remove_column :people, :lives
    change_table :people do |p|
      p.string :n_agd
      p.string :status
      p.string :clothes 
      p.string :year
      p.string :lives
    end
  end
end
