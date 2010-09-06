# Fileclient
require 'uri'
require 'net/http'
require 'active_support'

require 'erb'
require 'digest'
require 'tempfile'
require 'app/models/fileclient/client'
require 'app/models/fileclient/upfile'
require 'app/models/fileclient/data_file'
require 'app/models/fileclient/generated_file'
require 'app/models/fileclient/template'
require 'app/models/fileclient/model_file'
require 'app/models/fileclient/iostream'
#require 'app/models/fileclient/callback_compatibility'
require 'app/models/fileclient'
require 'app/helpers/fileclient_helper'
include FileclientHelper 
/%w{ helpers }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end 
# The base module that gets included in ActiveRecord::Base
/