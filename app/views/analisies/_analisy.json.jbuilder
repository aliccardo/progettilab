json.extract! analisy, :id, :sample_id, :code, :revision, :reference_at, :method, :body
json.type do
	json.id analisy.type.id
	json.title analisy.type.title
end
json.job do
  json.code analisy.job.code
  json.url job_path(analisy.job)
  json.valid? analisy.job.valid?
end
json.sample do
	json.id analisy.sample.id
	json.code analisy.sample.code
	json.lab_code analisy.sample.lab_code
	json.type_matrix analisy.sample.type_matrix.title
	json.device analisy.sample.device
	json.valid? analisy.sample.valid?
  json.url job_sample_path(job_id: analisy.job.id, id: analisy.sample.id)
end
json.reference_on analisy.reference_on
json.results analisy.results do |result|
	json.id result.id
	json.nuclide do
		json.id result.nuclide_id
		json.title result.nuclide.title
	end
	json.result result.result
	json.absent = result.absent
	json.absence_analysis = result.absence_analysis
	json.full_result result.full_result
	json.full_result_with_nuclide result.full_result_with_nuclide

	json.reports result.reports.issued do |report|
		json.id report.id
	end
	# json.report_url result.report.blank? ? '' : report_job_sample_analisy_url(job_id: result.job.id, sample_id: analisy.sample.id, id: analisy.id, file_id: analisy.report.id)
end

json.readable can?(:read, analisy)
json.editable can?(:update, analisy)
json.deletable can?(:destroy, analisy)
json.download false #can?(:download, analisy.report)
json.valid? analisy.valid?
json.url job_sample_analisy_path(job_id: analisy.job.id, sample_id: analisy.sample_id, id: analisy.id)
