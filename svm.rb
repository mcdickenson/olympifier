require 'libsvm'

load('data_accessor.rb')

# split data into training and test sets
athletes  = DataAccessor.new nil, filename="data/athletes.tsv"; nil
trn_set, tst_set = athletes.two_subsets(percent_in_first_subset=0.05); nil

sports = trn_set.get_features(:sport).flatten.uniq

trn_examples = trn_set.get_features.map{ |row| Libsvm::Node.features(row) }; nil
tst_examples = tst_set.get_features.map{ |row| Libsvm::Node.features(row) }; nil

trn_labels  = trn_set.get_features(:sport).flatten.map{|row| sports.index(row)}; nil
tst_classes = tst_set.get_features(:sport).flatten; nil

# set up problem (boilerplate)
problem   = Libsvm::Problem.new
parameter = Libsvm::SvmParameter.new

parameter.cache_size = 5
parameter.eps = 0.01
parameter.c   = 10

# train model
problem.set_examples(trn_labels, trn_examples)

start = Time.now
model = Libsvm::Model.train(problem, parameter) # takes a little while
puts "training svm on #{trn_set.length} examples took #{Time.now-start} seconds"

# test model 
pred = tst_examples.map {|x| model.predict(x) }
pred_labels = pred.map{|x| sports[x]}

acc = tst_set.check_accuracy(pred_labels, tst_classes)

puts "svm accuracy rate on #{tst_set.length} examples is #{acc}"

