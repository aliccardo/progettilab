class AddIndexSampleLatLong < ActiveRecord::Migration[5.2]
  remove_index :samples, [:latitude, :longitude] if index_exists?(:samples, [:latitude, :longitude])
  add_index :samples, [:latitude, :longitude]
end
