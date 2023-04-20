class People < ActiveRecord::Migration[7.0]
  def change
    
    create_table :people do |p|
      p.string :title         
      p.string :first_name,         null: false
      p.string :family_name,        null: false
      p.string :short_name,         null: false
      p.string :full_name,         null: false
      p.string :nominative
      p.string :accussative        
      p.string :full_info  
      p.string :group
      p.integer :lives,       default: 1      #cavabianca
      p.boolean :arrived,     default: true
      p.boolean :cavabianca,  default: true
      p.date :arrival
      p.date :departure
      p.boolean :teacher,     default: false
      p.date :birth
      p.string :celebration_info
      p.string :email
      p.string :phone
      p.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
    add_index :people, [:first_name, :family_name], unique: true
  end

end
