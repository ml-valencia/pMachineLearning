---
title: "Prediction Assignment Writeup"
author: "M L Valencia"
date: "August 13, 2019"
output: html_document
---

```{r include=FALSE}
knitr::opts_chunk$set(comment = NA)
```

##Background
Using devices such as Jawbone Up, Nike FuelBand, and Fitbit it is now possible to collect a large amount of data about personal activity relatively inexpensively. These type of devices are part of the quantified self movement - a group of enthusiasts who take measurements about themselves regularly to improve their health, to find patterns in their behavior, or because they are tech geeks. One thing that people regularly do is quantify how much of a particular activity they do, but they rarely quantify how well they do it. In this project, your goal will be to use data from accelerometers on the belt, forearm, arm, and dumbell of 6 participants. They were asked to perform barbell lifts correctly and incorrectly in 5 different ways. More information is available from the website [here.](http://groupware.les.inf.puc-rio.br/har)

###Data
The **training** data for this project are available [here.](https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv) and the **test** data are available [here.](https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv)

##Methodology Discussion

###Loading Data and Libraries
```{r message=FALSE, warning=FALSE,results='hide'}
library(caret)
library(randomForest)

training<-read.csv("pml-training.csv")
testing<-read.csv("pml-testing.csv")

```

###Data Exploration, Sampling, and Preprocessing
The dimensions and the contents of the data were explored (results are hidden), to help gain insight on the data.
```{r results='hide'}
dim(training)
dim(testing)

head(training)
head(testing)
```

A summary of the target classes.
```{r}
summary(training$classe)
```

####Splitting into Training and Validation Set
The original training set is split into 70-30 training-validation set, to help in cross validation.
```{r}
set.seed(212)
sample1<-createDataPartition(y=training$classe,p=0.7,list=FALSE)
train1<-training[sample1,]
valid1<-training[-sample1,]
```

####Removing columns with mostly NAs and Null Values
Initially, the columns with mostly NA values were removed in the training set. Then, the columns with null values were then removed. Finally, prior to modeling, the irrelevant columns for prediction such as *user_name, raw_timestamp_part_1, raw_timestamp_part_,2 cvtd_timestamp, new_window, and num_window* were removed.
```{r}
NA_count<-as.data.frame(colSums(is.na(train1)))
names_notNA<-which(NA_count==0)
train2<-train1[,names_notNA]
NA_count2<-as.data.frame(colSums(train2==""))
names_notNULL<-which(NA_count2==0)
train3<-train2[,names_notNULL]

dim(train1) #with NAs
dim(train2) #no NAs
dim(train3) #no NULLs
#irrelevant: user_name, raw_timestamp_part_1, raw_timestamp_part_,2 cvtd_timestamp, new_window, and  num_window
train4<-train3[,-c(1:7)]
dim(train4)
```

###Modeling using Random Forest
```{r}
set.seed(212)
Fit1 <- randomForest(classe ~. , data=train4, method="class",ntree=50)
print(Fit1)
```

###Cross Validation using training set and validation set
```{r}
set.seed(212)
pred0 <- predict(Fit1, train4, type = "class")
confusionMatrix(pred0, train4$classe)
pred1 <- predict(Fit1, valid1, type = "class")
confusionMatrix(pred1, valid1$classe)

```


##Testing on Test Set
The model obtained was then used to predict the classe of the out of sample test data.
```{r}
pred2 <- predict(Fit1, testing, type="class")
as.data.frame(pred2)
```

