require 'libsvm'

load('data_accessor.rb')

# set up problem (boilerplate)
problem   = Libsvm::Problem.new
parameter = Libsvm::SvmParameter.new

parameter.cache_size = 1
parameter.eps = 0.001
parameter.c   = 10

# split data into training and test sets
athletes  = DataAccessor.new nil, filename="data/athletes.tsv"; nil
train_set = DataAccessor.new athletes[0..999]; nil
test_set  = DataAccessor.new athletes[1000..1009]; nil
sports    = train_set.get_features(:sport).flatten.uniq

train_examples = train_set.get_features.map{ |row| Libsvm::Node.features(row) }; nil
test_examples  = test_set.get_features.map{ |row| Libsvm::Node.features(row) }; nil

train_labels = train_set.get_features(:sport).flatten.map{|row| sports.index(row)}; nil
test_labels  = test_set.get_features(:sport).flatten; nil

# train model
problem.set_examples(train_labels, train_examples)
model = Libsvm::Model.train(problem, parameter) # takes a little while

# test model 
pred = test_examples.map {|x| model.predict(x) }
pred_labels = pred.map{|x| sports[x]}

test_set.check_accuracy(pred_labels, test_labels)

# todo: incorporate gender, age
# todo: rename to distinguish between 'labels' and 'classes'