require 'libsvm'
load('data_accessor.rb')

def svm(percent)
  # split data into training and test sets
  athletes  = DataAccessor.new nil, filename="data/athletes.tsv"; nil
  trn_set, tst_set = athletes.two_subsets(percent_in_first_subset=0.05); nil

  sports = trn_set.get_features(:sport).flatten.uniq

  trn_examples = trn_set.get_features.map{ |row| Libsvm::Node.features(row) }; nil
  tst_examples = tst_set.get_features.map{ |row| Libsvm::Node.features(row) }; nil

  trn_labels  = trn_set.get_features(:sport).flatten.map{|row| sports.index(row)}; nil
  tst_classes = tst_set.get_features(:sport).flatten; nil

  problem   = Libsvm::Problem.new
  parameter = Libsvm::SvmParameter.new
  parameter.cache_size = 5
  parameter.eps = 0.01
  parameter.c   = 10

  # train model
  problem.set_examples(trn_labels, trn_examples)
  start = Time.now
  model = Libsvm::Model.train(problem, parameter) # takes a little while
  t = Time.now-start

  # test model 
  pred = tst_examples.map {|x| model.predict(x) }
  pred_labels = pred.map{|x| sports[x]}

  acc = tst_set.check_accuracy(pred_labels, tst_classes)
  {time: t, accuracy: acc}
end
