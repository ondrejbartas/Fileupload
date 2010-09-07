module Fileclient
  class DataFile  
    
    def self.default_options
      @default_options ||= {        
        :type=> "data",
        :rename => false,
        :base_filename => "",
        :templates => {}
      }
    end
     
    attr_reader :name, :instance
    def initialize(name, instance, options = {}, count = 0) #from application CLASS
      @client = Client.new()      
      @instance = instance
      @name = name
      @filename_current = nil
      
      options = self.class.default_options.merge(options)
  #    puts "\e[0;32mINICIALIZACE OBJEKTU #{name} #{@instance.id}\e[m"
  #    puts options.inspect
      
      opt_templates = []
      options[:templates].each do |key,template|
        opt_templates << Template.new().default_options(key).merge(template)
      end
      options[:templates] = opt_templates
      
   #   puts "\e[0;32mKONEC INICIALIZACE OBJEKTU #{name} #{@instance.id}\e[m"
      
      @destroy_all = false
      @queued_for_delete = []
      @queued_for_write  = []
      @model_name        = name
      @options           = options
      @errors            = {} 
      datas = instance_read("upload")
      if !datas.nil? && datas.length > 20
        data = JSON.parse(datas)
        if !data['files'][@instance.id.to_s].nil?
          @filename_original = data['files'][@instance.id.to_s][count]["filename_original"]
          @filename_current = data['files'][@instance.id.to_s][count]["filename_current"]
          @url = data['files'][@instance.id.to_s][count]["url"]
          @type = data['files'][@instance.id.to_s][count]["file_type"]
          @width = data['files'][@instance.id.to_s][count]["width"]
          @height = data['files'][@instance.id.to_s][count]["height"]
          @size = data['files'][@instance.id.to_s][count]["size"]
          @generated_files = {}
          data['files'][@instance.id.to_s][count]['generated_files'].each do |key,file|
              @generated_files[key] = GeneratedFile.new(file, @client.get_server_address)
          end
        end
      end
      
    end    
    
    def is_image?
      @type == "images"
    end

    def get_size
      @size
    end

    def height
      @height.to_i
    end
    def width
      @width.to_i
    end

    def get_filename_current
      @filename_current
    end

    def get_filename_original
      @filename_original
    end

    def delete
      @queued_for_delete << @filename_current
      flush_deletes
    end
    
    def assign uploaded_file
      if uploaded_file.is_a?(Hash)
        
        uploaded_file.binmode if uploaded_file.respond_to? :binmode

        return nil if uploaded_file.nil?
      
        #if object is now saved, upload file after save and save agin for data update
        if @instance.id.nil? 
          uploaded_file.each do |key,file|
            if !file.nil?
              @queued_for_write << file
            #  puts "\e[0;32mPRIDANO DO QUE FOR SAVE #{file} \e[m"
            end
          end
        else
          uploaded_file.each do |key,file|
            if !file.nil?
              output = @client.upload_file(file,@model_name,@instance,@options)          
              instance_write("upload", output.body) 
            #  puts "\e[0;32mDIRECT UPLOAD#{file}\e[m"
            end
          end          
        end
      else 
        if uploaded_file.is_a?(Fileclient::DataFile)
          uploaded_file = uploaded_file.to_file(:original)
          close_uploaded_file = uploaded_file.respond_to?(:close)
        end

        uploaded_file.binmode if uploaded_file.respond_to? :binmode

        return nil if uploaded_file.nil?
      
        #if object is now saved, upload file after save and save agin for data update
        if @instance.id.nil? 
          @queued_for_write << uploaded_file
        else
          output = @client.upload_file(uploaded_file,@model_name,@instance,@options)          
          instance_write("upload", output.body) 
        end
      end
    ensure
      uploaded_file.close if close_uploaded_file
    end
  
  
    def instance_write(attr, value)
      setter = :"#{name}_#{attr}="
      responds = instance.respond_to?(setter)
      self.instance_variable_set("@_#{setter.to_s.chop}", value)
      instance.send(setter, value)
    end

    # Reads the attachment-specific attribute on the instance. See instance_write
    # for more details.
    def instance_read(attr)
      getter = :"#{name}_#{attr}"
      responds = instance.respond_to?(getter)
      cached = self.instance_variable_get("@_#{getter}")
      return cached if cached
      instance.send(getter) 
    end
  
  
    def get_url
      if !@url.nil?
        @client.get_server_address+@url
      else
        nil
      end
    end

    def thumb_url(name)
      if !@generated_files.nil? && !@generated_files[name].nil?
        @generated_files[name].get_url
      else
        "this_is_not_style"
      end
    end
    
    def thumb(name)
      if !@generated_files.nil? && !@generated_files[name].nil?
        @generated_files[name]
      else
        nil
      end
    end
  
  
    def to_s
       out_files = ""
       self.generated_files.each do |key, file|
          out_files += key+" : "+file.to_s+", "
       end

      self.filename_current+" ("+self.type+") - "+self.get_url+" | GENERATED: ["+out_files+"] "
    end

    def flush_deletes #:nodoc:  
      puts "ke smazani"+@queued_for_delete.inspect
      if @queued_for_delete.size > 0
        out = nil
        @queued_for_delete.each do |filename|          
          out = @client.delete_file(@name,@instance,filename)
        end
        if @destroy_all == false
          instance_write("upload", out.body)
          @instance.save
        end
      end
    end

    def queue_selected_for_delete #:nodoc:
       if !@filename_current.nil?
         @queued_for_delete << @filename_current
       end
    end
    
    def queue_existing_for_delete #:nodoc:
       @destroy_all = true
       if !@filename_current.nil?
         @queued_for_delete << @filename_current
       end
    end
    
    def save
      if @queued_for_write.size > 0
        @queued_for_write.each do |uploaded_file|
          output = @client.upload_file(uploaded_file,@model_name,@instance,@options)          
          instance_write("upload", output.body)
        end
        @queued_for_write = []
        @instance.save
      end
      true
    end
    
    
    def reprocess!
        output = @client.reprocess(@model_name,@instance,@options)          
        instance_write("upload", output.body) 
        save
        
        return "Reprocessed: #{@instance.class.name}:#{@model_name} - #{instance.id}"
    end
    
    private

      def ensure_required_accessors! #:nodoc:
        %w(uploaded).each do |field|
          unless @instance.respond_to?("#{name}_#{field}") && @instance.respond_to?("#{name}_#{field}=")
            raise  FileclientError.new("#{@instance.class} model missing required attr_accessor for '#{name}_#{field}'")
          end
        end
      end
    
    end
end
