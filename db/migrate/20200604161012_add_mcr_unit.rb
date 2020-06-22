class AddMcrUnit < ActiveRecord::Migration[5.2]
  def change
    # Aggiunge la colonna mcr_unit_id relativa alle unità di misura della tabella analisy_results
    add_column :analisy_results, :mcr_unit_id, :integer, default: 4
    # Aggiunge il vincolo di chiave esterna alla tabella analisy_results sul campo mcr_unit_id relativa alle unità di misura della tabella units
    add_foreign_key :analisy_results, :units, column: :mcr_unit_id, primary_key: "id", on_delete: :restrict, on_update: :cascade
  end
end
