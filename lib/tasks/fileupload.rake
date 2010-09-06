def obtain_class
  class_name = ENV['CLASS'] || ENV['class']
  raise "Must specify CLASS" unless class_name
  puts "CLASS: #{class_name}"
  @klass = Object.const_get(class_name)
end

def obtain_fileuploads
  name = ENV['FILEUPLOAD'] || ENV['fileupload']
  raise "Class #{@klass.name} has no fileuploads specified" unless @klass.respond_to?(:fileupload_definitions)
  if !name.blank? && @klass.fileupload_definitions.keys.include?(name)
    [ name ]
  else
    @klass.fileupload_definitions.keys
  end
end

def for_all_fileuploads
  klass = obtain_class
  names = obtain_fileuploads
  ids   = klass.connection.select_values(klass.send(:construct_finder_sql, :select => 'id'))

  ids.each do |id|
    instance = klass.find(id)
    names.each do |name|
      result = if instance.send("#{ name }?")
                 yield(instance, name)
               else
                 true
               end
      print result ? "." : "x\n"; $stdout.flush
    end
  end
  puts " Done."
end

namespace :fileupload do
  task :refresh => :environment do
  desc "Regenerates thumbnails for a given CLASS (and optional ATTACHMENT)."
        errors = []
        for_all_fileuploads do |instance, name|
          if name.to_s.pluralize.singularize == name.to_s            
            result = instance.send(name).reprocess!
            print result
          else
            instance.send(name).each do |file|
              result = file.reprocess!
              print  result+"\n"; $stdout.flush
            end
          end
        end    
  end
end