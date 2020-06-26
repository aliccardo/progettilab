class AddReferencedAtToSample < ActiveRecord::Migration[5.2]
  def change
    add_column :samples, :referenced_at, :datetime
  end
end
