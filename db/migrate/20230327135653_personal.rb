class Personal < ActiveRecord::Migration[7.0]
  def change
    create_table :personals do |p|
      p.integer :person_id, index: true
      p.string :photo_path
      p.string :region_of_origin
      p.string :region
      p.string :city
      p.string :languages
      p.string :father_name
      p.string :mother_name
      p.string :parents_address
      p.string :parents_work
      p.string :parents_info
      p.string :siblings_info
      p.string :economic_info
      p.string :medical_info
      p.string :notes
    end
  end
end
