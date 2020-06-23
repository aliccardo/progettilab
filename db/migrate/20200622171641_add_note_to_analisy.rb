class AddNoteToAnalisy < ActiveRecord::Migration[5.2]
  def change
    add_column :analisies, :note, :string
  end
end
