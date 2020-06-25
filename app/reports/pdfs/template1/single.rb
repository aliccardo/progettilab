module Single
	def single
		start_new_page( :size => 'A4', :layout => :portrait )
		font "OpenSans"

		# watermark
		#unless @report.issued?
		#  text_box "BOZZA", :size => 60, character_spacing: 10, :width => bounds.width, :height => bounds.height, :align => :center, :valign => :center, :at => [0, bounds.height], :rotate => 45, :rotate_around => :center
		#end

		stroke_color 0, 0, 0, 100
		bounding_box [bounds.left, bounds.top ], :width  => bounds.width, :height => 90 do
			unless Settings['reportpdf']['logo'].blank?
				image( "#{Rails.root}/app/assets/images/#{ Settings['reportpdf']['logo'] }", :at => [bounds.left+1, bounds.top-10], :width => 150, :height => 70 ) if Settings['reportpdf']['logo'].present?
      end
      text_box "#{Settings.reportpdf.subtitle.try(:upcase)}", :at => [(bounds.left+190), bounds.top-10], :size => 12, style: :bold
      # text_box "#{Settings.config.title.upcase}", :at => [(bounds.left+190), bounds.top-45], :size => 12, style: :bold
			text_box "RAPPORTO DI ANALISI", :at => [(bounds.left+190), bounds.top-65], :size => 12
			stroke_bounds
		end

		move_down(15)

		left = bounds.left+5
		rect_left = bounds.left+170
		rect_width = bounds.right-170
		field_left = bounds.left+175

		label_size = @fontsize
		text_size = @fontsize-0.5

		line_width = 1
		stroke_color 0, 0, 0, 40

		text_box I18n.t('code', scope: 'reports.fields', default: 'Report code').upcase, :size => label_size, :at => [left, cursor]
		stroke_rectangle [ rect_left, cursor+5 ], 90, 20
		text_box "#{ @report.code }", :size => text_size, :at => [field_left, cursor]

		text_box I18n.t('issued_at', scope: 'reports.fields', default: 'Issued at').upcase, :size => label_size, :at => [365, cursor]
		stroke_rectangle [ 440, cursor+5 ], 82, 20
		text_box "#{ Time.now.strftime("%d/%m/%Y") }", :size => text_size, :at => [445, cursor]

		move_down(25)
		text_box I18n.t('code', scope: 'jobs.fields', default: 'Job code').upcase, :size => label_size, :at => [left, cursor]
		stroke_rectangle [ rect_left, cursor+5 ], rect_width, 20
		text_box "#{@job.code}", :size => text_size, :at => [field_left, cursor]

		move_down(25)
		text_box I18n.t('customer', scope: 'reports.fields', default: 'Customer').upcase, :size => label_size, :at => [left, cursor]
		stroke_rectangle [ rect_left, cursor+5 ], rect_width, 20
		text_box "#{@report.job.customer}", :size => text_size, :at => [field_left, cursor]

		move_down(25)
		text_box I18n.t('object', scope: 'reports.fields', default: 'Job object').upcase, :size => label_size, :at => [left, cursor]
		stroke_rectangle [ rect_left, cursor+5 ], rect_width, 45
		text_box "#{@report.job.title}", :size => text_size, :at => [field_left, cursor]

		move_down(50)
		text_box I18n.t('client_code', scope: 'reports.fields', default: 'Client code').upcase, :size => label_size, :at => [left, cursor]
		stroke_rectangle [ rect_left, cursor+5 ], rect_width, 20
		text_box "#{@report.sample.client_code}", :size => text_size, :at => [field_left, cursor]

		move_down(25)
		text_box I18n.t('lab_code', scope: 'reports.fields', default: 'Lab sample code').upcase, :size => label_size, :at => [left, cursor]
		stroke_rectangle [ rect_left, cursor+5 ], rect_width, 20
		text_box "#{@report.sample.lab_code}", :size => text_size, :at => [field_left, cursor]

		move_down(25)
		text_box I18n.t('lat', scope: 'reports.fields', default: 'Latitude').upcase, :size => label_size, :at => [left, cursor]
		stroke_rectangle [ rect_left, cursor+5 ], 95, 20
		text_box "#{@report.sample.latitude}", :size => text_size, :at => [field_left, cursor]

		text_box I18n.t('long', scope: 'reports.fields', default: 'Longitude').upcase, :size => label_size, :at => [363, cursor]
		stroke_rectangle [ 428, cursor+5 ], 95, 20
		text_box "#{@report.sample.longitude}", :size => text_size, :at => [433, cursor]

		move_down(25)
		text_box I18n.t('start_at', scope: 'reports.fields', default: 'Start at').upcase, :size => label_size, :at => [left, cursor]
		stroke_rectangle [ rect_left, cursor+5 ], 95, 20
		text_box "#{@report.sample.start_on}", :size => text_size, :at => [field_left, cursor]

		text_box I18n.t('stop_at', scope: 'reports.fields', default: 'Stop at').upcase, :size => label_size, :at => [300, cursor]
		stroke_rectangle [ 428, cursor+5 ], 95, 20
		text_box "#{@report.sample.stop_on}", :size => text_size, :at => [433, cursor]

		move_down(25)
		text_box I18n.t('performed_at', scope: 'reports.fields', default: 'Performed on').upcase, :size => label_size, :at => [left, cursor]
		stroke_rectangle [ rect_left, cursor+5 ], rect_width, 20
		text_box "#{@report.analisy.performed_on}", :size => text_size, :at => [field_left, cursor]

		move_down(25)
		text_box I18n.t('reference_at', scope: 'reports.fields', default: 'Reference at').upcase, :size => label_size, :at => [left, cursor]
		stroke_rectangle [ rect_left, cursor+5 ], rect_width, 20
		text_box "#{@report.analisy.reference_on}", :size => text_size, :at => [field_left, cursor]

		move_down(25)
		text_box I18n.t('analisy_type', scope: 'reports.fields', default: 'Analisy type').upcase, :size => label_size, :at => [left, cursor]
		stroke_rectangle [ rect_left, cursor+5 ], rect_width, 20
		text_box "#{@report.analisy.type.title}", :size => text_size, :at => [field_left, cursor]

		move_down(25)
		text_box I18n.t('results', scope: 'reports.fields', default: 'Results').upcase, :size => label_size, :at => [left, cursor]
		results = @analisy.results.join("\r\n").force_encoding("UTF-8")
		stroke_rectangle [ left+60, cursor+5 ], bounds.width-65, 110
		formatted_text_box result_to_report( @report.analisy.results.map{ |r| r.doc_rif_int.present? ? "#{r.full_result_with_nuclide} (Doc.Rif.Int. #{ r.doc_rif_int })" : r.full_result_with_nuclide }.join("\r\n") ), { :size => text_size, :at => [left+65, cursor] }

		move_down(120)
		text_box I18n.t('body', scope: 'reports.fields', default: 'Note').upcase, :size => label_size, :at => [left, cursor]
		stroke_rectangle [ left+60, cursor+5 ], bounds.width-65, 120
		text_box "#{@report.analisy.note}#{"\r\n" if @report.analisy.note.present?}#{@report.results.map{ |r| "#{ r.info }\r\n#{ r.body }"  }.join("\r\n") }", :size => text_size-1, :at => [left+65, cursor]

		move_down(130)
		text_box I18n.t('technicians', scope: 'reports.fields', default: "Laboratory technician").upcase, :size => label_size, :at => [left, cursor]
		stroke_rectangle [ rect_left, cursor+5 ], rect_width, 20
		text_box "#{@report.analisy.analisy_technic_users.pluck(:label).join(', ')}", :size => text_size, :at => [field_left, cursor]

		move_down(25)
		text_box I18n.t('responsible_for_testing', scope: 'reports.fields', default: "responsible for testing").upcase, :size => label_size, :at => [left, cursor]
		stroke_rectangle [ rect_left, cursor+5 ], rect_width, 20
		text_box "#{@report.analisy.analisy_headtest_users.pluck(:label).join(', ')}", :size => text_size, :at => [field_left, cursor]

		move_down(25)
		text_box I18n.t('chief', scope: 'reports.fields', default: "Manager").upcase, :size => label_size, :at => [left, cursor]
		stroke_rectangle [ rect_left, cursor+5 ], rect_width, 20
		text_box "#{@report.analisy.analisy_chief_users.pluck(:label).join(', ')}", :size => text_size, :at => [field_left, cursor]

		# Footer
    if @report.analisy.type.id == 1 # analisy_type.title == 'Concentrazione di attività di radon in aria (SSNTD\'s)'
      text_box "#{Settings.reportpdf.bottom.analisy}", :at => [(bounds.left+1), bounds.bottom+20], :size => text_size-2, :overflow => :shrink_to_fit
    end
	end
end

def result_to_report( string )
  return Prawn::Text::Formatted::Parser.format( string )
end
