class AddIsDeletedColumn < ActiveRecord::Migration[8.0]
  def change
    add_column :notes, :isDeleted, :boolean
  end
end
