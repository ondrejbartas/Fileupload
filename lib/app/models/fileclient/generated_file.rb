module Fileclient
  class GeneratedFile

    def initialize(data, server_address) #get data in JSON
        @url = data["url"]
        @filename_current = data["filename_current"]
        @width = data["width"]
        @height = data["height"]
        @size = data["size"]
        @server_address = server_address
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


    def get_url
      @server_address+@url
    end

    def to_s
      @filename_current+" ("+@width.to_s+"x"+@height.to_s+")"
    end
  end
end
