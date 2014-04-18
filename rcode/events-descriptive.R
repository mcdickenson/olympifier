# set up workspace
rm(list=ls())
setwd('~/github/olympifier')

# load data
athletes = read.csv('data/athletes-clean.csv', header=TRUE, as.is=TRUE)
dim(athletes)
head(athletes)
athletes = athletes[which(athletes$Sport=="Athletics"),]
athletes$sport.factor = as.factor(athletes$Sport)
athletes$event.factor = as.factor(athletes$FirstEvent)
length(unique(athletes$event.factor))
sort(unique(athletes$event.factor))


# set up training and test sets
features = c("Age", "Height", "Weight", "Female")
target = "event.factor"
summary(athletes$kfold)
trnData = athletes[athletes$kfold <= 5, features]
tstData = athletes[athletes$kfold >  5, features]
trnClass = athletes[athletes$kfold <= 5, target]
tstClass = athletes[athletes$kfold >  5, target]
# some models need it this way:
formula = event.factor ~ Age + Height + Weight + Female
data = cbind(trnData, trnClass)


# descriptive stats
# todo: plot well-differentiated
#       and poorly-differentiated events
plot(athletes$Weight, athletes$Height,
  col=athletes$event.factor)

# colors = c("#e41a1c", "#377eb8", "#4daf4a", "#984ea3")
# players$color = NA 
# for(i in 1:length(colors)){
#   league = leagues[i]
#   color = colors[i]
#   players$color = ifelse(players$league==league, color, players$color)
# }

# pdf("graphics/players-descriptive.pdf")
# plot(jitter(players$weight), jitter(players$height),
#   col=players$color, pch=16,
#   xlab="Weight (kg)",
#   ylab="Height (cm)")
# legend('topleft', 
#   legend=c("Australian Football", "A-League Football", "National Rugby", "Super Rugby"), 
#   col=colors, pch=16)
# dev.off()