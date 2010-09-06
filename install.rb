# Install hook code here
puts "Copying files..."
dir = "config"
["fileserver.yml"].each do |yml_file|
	dest_file = File.join(RAILS_ROOT, dir, yml_file)
	src_file = File.join(File.dirname(__FILE__) , 'lib', dir, yml_file)
	FileUtils.cp_r(src_file, dest_file)
end
puts "Files copied"

puts "Please change config file: "+File.join(RAILS_ROOT, dir, "fileserver.yml")