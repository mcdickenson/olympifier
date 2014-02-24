require 'libsvm'
load('data_accessor.rb')

def svm(percent)
  athletes  = DataAccessor.new nil, filename="data/athletes.tsv"
  trn_set, tst_set = athletes.two_subsets(percent_in_first_subset=0.05)

  sports = trn_set.get_features(:sport).flatten.uniq

  trn_examples = trn_set.get_features.map{ |row| Libsvm::Node.features(row) }
  tst_examples = tst_set.get_features.map{ |row| Libsvm::Node.features(row) }
  trn_labels  = trn_set.get_features(:sport).flatten.map{|row| sports.index(row)}

  model = train_svm(trn_labels, trn_examples)
  pred_labels = tst_examples.map {|x| model.predict(x) }.map{|x| sports[x] }

  acc = tst_set.check_accuracy(pred_labels)
end

def train_svm(labels, examples)
  problem   = Libsvm::Problem.new
  parameter = Libsvm::SvmParameter.new
  parameter.cache_size = 5
  parameter.eps = 0.01
  parameter.c   = 10

  problem.set_examples(labels, examples)
  Libsvm::Model.train(problem, parameter)
end
