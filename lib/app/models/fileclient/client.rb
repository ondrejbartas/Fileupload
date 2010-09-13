module Fileclient
  class Client  
    def initialize()
       config = File.open(File.join(RAILS_ROOT,"config","fileupload.yml")) { |f| YAML::load(f) }
       @private_key = config[ENV['RAILS_ENV']]['private_key']
       @server_address = config[ENV['RAILS_ENV']]['server_address']
    end
   def get_server_address
      @server_address
   end

   def get_movie_on_update(model_name, instance)
     uri = URI.parse(@server_address+"/clients/get_movie?private_key="+@private_key+"&class_name=#{instance.class.name}&domain_model_name="+model_name+"&received_id="+instance.id.to_s)
     http = Net::HTTP.new(uri.host, uri.port)
     return http.request(Net::HTTP::Get.new(uri.request_uri))
   end


   def get_files_for_model(model_name, instance)
     uri = URI.parse(@server_address+"/clients/get_files_for_model?private_key="+@private_key+"&class_name=#{instance.class.name}&domain_model_name="+model_name)
     http = Net::HTTP.new(uri.host, uri.port)
     response = http.request(Net::HTTP::Get.new(uri.request_uri))
     model_file = ModelFile.new(JSON.parse(response.body), @server_address)
   
     return model_file
    end

    def delete_file(model_name, instance, filename)
      uri = URI.parse("#{@server_address}/clients/delete_file_for_model?filename=#{URI.escape(filename)}&private_key=#{@private_key}&class_name=#{instance.class.name}&domain_model_name=#{model_name}&received_id=#{instance.id.to_s}")
      
#      puts "--------------------------------"
#      puts "#{@server_address}/clients/delete_file_for_model?filename=#{filename}&private_key=#{@private_key}&domain_model_name=#{model_name}&received_id=#{instance.id.to_s}"
#      puts "--------------------------------"
      
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.request(Net::HTTP::Get.new(uri.request_uri))
    end
    
    def delete_files(model_name, instance)
      uri = URI.parse(@server_address+"/clients/delete_files_for_model?private_key="+@private_key+"&class_name=#{instance.class.name}&domain_model_name=#{model_name}&received_id="+instance.id.to_s)
      
#      puts "--------------------------------"
#      puts @server_address+"/clients/delete_files_for_model?private_key="+@private_key+"&domain_model_name=#{model_name}&received_id="+instance.id.to_s
#      puts "--------------------------------"
      
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.request(Net::HTTP::Get.new(uri.request_uri))
    end


    def reprocess(model_name,instance,options)   
      boundary = "AaB03x-_ASADQWSAQW"      
      if model_name.to_s.pluralize.singularize == model_name.to_s #only one file
        count = 1
      else  
        count = 0
      end
      uri = URI.parse(@server_address+"/clients/reprocess")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({
          "private_key" => "#{@private_key}",
          "class_name" => "#{instance.class.name}",
          "domain_model_name" => "#{model_name}",
          "received_id" => "#{instance.id}",
          "direct" => true, 
          "options" => options.to_json
          
          })
      response = http.request(request)
    end
    
    def upload_file(uploaded_file,model_name,instance, options)
      boundary = "AaB03x-_ASADQWSAQW"      
      if model_name.to_s.pluralize.singularize == model_name.to_s #only one file
        count = 1
      else  
        count = 0
      end
      uri = URI.parse(@server_address+"/uploads/upload")
      
      post_body = []
      post_body << "--#{boundary}\r\n"
      post_body << "Content-Disposition: form-data; name=\"private_key\"\r\n"
      post_body << "\r\n"
      post_body << "#{@private_key}\r\n"

      post_body << "--#{boundary}\r\n"
      post_body << "Content-Disposition: form-data; name=\"class_name\"\r\n"
      post_body << "\r\n"
      post_body << "#{instance.class.name}\r\n"

      post_body << "--#{boundary}\r\n"
      post_body << "Content-Disposition: form-data; name=\"domain_model_name\"\r\n"
      post_body << "\r\n"
      post_body << "#{model_name}\r\n"

      post_body << "--#{boundary}\r\n"
      post_body << "Content-Disposition: form-data; name=\"received_id\"\r\n"
      post_body << "\r\n"
      post_body << "#{instance.id}\r\n"

      post_body << "--#{boundary}\r\n"
      post_body << "Content-Disposition: form-data; name=\"Filename\"\r\n"
      post_body << "\r\n"
      post_body << "#{uploaded_file.original_filename.to_s}\r\n"

      post_body << "--#{boundary}\r\n"
      post_body << "Content-Disposition: form-data; name=\"direct\"\r\n"
      post_body << "\r\n"
      post_body << "true\r\n"

      if !options.nil?
        post_body << "--#{boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"options\"\r\n"
        post_body << "\r\n"
        post_body << options.to_json+"\r\n"
      end

      post_body << "--#{boundary}\r\n"
      post_body << "Content-Disposition: form-data; name=\"count\"\r\n"
      post_body << "\r\n"
      post_body << "#{count}\r\n"

      post_body << "--#{boundary}\r\n"
      post_body << "Content-Disposition: form-data; name=\"file\"; filename=\"#{uploaded_file.original_filename.to_s}\"\r\n"
      post_body << "Content-Type: #{uploaded_file.content_type}\r\n"
      post_body << "\r\n"
      post_body << File.read(uploaded_file.to_tempfile.path)

#      post_body << File.read(uploaded_file.to_tempfile)
      post_body << "\r\n--#{boundary}--\r\n"

      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = post_body.join
      request["Content-Type"] = "multipart/form-data, boundary=#{boundary}"


      # puts "---------------------------------"
      #        puts request.body
      #        puts "---------------------------------"
      response = http.request(request)
    end
        
  end
end