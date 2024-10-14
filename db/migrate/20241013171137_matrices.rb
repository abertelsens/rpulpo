class Matrices < ActiveRecord::Migration[7.1]
  def change
    create_table "matrices" do |p|
      p.integer     :person_id
      p.boolean     :driver
      p.boolean     :choir
    end
  end
end
