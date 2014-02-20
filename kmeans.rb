require 'csv'
require 'k_means'

load('data_accessor.rb')

athletes  = DataAccessor.new nil, filename="data/athletes.tsv"
train_set = DataAccessor.new athletes[0..999]; nil
test_set  = DataAccessor.new athletes[1000..1009]; nil
sports    = train_set.uniq_sports

train_examples = train_set.get_features; nil
test_examples  = test_set.get_features; nil


kmeans = KMeans.new(train_examples, centroids: sports.length)
