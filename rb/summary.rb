require 'csv'

load('dtree.rb')
load('kmeans.rb')
load('svm.rb')

n = 10 

CSV.open("summary.csv", "w") do |csv|
  csv << ["method", "time", "accuracy"]
  ["dtree", "kmeans", "svm"].each do |meth|
    (1..9).map{|x| x.to_f/10}.each do |p|
      cmd = "#{meth}(#{p})"
      puts cmd
      n.times do 
        start = Time.now
        acc = eval(cmd)
        t = Time.now - start
        csv << [meth, t, acc]
      end
    end
  end
end
