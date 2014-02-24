require 'decisiontree'
load('data_accessor.rb')


def dtree(percent=0.9)

  athletes  = DataAccessor.new nil, filename="data/athletes.tsv", features=[:height_cm, :weight, :sport]
  trn_set, tst_set = athletes.two_subsets

  trn_examples, tst_examples = trn_set.get_features, tst_set.get_features

  dtree = DecisionTree::ID3Tree.new ['height', 'weight'], trn_examples, "Athletics", :discrete
  dtree.train

  tst_classes = tst_examples.map{|x| x.last}
  pred_labels = tst_examples.each_with_object([]) { |t,a| a << dtree.predict(t) }

  acc = tst_set.check_accuracy(pred_labels, tst_classes)
end
