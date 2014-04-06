# install.packages('mclust', repo='http://cran.revolutionanalytics.com/')
library(mclust)

clPairs(data=iris[,-5], classification=iris[,5])
hcVVViris <- hc(modelName = "VVV", data = iris[,-5])
cl <- hclass(hcVVViris, 2:3)
clPairs(data = iris[,-5], classification = cl[,"2"])
clPairs(data = iris[,-5], classification = cl[,"3"])
classError(cl[,"3"], truth = iris[,5])

