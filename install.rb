# Install hook code here
puts "Copying files..."
dir = "config"
["fileupload.yml"].each do |yml_file|
	dest_file = File.join(RAILS_ROOT, dir, yml_file)
	src_file = File.join(File.dirname(__FILE__) , 'lib', dir, yml_file)
	FileUtils.cp_r(src_file, dest_file)
end
puts "Files copied"

puts "Please change config file: "+File.join(RAILS_ROOT, dir, "fileupload.yml")
puts "or get your config file on: http://fileserver.bartas.cz"