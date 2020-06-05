module Multiple
	@chief = ''
	@headtest = ''
	@technics = ''


	def multiple
    @analisy_type = ''
		results = AnalisyResult.select("analisy_results.*, chiefs.label as chief, headtests.label as headtest, technics.technics AS technics").joins( "LEFT JOIN (SELECT analisy_users.analisy_id, users.label FROM analisy_users INNER JOIN users ON analisy_users.user_id = users.id WHERE analisy_users.role = 0) AS chiefs ON analisy_results.analisy_id = chiefs.analisy_id" ).joins( "LEFT JOIN (SELECT analisy_users.analisy_id, users.label FROM analisy_users INNER JOIN users ON analisy_users.user_id = users.id WHERE analisy_users.role = 1) AS headtests ON analisy_results.analisy_id = headtests.analisy_id" ).joins( "LEFT JOIN (SELECT analisy_users.analisy_id, array_to_string(array_agg(users.label order by users.label),',') AS technics FROM analisy_users INNER JOIN users ON analisy_users.user_id = users.id WHERE analisy_users.role = 2 GROUP BY analisy_users.analisy_id) AS technics ON analisy_results.analisy_id = technics.analisy_id" ).where(id: @result_ids).joins(:analisy_type).reorder( "analisy_types.title, chief, headtest, technics")
    left = bounds.left
    rect_left = bounds.left+150
    field_left = bounds.left+155

    label_size = @fontsize
    text_size = @fontsize-0.5

    @rows = []
    canvas do
    	unless results.blank?
	    	results.each do | result |
	    		if @rows.size == 0
	    			initialization( result )
	    		elsif @rows.size > 1
	    			if @analisy_type != result.analisy_type.title || @chief != result.chief || @headtest != result.headtest || @technics != result.technics
				    	write_page( result )
				    end
					end
				  @rows << [
            result.sample.client_code,
            result.sample.start_on,
            result.sample.stop_on,
            result.sample.lab_code,
            result.full_result_with_nuclide,
            result.body
          ]
					if results.last.id == result.id # && @rows.size > 1
						write_page( result )
					end
				end
			else
				write_page ''
			end
		end

	  string = "<page> di <total>"
    options = { :at => [bounds.right, 0],
     :align => :right,
     :start_count_at => 1 }
		number_pages string, options
	end
end

def header
  # header
  canvas do
    bounding_box [bounds.left, bounds.top ], :width  => bounds.width, :height => 90 do
      unless Settings['reportpdf']['logo'].blank?
        image( "#{Rails.root}/app/assets/images/#{ Settings['reportpdf']['logo'] }", :at => [bounds.left+1, bounds.top-10], :width => 150, :height => 70 ) if Settings['reportpdf']['logo'].present?
      end
      text_box "#{Settings.reportpdf.subtitle.try(:upcase)}", :at => [(bounds.left+190), bounds.top-10], :size => 12, style: :bold
      # text_box "#{Settings.config.title.upcase}", :at => [(bounds.left+250), bounds.top-35], :size => 12, style: :bold
      text_box "RAPPORTO DI ANALISI MULTIPLO", :at => [(bounds.left+190), bounds.top-65], :size => 12
      stroke do
        line = horizontal_line 0, bounds.width, :at => 0
      end
    end
    left = bounds.left
    rect_left = bounds.left+150
    field_left = bounds.left+155

    label_size = @fontsize
    text_size = @fontsize-0.5
    bounding_box [bounds.left, cursor ], :width  => bounds.width, :height => 60 do
      move_down(10)
      text_box "ID RAPPORTO", :size => text_size, :at => [left+20, cursor], style: :bold
      text_box "#{ @report.code }", :size => text_size, :at => [left+80, cursor]
      text_box "DATA EMISSIONE", :size => text_size, :at => [left+180, cursor], style: :bold
      text_box "#{ Time.now.strftime("%d/%m/%Y") }", :size => text_size, :at => [left+260, cursor]
      text_box "PROC/ATT", :size => text_size, :at => [left+310, cursor], style: :bold
      text_box "#{@job.code}", :size => text_size, :at => [left+360, cursor]
      text_box "OGGETTO", :size => text_size, :at => [left+420, cursor], style: :bold
      text_box "#{@job.title}", :size => text_size, :at => [left+500, cursor]

      move_down(20)
      text_box "CLIENTE", :size => text_size, :at => [left+20, cursor], style: :bold
      text_box "#{@job.customer}", :size => text_size, :at => [left+60, cursor]
      move_down(20)
      text_box "TIPOLOGIA ANALISI", :size => text_size, :at => [left+20, cursor], style: :bold
      text_box "#{@analisy_type}", :size => text_size, :at => [left+120, cursor]
      stroke do
        line = horizontal_line 0, bounds.width, :at => 0
      end
    end
  end
