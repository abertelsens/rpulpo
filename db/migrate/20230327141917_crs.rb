class Crs < ActiveRecord::Migration[7.0]
  def change
    create_table :crs do |p|
      p.integer :person_id
      p.string :classnumber
      p.date :pa
      p.date :admision
      p.date :oblacion
      p.date :fidelidad
      p.date :letter
      p.date :admissio
      p.date :presbiterado	
      p.date :diaconado	
      p.date :acolitado	
      p.date :lectorado	
      p.string :cipna
    end
  end
end
