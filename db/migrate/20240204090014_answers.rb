class Answers < ActiveRecord::Migration[7.0]
  def change
    create_table :answers do |p|
      p.integer       :mail_id
      p.integer       :answer_id
    end
  end
end
