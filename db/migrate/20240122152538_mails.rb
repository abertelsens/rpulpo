class Mails < ActiveRecord::Migration[7.0]
  def change
    create_table :mails do |p|
      p.integer       :entity_id
      p.date          :date
      p.string        :topic
      p.string        :protocol
      p.string        :base_path
      p.integer       :direction
    end
  end
end