end

def footer
	# footer
  canvas do
  	left = bounds.left
    rect_left = bounds.left+150
    field_left = bounds.left+155

    label_size = @fontsize
    text_size = @fontsize-0.5
    bounding_box [bounds.left, bounds.bottom + 110], :width  => bounds.width do
      stroke do
        line = horizontal_line 0, bounds.width, :at => 0
      end
      move_down(5)
      text_box "Nota incertezza", :size => text_size, :at => [left+20, cursor], style: :bold
      text_box "#{@report.general_body}", :size => text_size, :at => [left+160, cursor]
    end
    bounding_box [bounds.left, bounds.bottom + 70], :width  => bounds.width do
    	stroke do
        line = horizontal_line 0, bounds.width, :at => 0
      end
      move_down(10)
      text_box "Tecnici di laboratorio", :size => text_size, :at => [left+20, cursor], style: :bold
      text_box "#{@technics}", :size => text_size, :at => [left+160, cursor]
      move_down(20)
      text_box "Responsabile di prova", :size => text_size, :at => [left+20, cursor], style: :bold
      text_box "#{@headtest}", :size => text_size, :at => [left+160, cursor]
      move_down(20)
      text_box "Responsabile di area", :size => text_size, :at => [left+20, cursor], style: :bold
      text_box "#{@chief}", :size => text_size, :at => [left+160, cursor]
      # move_down(20)
      # Footer
      if @analisy_type_id == 1 # @analisy_type == 'Concentrazione di attività di radon in aria (SSNTD\'s)'
        move_up 20
        text_box "#{Settings.reportpdf.bottom.analisy}", :at => [left+450, cursor], :size => text_size-2, :overflow => :shrink_to_fit
      end
    end
  end

end

def initialization( result )
  @analisy_type = result.analisy_type.title
  @analisy_type_id = result.analisy_type.id
	@chief = result.chief
	@headtest = result.headtest
	@technics = result.technics
	@rows << [
      { :content => 'Cod. cliente', align: :center },
      { :content => 'Data inizio esposizione', align: :center },
      { :content => 'Data fine esposizione', align: :center },
      { :content => 'Cod. RAD-AMB', align: :center },
      { :content => 'Attività', align: :left },
      { :content => 'Note', align: :justify },
    ]
end

def write_page( result )
	# if @chief != result.chief || @headtest != result.headtest || @technics != result.technic
  	start_new_page( :size => 'A4', :layout => :landscape )
		font "OpenSans"
    header
		unless @rows.blank?
	    canvas do
	    	move_down 150
		    table(@rows, width: bounds.width, header: true, row_colors: ['e6e6e6', 'ffffff'], :cell_style => { :size => 8, inline_format: true } ) do
		      row(0).style :font_style => :bold
		      column(0).style align: :center, width: 60
		      column(1).style align: :center, width: 80
		      column(2).style align: :center, width: 80
		      column(3).style align: :center, width: 80
		      column(4).style align: :left, width: 180, inline_format: true
		      column(5).style align: :left, inline_format: true
		    end
		  end
		end
	  footer
	  @rows = []
	  initialization( result ) unless result.blank?
  # end

end

def result_to_report( string )
  return Prawn::Text::Formatted::Parser.format( string )
end
