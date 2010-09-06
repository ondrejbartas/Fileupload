# Uninstall hook code here

puts "Deleting files..."
dir = "config"
["fileupload.yml"].each do |yml_file|
  src_file = File.join(File.dirname(__FILE__) , 'lib', dir, yml_file)
  FileUtils.rm_r(src_file)
end
puts "Files deleted"

