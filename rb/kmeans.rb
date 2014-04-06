require 'k_means'
load('data_accessor.rb')

def kmeans(percent=0.9)
  athletes  = DataAccessor.new nil, filename="data/athletes.tsv"
  trn_set, tst_set = athletes.two_subsets(percent_in_first_subset=percent)

  sports = trn_set.get_features(:sport).flatten.uniq

  trn_examples, tst_examples = trn_set.get_features, tst_set.get_features

  trn_kmeans = KMeans.new(trn_examples, centroids: sports.length)
  tst_kmeans = KMeans.new(tst_examples, custom_centroids: trn_kmeans.centroids)
  tst_assignments = tst_kmeans.instance_variable_get :@centroid_pockets

  pred_labels = tst_assignments.each_with_index.with_object([]) { |(asn, i), labs|  asn.each { |j| labs << sports[i] } }
  acc = tst_set.check_accuracy(pred_labels)
end