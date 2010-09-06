module Fileclient
  class ModelFile
    
    def initialize(data, server_address) #get data in JSON
      @public_key = data['model']['public_key']
      @name = data['model']["name"]
      @url = data['model']["url"]
      @templates = data['model']["templates"]
      @type = data['model']["type"]
      @server_address = server_address
      @data_files = {}
      data['files'].each do |key,files|
        if @data_files[key].nil?
          @data_files[key] = []
        end
        files.each do |file|
          @data_files[key] << DataFile.new(file, @server_address)
        end
      end
    end
    
    def get_url
      @server_address+@url
    end
    
    def to_s
      out_files = ""
      @data_files.each do |key, files|
        out_files += key+" : ["
        out_files += files.join(", ")
        out_files += "],  "
      end
      
      
      @name+" ("+@type+") - "+@get_url+" | "+@templates.join(", ") +" | FILES: "+out_files
    end
  end
end
