module Fileclient
  class Template
    def default_options(key)
      @default_options ||= {
        :name => "#{key}",
        :size => "50x50", 
        :name_prefix => "_#{key}",
        :resize_smaller => false,
        :resize_mode => "fit"
      }
    end
  end
end