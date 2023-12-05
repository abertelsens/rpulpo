class Users < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |p|
      p.string  :uname, unique: true
      p.string  :password
      p.integer :usertype
    end
  end
end
