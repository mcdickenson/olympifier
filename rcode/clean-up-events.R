# set up workspace
setwd('~/github/olympifier')
# install.packages('mclust', repo='http://cran.revolutionanalytics.com/')
library(mclust)
library(RColorBrewer)


# load data
athletes = read.csv('data/athletes-mod.csv', header=TRUE, as.is=TRUE)
dim(athletes)
head(athletes)

sort(unique(athletes$Event))

# take out all dressage related, which label with horse name
notwant = which(grepl("Dressage", athletes$Event))
notwant = c(which(grepl("Eventing", athletes$Event)), notwant)
notwant = c(which(grepl("Jumping", athletes$Event)), notwant)

dim(athletes)
athletes = athletes[-notwant, c(1:12)]
dim(athletes)

# split on comma and take first event
athletes$FirstEvent = sapply(strsplit(athletes$Event, ","), "[[", 1) 
length(unique(athletes$FirstEvent))
sort(unique(athletes$FirstEvent))

names(athletes)
head(athletes)

# rerun kfold columns
nums = rep(1:10, times=ceiling(nrow(athletes)/10))
athletes$kfold = sample(nums)[1:nrow(athletes)]


write.csv(athletes, file="data/athletes-clean.csv", row.names=FALSE)
