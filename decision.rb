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

class ExampleSet
	def initialize(examples)
		@examples = examples
		@positives = 0
		@negatives = 0
	end

	def examples
		@examples 
	end

	def examples=(value)
		@examples = value
	end

	def positives
		@positives
	end

	def positives=(value)
		@positives = value
	end

	def negatives
		@negatives
	end

	def negatives=(value)
		@negatives = value
	end

	def calculate
		self.examples.each do |e|
			if e.outcome == true
				self.positives += 1
			else self.negatives += 1
			end
		end
	end

	def to_s
		puts "[Positives: " + self.positives.to_s + "][Negatives: " + self.negatives.to_s + "]"
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
initialSet = nil
# Count the number of lines in the file, split each line, and separate into features and outcomes
File.open(ARGV.first, 'r') do |f|
	exampleArray = Array.new
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
		exampleArray.push(example)
		lines += 1
	end
	initialSet = ExampleSet.new(exampleArray)
end

initialSet.calculate
initialSet.to_s






















