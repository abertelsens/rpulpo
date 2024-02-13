class Addstatustomail < ActiveRecord::Migration[7.0]
    def change
      add_column :mails, :mail_status, :integer
      add_column :mails, :assigned_users, :string
      add_column :mails, :refs_string, :string
      add_column :mails, :ans_string, :string
    end
  end
