class Studies < ActiveRecord::Migration[7.0]
  def change
    create_table :studies do |p|
      p.integer :person_id, index: true
      p.string :civil_studies
      p.string :studies_name
      p.string :degree
      p.string :profesional_experience
      p.string :year_of_studies
      p.string :faculty
      p.string :status
      p.string :licence
      p.string :doctorate
      p.string :thesis
    end
  end
end
