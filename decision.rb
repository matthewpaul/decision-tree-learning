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

	def entropy 
		total = self.positives + self.negatives
		yes = self.positives.to_f/total
		no = self.negatives.to_f/total

		entropy = -(yes * Math::log(yes, 2)) - (no * Math::log(no, 2))
		return entropy
	end

	def to_s
		puts "[Positives: " + self.positives.to_s + "][Negatives: " + self.negatives.to_s + "]"
	end

end

puts "Attempting to read " + ARGV.first

########################## Initialize Program Variables Here #################################
# The user will need to specify the field of the outcome as the second argument to the program
# Outcome field indexing starts at 0
outcomeField = ARGV[1].to_i
lineNum = 0
positiveOutcome = nil
thisOutcome = nil
initialSet = nil



########################## Begin program code Here ###########################################
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

		featureValues = Array.new
		for i in 0..featureArray.size-1
			if (i == outcomeField) && (lineNum == 0)
				positiveOutcome = featureArray[i]
				thisOutcome = featureArray[i]
			elsif (i == outcomeField)
				thisOutcome = featureArray[i]
			else 
				featureValues.push(featureArray[i].to_i) 
			end
		end
		puts featureValues.to_s
		example = Example.new(featureValues)
		example.classify(positiveOutcome, thisOutcome)
		exampleArray.push(example)
		lineNum += 1
	end
	initialSet = ExampleSet.new(exampleArray)
end

initialSet.calculate
initialSet.to_s
puts "Initial set entropy = " + initialSet.entropy.to_s






















