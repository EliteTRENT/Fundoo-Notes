class AddDefaultToIsDeleted < ActiveRecord::Migration[8.0]
  def change
    change_column_default :notes, :isDeleted, false
  end
end
