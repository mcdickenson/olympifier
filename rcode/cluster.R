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
athletes = athletes[-which(athletes$Sport=="Athletics"),]
athletes$sport.factor = as.factor(athletes$Sport)
athletes$event.factor = as.factor(athletes$FirstEvent)
length(unique(athletes$sport.factor))
sort(unique(athletes$sport.factor))


# set up training and test sets
features = c("Age", "Height", "Weight", "Female")
target = "sport.factor"
summary(athletes$kfold)
trnData = athletes[athletes$kfold <= 5, features]
tstData = athletes[athletes$kfold >  5, features]
trnClass = athletes[athletes$kfold <= 5, target]
tstClass = athletes[athletes$kfold >  5, target]
dim(trnData)
formula = sport.factor ~ Age + Height + Weight + Female

g = length(unique(tstClass))
clusterCounts = g

# check model
models = c("EII", "VII", "EEE", "VVV")
mclust = Mclust(trnData, G=g, modelNames=models)
summary(mclust) # optimal model according to BIC
# VII does well

as.character(g)
# VVV
hcVVVathletes = hc(modelName="VVV", data=trnData)
clVVV = hclass(hcVVVathletes, clusterCounts)
# classError(clVVV[,"2"], truth=athletes[, target])
# classError(clVVV[,"30"], truth=athletes[, target])
classError(clVVV[,as.character(g)], truth=trnClass)
# clPairs(data=trnData, classification=clVVV[,as.character(g)] )
# no errors for sport
hcVVVpred = predict(hcVVVathletes, )

# VII
hcVIIathletes = hc(modelName="VII", data=trnData)
clVII = hclass(hcVIIathletes, clusterCounts)
classError(clVII[,as.character(g)], truth=trnClass)
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
