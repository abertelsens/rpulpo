class References < ActiveRecord::Migration[7.0]
  def change
    create_table :references do |p|
      p.integer       :mail_id
      p.integer       :reference_id
    end
  end
end
