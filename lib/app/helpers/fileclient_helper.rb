module FileclientHelper

  def fileuploads_input(form,name, count = 5)
    
    out = ""
    if name.to_s.pluralize.singularize == name.to_s #only one file
      out << form.file_field(name)
			out << "<br />"
      
      if !form.object.new_record? && form.object.get_existence_of_file(name)
        out << t(:delete)
        out << check_box_tag("#{form.object.class.name.downcase}[#{name}_delete]", true)
        data_file = form.object.get_files_for(name)
        if data_file.width > data_file.height
          aspect = data_file.width.to_f/100.0
        else
          aspect = data_file.height.to_f/100.0
        end
        out << image_tag(data_file.get_url, :width=>data_file.width.to_f/aspect, :height=>data_file.height.to_f/aspect)
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
            if data_file.width > data_file.height
              aspect = data_file.width.to_f/100.0
            else
              aspect = data_file.height.to_f/100.0
            end
            out << image_tag(data_file.get_url, :width=>data_file.width.to_f/aspect, :height=>data_file.height.to_f/aspect)
      			out << "</li>"
          end
        out << "</ul>"
  			out << "<br />"
      end
 	  end
 	  out
  end

end