# set up workspace
rm(list=ls())
setwd('~/github/olympifier')
library(cluster)
# install.packages('evtree', repo='http://cran.revolutionanalytics.com/')
library(evtree)
# install.packages('maptree', repo='http://cran.revolutionanalytics.com/')
library(maptree)
# install.packages('oblique.tree', repo='http://cran.revolutionanalytics.com/')
library(oblique.tree)
library(party)
library(RColorBrewer)
library(randomForest)
library(rpart)
library(tree)


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
trnData = athletes[athletes$kfold <= 5, c(features, target)]
tstData = athletes[athletes$kfold >  5, features]
# trnClass = athletes[athletes$kfold <= 5, target]
# tstClass = athletes[athletes$kfold >  5, target]
dim(trnData)
formula = sport.factor ~ Age + Height + Weight + Female

# tree
tr = tree(formula, data=trnData)
summary(tr)
plot(tr)
text(tr)

# rpart
fit = rpart(formula, method="class", data=trnData)
printcp(fit)
plot(fit, uniform=TRUE)
text(fit, use.n=TRUE, all=TRUE, cex=0.8)

# party
(ct = ctree(formula, data=trnData))
plot(ct, main="Conditional Inference Tree")
# todo: prune this so the output is less ugly
# don't want p-values (if that's what they are)
table(predict(ct), trnData$sport.factor)
# todo: this would make a nice heatmap
tr.pred = predict(ct, newdata=tstData, type="prob")

# maptree
draw.tree(clip.rpart(rpart(trnData), best=7),
  nodeinfo=TRUE, units="sports",
  cases="athletes", digits=0)

# evtree
ev = evtree(formula, data=trnData)
plot(ev)
table(predict(ev), trnData$sport.factor)
1-mean(predict(ev)==trnData$sport.factor)
# todo: needs some pruning
# about 30% accuracy

# randomForest
fit.rf = randomForest(formula, data=trnData)

print(fit.rf)
# this could be interesting: which sports are easy to detect?
importance(fit.rf)
plot(fit.rf)
plot( importance(fit.rf), lty=2, pch=16)
lines(importance(fit.rf))
imp = importance(fit.rf)
impvar = rownames(imp)[order(imp[, 1], decreasing=TRUE)]
op = par(mfrow=c(1, 4))
for (i in seq_along(impvar)) {
  partialPlot(fit.rf, trnData, impvar[i], xlab=impvar[i],
  main=paste("Partial Dependence on", impvar[i]),
  ylim=c(0, 1))
}

# oblique.tree
ob.tree = oblique.tree(formula=formula, 
  data=trnData,
  oblique.splits="only")
plot(ob.tree)
text(ob.tree)