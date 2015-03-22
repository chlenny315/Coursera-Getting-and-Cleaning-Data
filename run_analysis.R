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
# load train data
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# load test data
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

# Create x, y, subject dataset
data_x <- join(x_test, x_train)
data_y <- join(y_test, y_train)
data_subject <- join(subject_test, subject_train)

## Step 2 
## Extracts only the measurements on the mean and standard deviation for each measurement.
##########################################################################################

features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# extract only mean and std
mean_n_std_features <- grep("mean|std", features)

# subset mean and std columns
data_x <- data_x[, mean_n_std_features]

# change colume names
names(data_x) <- features[mean_n_std_features]

## Step 3
## Use descriptive activity names to name the activities in the data set
##########################################################################################

# load activity data
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# update values with correct activity names
data_y[, 1] <- activity_labels[data_y[, 1], 2]

# correct column name
names(data_y) <- "activity"

# Step 4
# Appropriately label the data set with descriptive variable names
###############################################################################

# correct column name
names(data_subject) <- "subject"
 
# cbind data in one data set
data_all <- cbind(data_x, data_y, data_subject)

# Step 5
# Create a second, independent tidy data set with the average of each variable for each activity and each subject
###############################################################################

# 66 <- 68 columns but last two (activity & subject)
averages_data <- ddply(data_all, .(subject, activity), function(x) colMeans(x[, 1:66]))

write.table(averages_data, "averages_data.txt", row.name=FALSE)
