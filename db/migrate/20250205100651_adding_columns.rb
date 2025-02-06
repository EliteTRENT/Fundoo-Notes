class AddingColumns < ActiveRecord::Migration[8.0]
  def change
    add_column :notes, :isArchive, :boolean, default: false
    add_column :notes, :color, :string, default: "white"
  end
end
