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


# set features and target
features = c("Age", "Height", "Weight", "Female")
target = "sport.factor"
# target = "event.factor"

# for classifying sport:
want = which(athletes$kfold==1 & athletes$Sport != "Athletics")
#
data = athletes[want, features]
dim(data)
g = length(unique(athletes[want, target]))
g

# check model
# mclust
clusterCounts = c(1:30)
# clusterCounts = c(20:30, 200:300)
# ?Mclust
models = c("EII", "VII", "EEE", "VVV")
# athletesBIC <- mclustBIC(athletes)
mclust = Mclust(data, G=g, modelNames=models)
summary(mclust) # optimal model according to BIC
# VII does well

# VVV
hcVVVathletes = hc(modelName="VVV", data=data)
# save(hcVVVathletes, file="rcode/hcVVVathletes.rda")
# load("rcode/hcVVVathletes.rda")
# summary(hcVVVathletes) # takes forever!
clVVV = hclass(hcVVVathletes, clusterCounts)
dim(clVVV)
# save(clVVV, file="rcode/clVVV.rda")
classError(clVVV[,"2"], truth=athletes[, target])
classError(clVVV[,"30"], truth=athletes[, target])
classError(clVVV[,as.character(g)], truth=athletes[, target])
clPairs(data=athletes[,features], classification=clVVV[,as.character(g)], colors=colors)
# no errors for sport

# VII
hcVIIathletes = hc(modelName="VII", data=data)
# save(hcVIIathletes, file="rcode/hcVIIathletes.rda")
# load("rcode/hcVIIathletes.rda")
# summary(hcVIIathletes) # takes forever!
clVII = hclass(hcVIIathletes, clusterCounts)
classError(clVII[,as.character(g)], truth=athletes[, target])
clPairs(data=athletes[,features], classification=clVII[,as.character(g)], colors=colors)

# plots
pdf("graphics/clVVV-sport.pdf")
clPairs(data=athletes[,features], classification=clVVV[,as.character(g)], colors=colors)
dev.off()

pdf("graphics/clVVV-event.pdf")
clPairs(data=athletes[,features], classification=clVVV[,as.character(g)], colors=colors)
dev.off()

pdf("graphics/clVII-sport.pdf")
clPairs(data=athletes[,features], classification=clVII[,as.character(g)], colors=colors)
dev.off()

pdf("graphics/clVII-event.pdf")
clPairs(data=athletes[,features], classification=clVII[,as.character(g)], colors=colors)
dev.off()

# results:
# hcVII does at least as well as hcVVV
# classifying sports has a .85 error rate for 27 clusters 
# classifying events has a .819 error rate for 714 clusters
# size of true clusters highly unequal: 66 pentathlon vs 1901 athletics
