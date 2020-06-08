json.DT_RowId "tr_#{analisy.id}"
json.id analisy.id
json.job do
  json.id         analisy.job.id
  json.code       analisy.job.code
  json.valid?     analisy.job.valid?
  json.url        edit_job_url(id: analisy.job.id)
end
json.sample do
  json.id         analisy.sample.id
  json.code       analisy.sample.code
  json.lab_code   analisy.sample.lab_code
  json.valid?     analisy.sample.valid?
  json.url        edit_job_sample_url(job_id: analisy.job.id, id: analisy.sample.id)
end
json.analisy do
  json.id analisy.id
  json.code       analisy.code
  json.type       analisy.type.title
  json.chiefs     analisy.analisy_chief_users.map{ |u| u.label if User.chiefs.pluck(:id).include?( u.id ) }.compact.join(',')
  json.headtests  analisy.analisy_headtest_users.map{ |u| u.label if User.headtests.pluck(:id).include?( u.id ) }.compact.join(',')
  json.technics   analisy.analisy_technic_users.map{ |u| u.label if User.technics.pluck(:id).include?( u.id ) }.compact.join(',')
  json.valid?     (
                    analisy.valid? && 
                    analisy.analisy_chief_users.map{ |u| u.label if User.chiefs.pluck(:id).include?( u.id ) }.compact.present? && 
                    analisy.analisy_headtest_users.map{ |u| u.label if User.headtests.pluck(:id).include?( u.id ) }.compact.present? &&
                    analisy.analisy_technic_users.map{ |u| u.label if User.technics.pluck(:id).include?( u.id ) }.compact.present?
                  )
  json.url        edit_job_sample_analisy_url(job_id: analisy.job.id, sample_id: analisy.sample.id, id: analisy.id)
end
json.results  analisy.results.each do | result |
  json.id         result.id
  json.result     result.full_result_with_nuclide
  json.valid?     result.valid?
  json.report do
    json.code     result.reports.issued.reorder(created_at: :desc).last.present? ? result.reports.issued.last.code : ''
    json.type     result.reports.issued.reorder(created_at: :desc).last.present? ? result.reports.issued.last.report_type : ''
    json.url      result.reports.issued.reorder(created_at: :desc).last.present? ? job_report_url(job_id: result.job.id, id: result.reports.issued.last.id) : ''
  end
end
json.readable can?(:read, analisy)
json.editable can?(:update, analisy)
json.deletable can?(:destroy, analisy)
json.creable can?(:create, Report)
json.valid? (
              analisy.job.valid? &&
              analisy.sample.valid? &&
              analisy.valid? &&
              analisy.analisy_chief_users.map{ |u| u.label if User.chiefs.pluck(:id).include?( u.id ) }.compact.present? &&
              analisy.analisy_headtest_users.map{ |u| u.label if User.headtests.pluck(:id).include?( u.id ) }.compact.present?
            )
json.has_reports? analisy.reports.issued.present?
json.report_code analisy.reports.issued.present? ? analisy.reports.issued.first.code : ''
json.url edit_job_sample_analisy_url(job_id: analisy.job.id, sample_id: analisy.sample.id, id: analisy.id)
