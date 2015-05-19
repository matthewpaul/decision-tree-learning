require 'csv'

$recursiveCalls = 0

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

	def to_s
		puts self.features.to_s
		puts self.outcome.to_s
	end
end

class ExampleSet
	def initialize(examples)
		@examples = examples
		@featureCount = 0
		@tally = Hash.new
	end

	def examples
		@examples 
	end

	def examples=(value)
		@examples = value
	end

	def tally
		@tally
	end

	def tally=(value)
		@tally = value
	end

	def featureCount
		@featureCount
	end

	def featureCount=(value)
		@featureCount = value
	end

	def calculate
		possibleOutcomes = Array.new
		self.examples.each do |e|
			possibleOutcomes.push(e.outcome)
		end
		possibleOutcomes.uniq!
		possibleOutcomes.each do |o|
			self.tally[o] = 0
		end
		self.examples.each do |e|
			self.tally[e.outcome] += 1
		end
		self.featureCount = self.examples.first.features.size
	end

	def freq(outcome)
		total = 0
		self.tally.each_value {|value| total += value}
		return self.tally[outcome] / total.to_f
	end

	def info
		total = 0
		info = 0
		self.tally.each_value {|value| total += value}
		self.tally.each_key {|key| info += ((self.freq(key)/total) * Math::log(self.freq(key)/total, 2))}
		if info.nan?
			return 0
		else 
			return -info
		end
	end

	def featureInfo(feature)
		#features is used to calculate the number of different attributes
		features = Array.new
		#groups is an array used to store the results of splitting on each attribute
		groups = Array.new
		self.examples.each do |e|
			features.push(e.features[feature])
		end
		features.uniq!
		features.each do |f|
			#create a new example set that matches this feature attribute
			examples = Array.new
			self.examples.each do |example|
				if example.features[feature] == f
					examples.push(example)
				end
			end
			if examples != nil
				currentExampleSet = ExampleSet.new(examples)
				groups.push(currentExampleSet)
			end
		end
		info = 0
		numExamples = 0
		groups.each do |item|
			item.calculate
			item.tally.each_value {|value| numExamples += value}
		end
		groups.each do |i|
			total = 0
			i.tally.each_value {|value| total += value}
			info += (total.to_f / numExamples) * i.info
		end
		return info
	end

	# Feature is an integer defining which feature to calculate
	# information gain for
	def gain(feature)
		return self.info - self.featureInfo(feature)
	end

	# Returns a boolean value that determines whether the example set contains values of 
	# only one type of outcome. 
	def pure? 
		outcomes = Array.new
		self.examples.each do |e|
			outcomes.push(e.outcome)
		end
		outcomes.uniq!
		if outcomes.size == 1
			return true
		else 
			return false
		end
	end

	# Determines the best feature to split on based on finding
	# the feature with the most information gain
	def splitOn?
		maxGain = 0
		bestFeature = nil
		for i in 0..self.featureCount-1
			gain = self.gain(i)
			if gain >= maxGain
				maxGain = gain
				bestFeature = i
			end
		end
		if maxGain == 0
			bestFeature = rand(0..self.featureCount-1)
		end
		return bestFeature
	end

	def getValues(field)
		values = Array.new
		self.examples.each do |e|
			values.push(e.features[field])
		end
		values.uniq!
		return values
	end

	# returns a portion of the set that has a matching value at the given 
	# field
	def giveMe(field, value)
		examples = Array.new
		self.examples.each do |e|
			if e.features[field] == value
				examples.push(e)
			end
		end
		set = ExampleSet.new(examples)
		set.calculate
		return set
	end

	def to_s
		self.tally.each {|key, value| puts key.to_s + " ** " + value.to_s }
	end

end


