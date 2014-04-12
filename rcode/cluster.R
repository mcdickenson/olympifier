# set up workspace
setwd('~/github/olympifier')
library(mclust)

# load data
athletes = read.csv('data/athletes-mod.csv', header=TRUE, as.is=TRUE)
dim(athletes)
head(athletes)

# set features and target
features = c("Age", "Height", "Weight")
target = "Sport"
# target = "Event"


# check model
# ?Mclust
# athletesBIC <- mclustBIC(athletes)
# mclust = Mclust(athletes[, features], G=3)
# mclust = Mclust(athletes[, features], modelNames=c("VVV"))
# summary(mclust) # optimal model according to BIC


# hcVVVathletes = hc(modelName="VVV", data=athletes[, features])
# save(hcVVVathletes, file="rcode/hcVVVathletes.rda")
load("rcode/hcVVVathletes.rda")
plot(hcVVVathletes)
# summary(hcVVVathletes) # takes forever!

cl = hclass(hcVVVathletes)
# save(cl, file="rcode/cl.rda")

# hcVVViris <- hc(modelName = "VVV", data = iris[,-5])
# cl <- hclass(hcVVViris, 2:3)
# classError(cl[,"1"], truth = iris[,5])
# classError(cl[,"2"], truth = iris[,5])
# classError(cl[,"3"], truth = iris[,5])