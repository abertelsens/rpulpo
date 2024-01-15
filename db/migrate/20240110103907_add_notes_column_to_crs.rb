class AddNotesColumnToCrs < ActiveRecord::Migration[7.0]
  def change
    add_column :crs, :notes, :string
  end
end
