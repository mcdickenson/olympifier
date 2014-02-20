require 'csv'

class DataAccessor
  attr_reader :data

  def initialize(subset, filename=nil)
    subset ||= CSV.read(filename, 
      col_sep: "\t", 
      headers: true, 
      header_converters: :symbol,
      converters: :integer)
    @data = subset
    @features = [:height_cm, :weight]
  end

  def [](i)
    @data.values_at(i)
  end

  def first
    @data[0]
  end

  def has_features(row, *args)
    args = @features if args.empty?
    args.flatten.all? { |i| !row[i].nil?}
  end

  def get_features(subset=@data, *args)
    args = @features if args.empty?
    subset.map { |row| args.each_with_object([]){ |f, x| x << row[f] if has_features(row) }}.reject(&:empty?)
  end

  def examples_where(subset=@data, opts={})
    subset.map { |row| row if opts.keys.all? {|k| row[k] == opts[k]} }.reject(&:nil?)
  end

  def uniq_sports(subset=@data)
    sports = subset.map { |row| row[:sport] if has_features(row) }.reject(&:nil?).compact.uniq
  end

  def mean(*args)
    args.flatten.inject(&:+).to_f / args.flatten.length
  end
  
end