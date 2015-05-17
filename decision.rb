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
		print self.features.to_s + " "
		if self.outcome 
			puts "+"
		else
			puts "-"
		end
	end
end

class ExampleSet
	def initialize(examples)
		@examples = examples
		@featureCount = 0
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

	def featureCount
		@featureCount
	end

	def featureCount=(value)
		@featureCount = value
	end

	def calculate
		self.examples.each do |e|
			if e.outcome == true
				self.positives += 1
			else self.negatives += 1
			end
		end
		self.featureCount = self.examples.first.features.size
	end

	def entropy 
		total = self.positives + self.negatives
		yes = self.positives.to_f/total
		no = self.negatives.to_f/total

		entropy = -(yes * Math::log(yes, 2)) - (no * Math::log(no, 2))
		if entropy.nan?
			return 0
		else return entropy
		end
	end

	def featureEntropy(feature)
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
		entropy = 0
		numExamples = 0
		groups.each do |item|
			item.calculate
			numExamples += item.positives + item.negatives
		end
		groups.each do |i|
			total = i.positives + i.negatives
			probability = (total.to_f / numExamples)
			entropy = entropy + (i.entropy * probability)
		end
		return entropy
	end

	# Feature is an integer defining which feature to calculate
	# information gain for
	def gain(feature)
		return self.entropy - self.featureEntropy(feature)
	end

	# Returns a boolean value that determines whether the example set contains values of 
	# only one type of outcome. 
	def pure? 
		if self.positives == 0 && self.negatives != 0
			return true
		elsif self.negatives == 0 && self.positives != 0
			return true
		else return false
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
		puts "[Positives: " + self.positives.to_s + "][Negatives: " + self.negatives.to_s + "] {Entropy = " + self.entropy.to_s + "}"
		self.examples.each do |e|
			e.to_s
		end
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

	def splitOnSoFar
		@splitOnSoFar
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

	def splitOnSoFar=(value)
		@splitOnSoFar = value
	end
end

def buildTree(set)
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
	if node.outcome == "Failure"
		puts "Failed to Classify"
	elsif node.field == nil
		puts "Decided: " + node.outcome.to_s
	else
		decide(node.exampleHash[example.features[node.field]], example)
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
bestFeature = initialSet.splitOn?
puts "Best feature = " + bestFeature.to_s + ", Gain: " + initialSet.gain(bestFeature).to_s
tree = buildTree(initialSet)

# Testing the use of the decision tree
someFeatures = [0, 3, 5, 6]
classifyMe = Example.new(someFeatures)

decide(tree, classifyMe)



















