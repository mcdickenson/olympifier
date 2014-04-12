# set up workspace
setwd('~/github/olympifier')
# install.packages('mclust', repo='http://cran.revolutionanalytics.com/')
library(mclust)
library(RColorBrewer)


# load data
athletes = read.csv('data/athletes-mod.csv', header=TRUE, as.is=TRUE)
dim(athletes)
head(athletes)
class(athletes$Female)
athletes$sport.factor = as.factor(athletes$Sport)
athletes$event.factor = as.factor(athletes$Event)
colors = rep(brewer.pal(7,"Set1"),times=4)


# set features and target
features = c("Age", "Height", "Weight", "Female")
# target = "Sport"
# target = "Event"
target = "event.factor"
# todo: may need to exclude "(Other)"
# todo: may need some add'l cleanups (dressage, etc)

want = which(athletes$kfold1!=0)
data = athletes[want, features]
dim(data)
g = length(unique(athletes[want, target]))

# check model

# mclust
clusterCounts = c(20:30, 700:750)
# ?Mclust
models = c("EII", "VII", "EEE", "VVV")
# athletesBIC <- mclustBIC(athletes)
mclust = Mclust(data, G=g, modelNames=models)
summary(mclust) # optimal model according to BIC
# VII does well for classifying sports

# VVV
# hcVVVathletes = hc(modelName="VVV", data=athletes[, features])
# save(hcVVVathletes, file="rcode/hcVVVathletes.rda")
load("rcode/hcVVVathletes.rda")
# summary(hcVVVathletes) # takes forever!
clVVV = hclass(hcVVVathletes, clusterCounts)
# save(clVVV, file="rcode/clVVV.rda")
classError(clVVV[,"27"], truth=athletes[, target])  # sport
classError(clVVV[,"714"], truth=athletes[, target]) # event
clPairs(data=athletes[,features], classification=clVVV[,"27"], colors=colors)
clPairs(data=athletes[,features], classification=clVVV[,"714"], colors=colors)

# VII
# hcVIIathletes = hc(modelName="VII", data=data)
# save(hcVIIathletes, file="rcode/hcVIIathletes.rda")
load("rcode/hcVIIathletes.rda")
# summary(hcVIIathletes) # takes forever!
clVII = hclass(hcVIIathletes, clusterCounts)
classError(clVII[,"27"], truth=athletes[, target])  # sport
classError(clVII[,"714"], truth=athletes[, target]) # event
clPairs(data=athletes[,features], classification=clVII[,"27"], colors=colors)
clPairs(data=athletes[,features], classification=clVII[,"714"], colors=colors)


# plots
pdf("clVVV-sport.pdf")
clPairs(data=athletes[,features], classification=clVVV[,"27"], colors=colors)
dev.off()

pdf("clVVV-event.pdf")
clPairs(data=athletes[,features], classification=clVVV[,"714"], colors=colors)
dev.off()

pdf("clVII-sport.pdf")
clPairs(data=athletes[,features], classification=clVII[,"27"], colors=colors)
dev.off()

pdf("clVII-event.pdf")
clPairs(data=athletes[,features], classification=clVII[,"714"], colors=colors)
dev.off()

# results:
# hcVII does at least as well as hcVVV
# classifying sports has a .85 error rate for 27 clusters 
# classifying events has a .819 error rate for 714 clusters
# size of true clusters highly unequal: 66 pentathlon vs 1901 athletics
