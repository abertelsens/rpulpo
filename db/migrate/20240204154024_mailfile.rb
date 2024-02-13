class Mailfile < ActiveRecord::Migration[7.0]
  def change
    create_table :mail_files do |p|
      p.integer       :mail_id
      p.string        :name
      p.string        :href
      p.string        :extension
    end
  end
end
