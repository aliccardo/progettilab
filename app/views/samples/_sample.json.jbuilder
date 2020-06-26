json.extract! sample, :id, :code, :lab_code, :client_code, :device, :created_by, :updated_by, :referenced_at, :referenced_on, :accepted_at, :accepted_on, :body
json.type_matrix sample.type_matrix || { title: '' }
json.job do
  json.code sample.job.code
  json.url job_path(sample.job)
  json.valid? sample.job.valid?
end
json.analisies do
  json.partial! 'analisies/analisy', collection: sample.analisies, as: :analisy
end
json.readable can?(:read, sample) && cannot?(:update, sample)
json.editable can?(:update, sample)
json.deletable can?(:destroy, sample)
json.valid? sample.valid?
json.url job_sample_path( job_id: sample.job_id, id: sample.id )
