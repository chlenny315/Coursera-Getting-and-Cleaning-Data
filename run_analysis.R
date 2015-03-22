## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(data.table)
library(reshape2)
library(plyr)


## Step 1 
## Merges the training and the test sets to create one data set.
##########################################################################################
# url of the dataset
URL <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
# root directory of the dataset
DIR <- 'UCI HAR Dataset'
# output filenames
TIDY_FILENAME <- 'tidy.txt'
AGGREGATED_FILENAME <- 'aggregated.txt'

if (!file.exists(DIR)) {
      message("No data set in wd. Downloading")
      download.file(URL, 'dataset.zip', 'curl')
      unzip('dataset.zip')
}

message('Reading data...')

x.train <- read.table(file.path(DIR, 'train', 'X_train.txt'))
y.train <- read.table(file.path(DIR, 'train', 'y_train.txt'))
subj.train <- read.table(file.path(DIR, 'train', 'subject_train.txt'))
x.test <- read.table(file.path(DIR, 'test', 'X_test.txt'))
y.test <- read.table(file.path(DIR, 'test', 'y_test.txt'))
subj.test <- read.table(file.path(DIR, 'test', 'subject_test.txt'))
features <- read.table(file.path(DIR, 'features.txt'))
activities <- read.table(file.path(DIR, 'activity_labels.txt'))

message('Reading data is finished.')

# Create x, y, subject dataset
message('Binding train and test datasets.')
x <- rbind(x.train, x.test)
y <- rbind(y.train, y.test)
subj <- rbind(subj.train, subj.test)


## Step 2 
## Extracts only the measurements on the mean and standard deviation for each measurement.
##########################################################################################

message('Extract mean and standard deviation.')

features.filter <- grep("-mean\\(\\)|-std\\(\\)",features[,2])
x <- x[,features.filter]
names(x) <- gsub("\\(|\\)","",tolower(features[features.filter, 2]))


## Step 3
## Use descriptive activity names to name the activities in the data set
##########################################################################################

message('Use descriptive activity names to name the activities in the data set.')

names(y) <- 'activity'
y[,1] <- activities[y[,1],2]

# Step 4
# Appropriately label the data set with descriptive variable names
###############################################################################

# Step 5
# Create a second, independent tidy data set with the average of each variable for each activity and each subject
###############################################################################

message('Creating tidy dataset.')
names(subj) <- 'subject'
tidy <- cbind(subj, y, x)

message('Aggregating tidy dataset variables by activity and subject.')
aggregated <- aggregate(tidy[3:68], by=list(subject = tidy$subject,activity = tidy$activity), FUN=mean)

message('Writing tidy datasets')
write.table(tidy, TIDY_FILENAME, row.names = FALSE)
write.table(aggregated, AGGREGATED_FILENAME, row.names = FALSE)
