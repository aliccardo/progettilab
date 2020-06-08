json.DT_RowId "tr_#{result.id}"
json.id result.id
json.results result.full_result_with_nuclide
json.job do
  json.id result.job.id
  json.code result.job.code
  json.valid? result.job.valid?
  json.url edit_job_url(id: result.job.id)
end
json.sample do
  json.id result.sample.id
  json.code result.sample.code
  json.lab_code result.sample.lab_code
  json.valid? result.sample.valid?
  json.url edit_job_sample_url(job_id: result.job.id, id: result.sample.id)
end
json.analisy do
  json.id result.analisy.id
  json.code result.analisy.code
  json.type result.analisy.type.title
  json.chiefs     result.analisy.analisy_chief_users.map{ |u| u.label if User.chiefs.pluck(:id).include?( u.id ) }.compact.join(',')
  json.headtests  result.analisy.analisy_headtest_users.map{ |u| u.label if User.headtests.pluck(:id).include?( u.id ) }.compact.join(',')
  json.technics   result.analisy.analisy_technic_users.map{ |u| u.label if User.technics.pluck(:id).include?( u.id ) }.compact.join(',')
  json.valid? (
                result.analisy.valid? &&
                result.analisy.analisy_chief_users.map{ |u| u.label if User.chiefs.pluck(:id).include?( u.id ) }.compact.present? &&
                result.analisy.analisy_headtest_users.map{ |u| u.label if User.headtests.pluck(:id).include?( u.id ) }.compact.present?
              )
  json.url edit_job_sample_analisy_url(job_id: result.job.id, sample_id: result.sample.id, id: result.analisy.id)
end
json.readable can?(:read, result)
json.editable can?(:update, result)
json.deletable can?(:destroy, result)
json.creable can?(:create, Report)
json.valid? (
              result.analisy.valid? &&
              result.sample.valid? &&
              result.analisy.valid? &&
              result.valid? &&
              result.analisy.analisy_chief_users.map{ |u| u.label if User.chiefs.pluck(:id).include?( u.id ) }.compact.present? &&
              result.analisy.analisy_headtest_users.map{ |u| u.label if User.headtests.pluck(:id).include?( u.id ) }.compact.present?
            )
json.url edit_job_sample_analisy_result_url(job_id: result.job.id, sample_id: result.sample.id, analisy_id: result.analisy.id, id: result.id)
