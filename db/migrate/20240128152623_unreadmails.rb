class Unreadmails < ActiveRecord::Migration[7.0]
  def change
    create_table :unread_mails do |p|
      p.integer       :mail_id
      p.integer       :user_id
    end
  end
end
