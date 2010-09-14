module FileclientHelper

  def fileuploads_input(form,name, count = 5)
    
    out = ""
    
    if !form.object.new_record? && form.object.is_movie?(name)
			out << "<br />"
			out << "<a href='#{form.object.get_link_to_upload_movie(name)}' target='_blank'> #{t(:for_uploading_movie_click_to_link)}</a>"
			if form.object.get_existence_of_file(name)
			  data_file = form.object.get_files_for(name)
        out << t(:delete)
        out << check_box_tag("#{form.object.class.name.downcase}[#{name}_delete]", true)
        out << " : "+data_file.get_filename_current
      end
			out << "<br />"
		elsif  form.object.new_record? && form.object.is_movie?(name)
			out << "<br />"
			out << "#{t(:not_possible_movie_upload_for_new_object)}"
			out << "<br />"
    else
      if name.to_s.pluralize.singularize == name.to_s #only one file
        out << form.file_field(name)
  			out << "<br />"
      
        if !form.object.new_record? && form.object.get_existence_of_file(name)
          out << t(:delete)
          out << check_box_tag("#{form.object.class.name.downcase}[#{name}_delete]", true)
          data_file = form.object.get_files_for(name)
          if data_file.is_image?
            if data_file.width > data_file.height
              aspect = data_file.width.to_f/100.0
            else
              aspect = data_file.height.to_f/100.0
            end
            out << image_tag(data_file.get_url, :width=>data_file.width.to_f/aspect, :height=>data_file.height.to_f/aspect)
          end
    			out << "<br />"
        end
      else
    
        form.fields_for name do |photo|
      	  count.times do |i|
      			out << photo.file_field(i)
      			out << "<br />"
    		  end
        end
        if !form.object.new_record? && form.object.get_existence_of_file(name)
          out << "<ul>"
            form.object.get_files_for(name).each do |data_file|
        			out << "<li>"
        			out << t(:delete)
              out << check_box_tag("#{form.object.class.name.downcase}[#{name}_delete][#{data_file.get_filename_current}]", true)
              out << data_file.get_filename_current+":"
              if data_file.is_image?
                if data_file.width > data_file.height
                  aspect = data_file.width.to_f/100.0
                else
                  aspect = data_file.height.to_f/100.0
                end
                out << image_tag(data_file.get_url, :width=>data_file.width.to_f/aspect, :height=>data_file.height.to_f/aspect)
              end
        			out << "</li>"
            end
          out << "</ul>"
    			out << "<br />"
        end
   	  end
   	end
 	  out
  end

end