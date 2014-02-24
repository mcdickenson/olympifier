require 'k_means'

load('data_accessor.rb')

athletes  = DataAccessor.new nil, filename="data/athletes.tsv"; nil
trn_set, tst_set = athletes.two_subsets; nil

sports = trn_set.get_features(:sport).flatten.uniq

trn_examples = trn_set.get_features; nil
tst_examples = tst_set.get_features; nil

trn_kmeans = KMeans.new(trn_examples, centroids: sports.length)
tst_kmeans = KMeans.new(tst_examples, custom_centroids: trn_kmeans.centroids)

# check clusterfications
tst_assignments = tst_kmeans.instance_variable_get :@centroid_pockets
tst_assignments.each_with_index do |asn, i|
  if asn.empty?
    puts "no observations classified as #{sports[i]}"
  else
    puts "#{asn.length} observations classified as #{sports[i]}"
    # asn.each {|j| puts tst_set[j][:sport] }; nil
    actual = asn.map {|j| tst_set[j][:sport]}
    # puts actual
    actual.uniq do |act|
      puts "\t #{actual.count(act)} are #{act}"
    end
  end
end; nil
