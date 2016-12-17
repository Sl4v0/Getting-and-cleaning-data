# Getting-and-cleaning-data - peer graded project details
##Peer-graded Assignment: Getting and Cleaning Data Course Project

>The purpose of this project is to demonstrate the ability to collect, work with, and clean a data set.

>The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

>One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

>http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

>Here are the data for the project:

>https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

>You should create one R script called run_analysis.R that does the following.

>Merges the training and the test sets to create one data set.
Extracts only the measurements on the mean and standard deviation for each measurement.
Uses descriptive activity names to name the activities in the data set
Appropriately labels the data set with descriptive variable names.
From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#Details behind 'run_analysis.R' script

The script doesn't need any data to be prepared prior to running it. It connects over internet, downloads and unzips the data set in a /data folder that it creates prior to cleaning up the data
```
## create the directory for the data
if(!file.exists("./data")){dir.create("./data")}

## download the data file
fileURL <-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile="./data/UCI_HAR_Dataset.zip")

## unzip data files into the /data directory
unzip(zipfile="./data/UCI_HAR_Dataset.zip",exdir="./data")
```
Once the data is downloaded and extracted it first reads **features.txt** to use its contents to name columns during importing of data from files into variables
```
## read features table to name columns during reading the test and train data
features <- read.table("./data/UCI HAR Dataset/features.txt")
```

Data files are being read into variables and columns are named per the tidy data set requirements during the process
``` 
## read test .txt data files into table variables in parallel naming columns
x_test<-read.table("./data/UCI HAR Dataset/test/X_test.txt", col.names = features$V2)
y_test<-read.table("./data/UCI HAR Dataset/test/y_test.txt", col.names = "activityID")
subject_test<-read.table("./data/UCI HAR Dataset/test/subject_test.txt", col.names="subjectID")

## read train .txt data files into table variables in parallel naming columns
x_train <-read.table("./data/UCI HAR Dataset/train/X_train.txt", col.names = features$V2)
y_train <-read.table("./data/UCI HAR Dataset/train/y_train.txt", col.names = "activityID")
subject_train <-read.table("./data/UCI HAR Dataset/train/subject_train.txt", col.names="subjectID")

## read activity labels to match with activity ID - requirement for a tidy data set
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt", col.names = c("activityID", "activityType"))
```
The script keeps only measurements that are either a mean or standard deviation matching them in column names
``` 
## Extract only the measurements on the mean and standard deviation for each measurement
test_mean_std <- x_test[grep("mean()|std()", colnames(x_test))]
train_mean_std <- x_train[grep("mean()|std()", colnames(x_train))]
``` 
Then 2 separate data sets are created - one for test subjects, one for train subjects - by merging columns from measurement, activity and subject data sets  
```
## Add Activity ID and Subject ID as columns to the data set (separately for test and train)
train_set<- cbind(subject_train, y_train, train_mean_std)
test_set<- cbind(subject_test, y_test, test_mean_std)
``` 
Finally a data set is created that row binds/merges the 2 previous data sets for train and test subjects and the activity numbers are converted to factor variables and human readable labels ('Walking', 'Sitting', 'Standing' etc.) - to fulfill the last requirement for the tidy data set
```
## merge the test and train data sets across common columns
merged_set <- merge(train_set, test_set, all=TRUE)

## Change activity ID to names - tidy set requirement, human readable format, factor type
merged_set$activityID = factor(merged_set$activityID, labels = activity_labels$activityType)
```
As a last step an independent data set averaging each measurement variable for each combilnation of activity and subject ID is created and written to output file called **tidy_set.txt**
```
## Create a second, independent tidy data set with the average of 
## each variable for each activity and each subject
tidy_set <- aggregate(. ~subjectID + activityID, merged_set,mean)

## write the tidy data set to a file
write.table(tidy_set, "tidy_set.txt", row.name=FALSE)
```
