# set up workspace
rm(list=ls())
setwd('~/github/olympifier')
# library(cluster)
# install.packages('evtree', repo='http://cran.revolutionanalytics.com/')
library(evtree)
# install.packages('maptree', repo='http://cran.revolutionanalytics.com/')
# library(maptree)
# install.packages('oblique.tree', repo='http://cran.revolutionanalytics.com/')
# library(oblique.tree)
library(party)
# library(RColorBrewer)
library(randomForest)
# library(rpart)
# library(tree)


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

# party
data = cbind(trnData, trnClass)
names(data)[5] = target

sportCIT = ctree(formula, data=data )
save(sportCIT, file="rcode/sportCIT.rda")
load("rcode/sportCIT.rda")

# training set
trnPred = predict(sportCIT)
table(trnPred, trnClass)
1-mean(trnPred == trnClass)

# test set
tstPred = predict(sportCIT, newdata=tstData)
table(tstPred, tstClass)
1-mean(tstPred == tstClass)


# evtree
sportEV = evtree(formula, data=data)
save(sportEV, file="rcode/sportEV.rda")
load("rcode/sportEV.rda")

trnPred = predict(sportEV, trnData)
table(trnPred, trnClass)
1-mean(trnPred == trnClass)

tstPred = predict(sportEV, tstData)
table(tstPred, tstClass)
1-mean(tstPred == tstClass)

# randomForest
fit.rf = randomForest(formula, data=data)
sportRF = fit.rf

sportRF = randomForest(formula, data=data)
save(sportRF, file="rcode/sportRF.rda")
load("rcode/sportRF.rda")

trnPred = predict(sportRF, trnData)
table(trnPred, trnClass)
1-mean(trnPred == trnClass)

tstPred = predict(sportRF, tstData)
table(tstPred, tstClass)
1-mean(tstPred == tstClass)




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