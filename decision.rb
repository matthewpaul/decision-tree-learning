puts "Attempting to read " + ARGV.first

File.open(ARGV.first, 'r') do |f1|
	while line = f1.gets
		puts line
	end
end

lines = 0

# Count the number of lines in the file, split each line, and separate into features and outcomes
File.open(ARGV.first, 'r') do |f|
	while line = f.gets
		featureArray = line.split(",")
		featureArray.last.delete!("\n")
		# remove whitespace from features
		featureArray.each do |feature|
			feature.lstrip!
		end
		feature_values = featureArray.map(&:to_i)
		puts feature_values.to_s
		lines += 1
	end
end

puts "There are " + lines.to_s + " sets of data in this file."