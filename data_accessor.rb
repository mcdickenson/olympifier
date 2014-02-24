require 'csv'
require 'forwardable'

class DataAccessor
  include Enumerable
  extend Forwardable 
  def_delegators :@data, :first, :last, :each, :[], :length

  attr_reader :features, :data

  def initialize(subset, filename=nil, features=[:height_cm, :weight])
    subset ||= CSV.read(filename, 
      col_sep: "\t", 
      headers: true, 
      header_converters: :symbol,
      converters: :integer).map{|r| r.to_hash}
    @features = features.map{ |f| f.to_sym }
    @data = subset.to_a.map.reject{|k, v| @features.flatten.any? { |i| k[i].nil? } }.shuffle!(random: @seed)
    @seed = 8675309
  end

  def get_features(*args)
    args = @features if args.empty?
    @data.map { |row| args.each_with_object([]){ |f, x| x << row[f] }}
  end

  def examples_where(opts={})
    @data.map { |row| row if opts.keys.all? {|k| row[k] == opts[k]} }.reject(&:nil?)
  end

  def check_accuracy(pred, actual)
    accurate = 0 
    total = 0 
    pred.each_with_index do |p, i|
      accurate += 1 if actual[i] == p
      total += 1
    end
    accurate.to_f / total
  end

  def mean(*args)
    args.flatten.inject(&:+).to_f / args.flatten.length
  end

  def feature_means_by(target, *args)
    args = @features if args.empty?
    get_features(target).flatten.uniq.each_with_object({}) do |t, hsh|
      tx = DataAccessor.new examples_where({target => t})
      hsh[t] = args.each_with_object({}) { |a, hsh| hsh[a] = tx.mean(tx.get_features(a)) }
    end
  end

  def two_subsets(percent_in_first_subset=0.9)
    length1 = (@data.length * percent_in_first_subset.to_f).to_i
    [DataAccessor.new(@data[1..length1]), DataAccessor.new(@data[length1+1..-1])]
  end
  
end