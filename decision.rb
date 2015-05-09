require 'set'

class Example
	def initialize(features)
		@features = features
		@outcome = nil
	end

	def features
		@features
	end

	def features=(value)
		@features = value
	end

	def outcome
		@outcome
	end

	def outcome=(value)
		@outcome = value
	end

	# The classify method will take a positive outcome value
	# and classify example
	# outcomes based on this feature.
	def classify(positiveOutcome, thisOutcome)
		if thisOutcome == positiveOutcome
			self.outcome = true
		else self.outcome = false
		end
	end

	def to_s 
		puts self.features.to_s
		if self.outcome == true
			puts "Positive"
		else puts "Negative"
		end
	end
end

puts "Attempting to read " + ARGV.first

File.open(ARGV.first, 'r') do |f1|
	while line = f1.gets
		puts line
	end
end

lines = 0
positiveOutcome = nil
# Count the number of lines in the file, split each line, and separate into features and outcomes
File.open(ARGV.first, 'r') do |f|
	while line = f.gets
		featureArray = line.split(",")
		featureArray.last.delete!("\n")
		# remove whitespace from features
		featureArray.each do |feature|
			feature.lstrip!
		end
		featureValues = featureArray.map(&:to_i)

		# We use the first seen outcome value as the "positive" outcome
		# value even though it may not be the actual positive value. 
		# This allows the program to operate on arbitrary size and style
		# of data sets. 
		if lines == 0
			positiveOutcome = featureValues.last
		end
		example = Example.new(featureValues[0..featureValues.size-2])
		thisOutcome = featureValues.last
		example.classify(positiveOutcome, thisOutcome)
		example.to_s
		lines += 1
	end
end

puts "There are " + lines.to_s + " sets of data in this file."