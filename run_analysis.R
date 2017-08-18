# Load the required Packages
library(data.table)
library(reshape2)
library(dplyr)

# Cleanup the Environment
rm(list = ls())

#Download the dataset & Unzip
setwd("C:/Users/Seyed/Documents/Courses/Data Science, Python and R Courses/JHU 03 Getting and Cleaning Data")

if(!file.exists("./data"))
  {dir.create("./data")}

fileUrl <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, "./data/dataFiles.zip", mode = "wb")  # method = 'curl' behaves weirdly sometimes. wb is binary
unzip("./data/dataFiles.zip")

# Read the activity_labels and features dataset
# 'activity_labels.txt': Links the class labels with their activity name
# 'features.txt': List of all features

activityLabels <- fread("UCI HAR Dataset/activity_labels.txt", col.names = c("classLabel", "activityName"))
features <- fread("UCI HAR Dataset/features.txt", col.names = c("featureNumber", "featureName"))

# Extract only the measurements on the mean and standard deviation
featuresWanted <- grep("(mean|std)", features[, featureName])
measurements <- features[featuresWanted, featureName]
measurements <- gsub('[()]', '', measurements)  # remove the (), so they can be used as Col names


# Load training datasets for Activities and Subjects
training <- fread("UCI HAR Dataset/train/X_train.txt")
training <- select(training, featuresWanted)
setnames(training, colnames(training), measurements)

trainActivities <- fread("UCI HAR Dataset/train/Y_train.txt")
setnames(trainActivities,"V1","Activity") # V1 is the default column name

trainSubjects <- fread("UCI HAR Dataset/train/subject_train.txt")
setnames(trainSubjects,"V1","SubjectNumber") # V1 is the default column name

# Combine the datasets by Columns
training <- cbind(trainSubjects, trainActivities, training)

###   Now, let's load the test datasets

test <- fread("UCI HAR Dataset/test/X_test.txt")
test <- select(test, featuresWanted)
setnames(test, colnames(test), measurements)

testActivities <- fread("UCI HAR Dataset/test/Y_test.txt")
setnames(testActivities,"V1","Activity")

testSubjects <- fread("UCI HAR Dataset/test/subject_test.txt")
setnames(testSubjects,"V1","SubjectNumber")

# Combine the datasets by Columns
test <- cbind(testSubjects, testActivities, test)


### Last Steps. Combine the training and test datasets by Rows
combined <- rbind(training, test)

# Convert the numeric class Label to descriptive Activity Name. And factor these, before we can melt and cast
combined[["Activity"]] <- factor(combined[, Activity], levels = activityLabels[["classLabel"]], labels = activityLabels[["activityName"]])
combined[["SubjectNumber"]] <- as.factor(combined[, SubjectNumber])

# Create a tidy data set with the average of each variable for each activity and each subject
combined <- melt(combined, id = c("SubjectNumber", "Activity"))
combined <- dcast(combined, SubjectNumber + Activity ~ variable, fun.aggregate = mean)

# Please upload your data set as a txt file created with write.table() using row.name=FALSE
write.table(combined, "TidyDataSeyed.txt", row.names = FALSE, quote = FALSE)

