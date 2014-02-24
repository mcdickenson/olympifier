require 'decisiontree'
load('data_accessor.rb')


def dtree(percent)

  athletes  = DataAccessor.new nil, filename="data/athletes.tsv"; nil
  trn_set, tst_set = athletes.two_subsets; nil

  attributes = ['height', 'weight']
  trn_examples = trn_set.get_features(:height_cm, :weight, :sport)
  tst_examples = tst_set.get_features(:height_cm, :weight, :sport)


  dtree = DecisionTree::ID3Tree.new attributes, trn_examples, "Athletics", :discrete

  start = Time.now
  dtree.train; nil
  t = Time.now-start

  tst_classes = []
  pred_labels = []
  tst_examples.each do |tst|
    tst_classes << tst.last
    pred_labels << dtree.predict(tst)
  end

  acc = tst_set.check_accuracy(pred_labels, tst_classes)
  {time: t, accuracy: acc}
end
