#### WS ####
rm(list=ls())
options(stringsAsFactors = FALSE)
library("plyr")
library("dplyr")
source("00_utils.R")

#### LOAD DATA ####
dtrn <- read.table("../data/train.csv", header = TRUE, sep = ",")

#### EXPLORING ####
df.summary(dtrn)

# NAs
AgeMedian <- median(dtrn$Age, na.rm = TRUE)
dtrn$Age[is.na(dtrn$Age)] <- AgeMedian

# Char # > 32
df.summary(dtrn) %>%
  filter(Class == "character") %>%
  filter(Uniques > 32)

dtrn$Ticket
dtrn$Cabin


### TRANSFORM
dtrn <- dtrn  %>% 
  mutate(CabinStart = substring(Cabin, 0, 1) %>% factor,
         Survived = as.factor(ifelse(Survived, "Y", "N")),
         Pclass = as.factor(Pclass)) %>%
   df.chr2factor

df.summary(dtrn) %>%
  filter(Class == "factor") %>%
  filter(Uniques > 32)


dtrnf <-  dtrn  %>% select(-Name, -Ticket, -Cabin)





#### DATA TEST ####
dtst <- read.table("../data/test.csv", header = TRUE, sep = ",")
dtst <- dtst  %>% 
  mutate(CabinStart = substring(Cabin, 0, 1) %>% factor(levels = levels(dtrn$CabinStart)),
         Pclass = as.factor(Pclass),
         Embarked = factor(Embarked, levels = levels(dtrn$Embarked))) %>%
  df.chr2factor

dtst$Age[is.na(dtst$Age)] <- AgeMedian
dtst$Fare[is.na(dtst$Fare)] <- median(dtrn$Fare, na.rm = TRUE)


dtrnf <- dtrn  %>% select(-Name, -Ticket, -Cabin)
dtstf <- dtst


#### TRANSFORMATIONS #####


#### EXPORT ####
save(dtrnf, dtstf, file = "../data/process_data.RData")



