class AddColumnsToPeople < ActiveRecord::Migration[7.0]
  def change
    change_table :people do |p|
      p.integer :n_agd
      p.integer :status
    end
  end
end
