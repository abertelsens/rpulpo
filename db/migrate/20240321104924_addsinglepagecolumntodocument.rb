class Addsinglepagecolumntodocument < ActiveRecord::Migration[7.0]
  def change
    add_column :documents, :singlepage, :boolean
  end
end
