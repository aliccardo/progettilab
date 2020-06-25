class AddPerformedAtToAnalisy < ActiveRecord::Migration[5.2]
  def change
    add_column :analisies, :performed_at, :datetime
  end
end
