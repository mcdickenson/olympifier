# set up workspace
rm(list=ls())
setwd('~/github/olympifier')
# install.packages('mclust', repo='http://cran.revolutionanalytics.com/')
library(mclust)
library(RColorBrewer)


# load data
athletes = read.csv('data/athletes-clean.csv', header=TRUE, as.is=TRUE)
dim(athletes)
head(athletes)
athletes$sport.factor = as.factor(athletes$Sport)
athletes$event.factor = as.factor(athletes$FirstEvent)
colors = rep(brewer.pal(7,"Set1"),times=4)

########################################
# pick which putcome we want to analyze
# MODE = "SPORT"
MODE = "EVENT"
########################################

# set features and target
features = c("Age", "Height", "Weight", "Female")

if(MODE=="SPORT"){
  target = "sport.factor"
  want = which(athletes$kfold==1 & athletes$Sport != "Athletics")
  clusterCounts = c(1:30)
} else {
  target = "event.factor"
  want = which(athletes$kfold==1)
  clusterCounts = c(20:30, 200:300)
}

data = athletes[want, features]
dim(data)
g = length(unique(athletes[want, target]))
g

# check model
models = c("EII", "VII", "EEE", "VVV")
mclust = Mclust(data, G=g, modelNames=models)
summary(mclust) # optimal model according to BIC
# VII does well

as.character(g)
# VVV
hcVVVathletes = hc(modelName="VVV", data=data)
clVVV = hclass(hcVVVathletes, clusterCounts)
# classError(clVVV[,"2"], truth=athletes[, target])
# classError(clVVV[,"30"], truth=athletes[, target])
classError(clVVV[,as.character(g)], truth=athletes[want, target])
clPairs(data=athletes[,features], classification=clVVV[,as.character(g)], colors=colors)
# no errors for sport

# VII
hcVIIathletes = hc(modelName="VII", data=data)
clVII = hclass(hcVIIathletes, clusterCounts)
classError(clVII[,as.character(g)], truth=athletes[, target])
clPairs(data=athletes[,features], classification=clVII[,as.character(g)], colors=colors)

# plots
if(MODE=="SPORT"){
  pdf("graphics/clVVV-sport.pdf")
    clPairs(data=athletes[,features], classification=clVVV[,as.character(g)], colors=colors)
  dev.off()

  pdf("graphics/clVII-sport.pdf")
    clPairs(data=athletes[,features], classification=clVII[,as.character(g)], colors=colors)
  dev.off()
} else {
  pdf("graphics/clVVV-event.pdf")
    clPairs(data=athletes[,features], classification=clVVV[,as.character(g)], colors=colors)
  dev.off()

  pdf("graphics/clVII-event.pdf")
    clPairs(data=athletes[,features], classification=clVII[,as.character(g)], colors=colors)
  dev.off()
}


# results:
# hcVII does at least as well as hcVVV
