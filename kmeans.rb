require 'k_means'

load('data_accessor.rb')

athletes  = DataAccessor.new nil, filename="data/athletes.tsv"; nil
trn_set, tst_set = athletes.two_subsets; nil

sports = trn_set.get_features(:sport).flatten.uniq

trn_examples = trn_set.get_features; nil
tst_examples = tst_set.get_features; nil

kmeans = KMeans.new(trn_examples, centroids: sports.length)
kmeans.nodes.size
# kmeans.nodes
# kmeans.centroids

# todo: find the modal sport for each cluster

# todo: custom centroids for each sport
# set them on training set and use them on test set





# class CustomCentroid
#   attr_accessor :position
#   def initialize(position); @position = position; end
#   def reposition(nodes, centroid_positions); end
# end
# needs to have #position and #reposition methods

# custom_centroids = []
# 2.times { custom_centroids << CustomCentroid.new([1,1]) }