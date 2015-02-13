#### WS ####
rm(list=ls())
options(stringsAsFactors = FALSE)
library("plyr")
library("dplyr")
library("stringr")
library("ggplot2")
source("00_utils.R")

#### LOAD DATA ####
train <- read.table("../data/train.csv", header = TRUE, sep = ",")
test <- read.table("../data/test.csv", header = TRUE, sep = ",")

#### EXPLORING ####
df.summary(train)
df.summary(test)

data <- rbind.fill(train, test)

table(addNA(data$Survived))
head(data)
str(data)


#### VARIABLES ####

# Engineered variable: Title
data$Title <- laply(data$Name, function(x) {strsplit(x, split="[,.]")[[1]][2]})
data$Title <- str_trim(data$Title)
# Combine small title groups
data$Title[data$Title %in% c("Mme", "Mlle")] <- "Mlle"
data$Title[data$Title %in% c("Capt", "Don", "Major", "Sir")] <- "Sir"
data$Title[data$Title %in% c("Dona", "Lady", "the Countess", "Jonkheer")] <- "Lady"

# Engineered variable: Family size
data$FamilySize <- data$SibSp + data$Parch + 1

data$SibParch <- (data$SibSp+1)/(data$Parch + 1)


# Engineered variable: Family
data$Surname <- laply(data$Name, function(x) {strsplit(x, split='[,.]')[[1]][1]})
data$FamilyID <- paste(as.character(data$FamilySize), data$Surname, sep="")
data$FamilyID[data$FamilySize <= 2] <- "Small"

# Delete erroneous family IDs
famIDs <- data.frame(table(data$FamilyID))
famIDs <- famIDs[famIDs$Freq <= 3,]
data$FamilyID[data$FamilyID %in% famIDs$Var1] <- "Small"
# Convert to a factor



# Fill in Age NAs
summary(data$Age)
Agefit <- rpart(Age ~ Pclass + Sex + SibSp + Parch +
                  Embarked + Title + FamilySize, 
                data=data[!is.na(data$Age),], method="anova")

data$Age[is.na(data$Age)] <- predict(Agefit, data[is.na(data$Age),])
summary(data$Age)

data$Log_Age <- log(data$Age)

# Fill in Fare NAs
summary(data$Fare)
data$Fare[is.na(data$Fare)] <- median(data$Fare, na.rm = TRUE)

data$Fare2 <- 0
#calculate Fare per person
for (t in unique(data$Ticket)) {
  who <- which(data$Ticket==t)
  data$Fare2[who] <- data$Fare[who[1]]/length(who)
}



# Fill in Embarked blanks
summary(data$Embarked)
data$Embarked[c(which(data$Embarked == ""))] = "S"



data$Ticket2 <- substr(gsub("[][!#$%()*,.:;<=>@^_`|~.{} ]", "", as.character(data$Ticket)), 1, 1)




# Sector
data$Sector <- substr(data$Cabin, 1, 1)

#### EXPORT ####
data <- data %>% 
  mutate(Pclass = factor(Pclass)) %>%
  df.chr2factor %>%
  select(-Name, -Ticket, -Surname, -Cabin)

str(data)

save(data, file = "../data/process_data.RData")



