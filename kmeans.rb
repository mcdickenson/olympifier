require 'k_means'

load('data_accessor.rb')

athletes  = DataAccessor.new nil, filename="data/athletes.tsv"; nil
trn_set, tst_set = athletes.two_subsets; nil

sports = trn_set.get_features(:sport).flatten.uniq

trn_examples = trn_set.get_features; nil
tst_examples = tst_set.get_features; nil

trn_kmeans = KMeans.new(trn_examples, centroids: sports.length)
tst_kmeans = KMeans.new(tst_examples, custom_centroids: trn_kmeans.centroids)

tst_assignments = tst_kmeans.instance_variable_get :@centroid_pockets

tst_classes = []
pred_labels = []

tst_assignments.each_with_index do |asn, i|
  asn.each do |j|
    pred_labels << sports[i]
    tst_classes << tst_set[j][:sport]
  end
end; nil
tst_set.check_accuracy(pred_labels, tst_classes)
