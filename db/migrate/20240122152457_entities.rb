class Entities < ActiveRecord::Migration[7.0]
  def change
    create_table :entities do |p|
      p.string    :sigla
      p.string    :name
      p.string    :path
    end
  end
end