class DecisionTreeNode
	def initialize(field, outcome, exampleHash)
		@field = field
		@outcome = outcome
		@splitOnSoFar = Array.new
		@exampleHash = exampleHash
	end

	def field
		@field
	end

	def outcome
		@outcome
	end

	def exampleHash
		@exampleHash
	end

	def field=(value)
		@field = value
	end

	def outcome=(value)
		@outcome = value
	end

	def exampleHash=(value)
		@exampleHash=(value)
	end

	def to_s
		puts "-------------------"
		if field != nil 
			puts "Attr: " + field.to_s
		end
		if outcome != nil
			puts "Outcome: " + outcome.to_s
		end
		puts "-------------------"
	end
end

def buildTree(set)
	$recursiveCalls += 1
	if set.examples.empty?
		node = DecisionTreeNode.new(nil, "Failure", nil)
		puts "failure"
		return node
	elsif set.pure?
		node = DecisionTreeNode.new(nil, set.examples.first.outcome, nil)
		puts "pure set"
		return node
	else 
		currentSplit = set.splitOn?
		puts "splitting on " + currentSplit.to_s
		hash = Hash.new
		branches = set.getValues(currentSplit)
		branches.each do |b|
			exampleSet = set.giveMe(currentSplit, b)
			hash[b] = buildTree(exampleSet)
		end
		node = DecisionTreeNode.new(currentSplit, nil, hash)
		return node
	end

end

def decide(node, example)
	if node != nil
		if node.outcome == "Failure"
			puts "Failed to Classify"
			return nil
		elsif node.field == nil
			example.outcome = node.outcome
			#puts "Decided: " + node.outcome.to_s
			return node.outcome
		else
			if node.exampleHash.has_key?(example.features[node.field])
				decide(node.exampleHash[example.features[node.field]], example)
			else
				puts "We'll need to make an estimate, no prior information about this one."
				return rand(0..9)
			end
		end
	else puts "nil node"
	end
end

# Will assume that the last value of each line is the actual intended outcome
# in order to determine the success of the tree
def analyzeTestSet(testFile, tree, outcomeField)
	correctCount = 0
	incorrectCount = 0

	CSV.foreach(testFile) do |row|
		outcome = nil
		featureValues = Array.new
		for i in 0..row.size-1
			if (i == outcomeField)
				outcome = row[i]
			else 
				featureValues.push(row[i].to_i) 
			end
		end
		example = Example.new(featureValues)
		example.outcome = outcome
		decision = decide(tree, example)
		if outcome.eql?(decision)
			puts "CORRECT: " + outcome.to_s + " " + decision.to_s 
			correctCount += 1
		else
			puts "INCORRECT"
			incorrectCount += 1
		end
	end
	percentage = (correctCount.to_f / (correctCount + incorrectCount))
	puts "Accuracy: " + percentage.to_s + " on test data"
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
exampleArray = Array.new
if File.extname(ARGV.first) == ".csv"
	CSV.foreach(ARGV.first) do |row|
		outcome = nil
		featureValues = Array.new
		for i in 0..row.size-1
			if (i == outcomeField)
				outcome = row[i]
			else 
				featureValues.push(row[i].to_i) 
			end
		end
		puts featureValues.to_s
		example = Example.new(featureValues)
		example.outcome = outcome
		exampleArray.push(example)
	end
	initialSet = ExampleSet.new(exampleArray)
else
	text = File.open(ARGV.first).read
	text.gsub!(/\r\n?/, "\n")
	text.each_line do |line|

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
puts "Initial set info = " + initialSet.info.to_s
bestFeature = initialSet.splitOn?
puts "Best feature = " + bestFeature.to_s + ", Gain: " + initialSet.gain(bestFeature).to_s
puts "*********** Building Tree *********"
tree = buildTree(initialSet)

puts "******** Making Decisions *********"
if ARGV.size > 3
	analyzeTestSet(ARGV[2], tree, ARGV[3].to_i)
elsif ARGV.size == 3
	puts "You'll need to specify test set location AND outcome field"
end
puts $recursiveCalls.to_s + " nodes in the tree"




















