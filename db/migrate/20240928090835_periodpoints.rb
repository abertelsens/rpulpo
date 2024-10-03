class Periodpoints < ActiveRecord::Migration[7.1]
  def change
    create_table "period_points" do |p|
      p.integer     :period_id
      p.integer     :person_id
      p.integer     :points
    end
  end
end
