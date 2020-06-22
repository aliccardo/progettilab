class AddPrecisionToResultAndIndecision < ActiveRecord::Migration[5.2]
  def change
    # Aggiunge la colonna result_precision relativa alla precisione decimale del capo result da mostrare a video (necessrio per avere anche gli zeri non significativi!)
    add_column :analisy_results, :result_precision, :integer
    # Aggiunge la colonna indecision_precision relativa alla precisione decimale del campo indcision da mostrare a video (necessrio per avere anche gli zeri non significativi!)
    add_column :analisy_results, :indecision_precision, :integer
  end
end
