require 'csv'

class DataAccessor
  attr_reader :data

  def initialize(subset, filename=nil)
    subset ||= CSV.read(filename, 
      col_sep: "\t", 
      headers: true, 
      header_converters: :symbol,
      converters: :integer).map{|r| r.to_hash}
    @data = subset
    @features = [:height_cm, :weight]
  end

  def [](i)
    @data.values_at(i)
  end

  # todo: delegate first and last, maybe by extending enumerable
  def first
    @data[0].to_hash
  end

  def has_features(row, *args)
    args = @features if args.empty?
    args.flatten.all? { |i| !row[i].nil?}
  end

  def get_features(*args)
    args = @features if args.empty?
    @data.map { |row| args.each_with_object([]){ |f, x| x << row[f] if has_features(row) }}.reject(&:empty?)
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
  
end