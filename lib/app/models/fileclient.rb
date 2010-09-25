module Fileclient

  def self.included(base) 
    base.send :extend, ClassMethods 
   end 
  
  class FileclientError < StandardError #:nodoc:
  end
    
   module ClassMethods
      def has_uploaded_file name, options = {}
        include InstanceMethods

        write_inheritable_attribute(:fileupload_definitions, {}) if fileupload_definitions.nil?
        fileupload_definitions[name] = options
        attr_accessor :"#{name}_delete"
        before_save :get_movie
        after_save :save_uploaded_files
        after_save :delete_uploaded_files
        before_destroy :destroy_uploaded_files

        define_method name do |*args|
          a = fileupload_for(name)
          (args.length > 0) ? a.to_s(args.first) : a
        end

        define_method "#{name}=" do |file|
          fileupload_for(name).assign(file)
        end

        define_method "#{name}?" do
          get_existence_of_file(name)
        end
        
        define_method "#{name}" do
          get_files_for(name)
        end

        define_method "#{name}.delete" do
          fileupload_for(name).delete
        end


      end
      
       def fileupload_definitions
          read_inheritable_attribute(:fileupload_definitions)
       end
    end

    module InstanceMethods #:nodoc:      
      def instance_read(name,attr)
        getter = :"#{name}_#{attr}"
        responds = self.respond_to?(getter)
        cached = self.instance_variable_get("@_#{getter}")
        return cached if cached
        self.send(getter) 
      end
      
      def get_files_for name
        if name.to_s.pluralize.singularize == name.to_s #only one file
          DataFile.new(name, self,self.class.fileupload_definitions[name])
        else #a lot of files
          datas = instance_read(name,"upload")
          if !datas.nil? && datas.length > 20
            data = JSON.parse(datas)
            data_files = []
            data['files'][self.id.to_s].size.times do |count|
              data_files << DataFile.new(name, self, self.class.fileupload_definitions[name], count)
            end
            return data_files
          else
            nil
          end
        end
      end
      
      def get_existence_of_file name
        return !instance_read(name,"upload").nil? && instance_read(name,"upload").length > 20
      end
      
      
      def fileupload_for name
        @_fileuploads ||= {}
        @_fileuploads[name] ||= DataFile.new(name, self, self.class.fileupload_definitions[name])
      end

      def each_fileupload_old
        self.class.fileupload_definitions.each do |name, definition|
          yield(name, fileupload_for(name))
        end
      end

      def each_fileupload
        self.class.fileupload_definitions.each do |name, definition|
          yield(name, get_files_for(name))
        end
      end

      def save_uploaded_files
        #each_fileupload_old do |name, fileupload|
        #    fileupload.send(:flush_deletes)
        #    fileupload.send(:save)
        #end

        each_fileupload do |name, fileupload|
          if !fileupload.nil?
            if name.to_s.pluralize.singularize == name.to_s
              fileupload.send(:flush_deletes)
              fileupload.send(:save)
            else
              fileupload.each do |file|
                file.send(:flush_deletes)
                file.send(:save)
              end
            end
          end
        end
      end

      def delete_uploaded_files
        puts "\e[0;32m MAZANI \e[m"
        each_fileupload do |name, fileupload|
          if !fileupload.nil?
            if name.to_s.pluralize.singularize == name.to_s #only one file            
              if instance_read(name,"delete") == "true"
                fileupload.send(:queue_selected_for_delete)
                fileupload.send(:flush_deletes)
              end
            else 
              puts "\e[0;32m MAZANI 2\e[m"+instance_read(name,"delete").inspect
              fileupload.each do |file|
                puts instance_read(name,"delete").inspect+" --- "+file.get_filename_current
                if !instance_read(name,"delete").nil? && instance_read(name,"delete")[file.get_filename_current] == "true"
                  puts "maze"
                  file.send(:queue_selected_for_delete)
                  file.send(:flush_deletes)
                end
              end
            end
          end
        end
      end

      def is_movie?(name_in)
        self.class.fileupload_definitions.each do |name, definition|
          if name_in == name &&  definition[:type] == "movie"
            return true
          end
        end 
        return false
      end
      
      def get_link_to_upload_movie(name_in)
        link = ""
        self.class.fileupload_definitions.each do |name, definition|
          if name_in == name && definition[:type] == "movie"
             link = DataFile.new(name, self, self.class.fileupload_definitions[name]).get_link_to_upload_movie
          end
        end 
        link
      end

      def get_movie
         self.class.fileupload_definitions.each do |name, definition|
           if definition[:type] == "movie"
              puts "vytvarim objekt"
              begin
                DataFile.new(name, self, self.class.fileupload_definitions[name]).get_movie
                puts instance_read(name,"upload")
              rescue
              end
              puts "ted by mel objekt mit nactene video"
           end
         end 
      end
      
      def destroy_uploaded_files
        each_fileupload do |name, fileupload|
          if !fileupload.nil?
            if name.to_s.pluralize.singularize == name.to_s #only one file            
              fileupload.send(:queue_existing_for_delete)
              fileupload.send(:flush_deletes)
            else 
              fileupload.each do |file|
                file.send(:queue_existing_for_delete)
                file.send(:flush_deletes)
              end
            end
          end
        end
      end
    end 
  
end

ActiveRecord::Base.send :include, Fileclient