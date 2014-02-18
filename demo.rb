require 'csv'
require 'libsvm'

athletes = CSV.read("data/athletes.tsv", 
  col_sep: "\t", 
  headers: true, 
  header_converters: :symbol,
  converters: :integer); nil

# support vector machine: what sport do they play?

# boilerplate
problem   = Libsvm::Problem.new
parameter = Libsvm::SvmParameter.new

parameter.cache_size = 1 # in megabytes
parameter.eps = 0.001
parameter.c   = 10

# split data into training and test sets
training_set = athletes.values_at(0..999); nil
test_set     = athletes.values_at(1000..1009); nil 

# get a feel for the data
test_set.each do |row| 
  next unless row[:height_cm] and row[:weight]
  puts "#{row[:height_cm]}, #{row[:weight]}, #{row[:sport]}" 
end; nil


# clean up data
def examples_from(subset)
  examples = subset.map do |row| 
    next unless row[:height_cm] and row[:weight]
    Libsvm::Node.features([row[:height_cm], row[:weight]])
  end
  examples = examples.compact
end

def uniq_sports(subset)
  sports = subset.map do |row|
    next unless row[:height_cm] and row[:weight]
    row[:sport]
  end
  sports = sports.compact
  sports.uniq! 
end

def labels_from(subset, sports)
  labels = subset.map do |row|
    next unless row[:height_cm] and row[:weight]
    sports.index(row[:sport])
  end
  labels = labels.compact
end

def check_accuracy(actual, pred, sports)
  i = 0 
  actual.each do |row|
    next unless row[:height_cm] and row[:weight]
    p = pred[i]
    puts "Predicted: #{sports[p]}\tActual: #{row[:sport]}\t\tHeight: #{row[:height_cm]}\tWeight: #{row[:weight]}"
    i += 1
  end
end

sports         = uniq_sports training_set; nil
train_examples = examples_from training_set; nil
train_labels   = labels_from(training_set, sports); nil

test_examples = examples_from test_set; nil
test_labels   = labels_from(test_set, sports); nil

# train model
problem.set_examples(train_labels, train_examples)
model = Libsvm::Model.train(problem, parameter) # takes a little while

# test model 
# pred = model.predict(Libsvm::Node.features([170, 60]))
pred = test_examples.map do |example|
  model.predict(example)
end
# pred = model.predict(test_examples)

check_accuracy(test_set, pred, sports); nil


# todo: incorporate gender, age
# todo: predict event 

