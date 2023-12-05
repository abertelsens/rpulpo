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
      p.string :clothes
      p.string :year
      p.integer :ctr,       default: 1        # cavabianca
      p.integer :n_agd,       default: 0      # n
      p.integer :status,       default: 0     # laico
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
  end

end
