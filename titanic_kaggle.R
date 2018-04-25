
tdf = read.csv("train.csv")

# Survived (0, 1)
# Pclass (1, 2, 3)
# Sex (male, female)
# Age (0.42 - 80, NA)
# SibSp (0 - 8)
# Parch (0 - 6)
# Fare (0 - 512.3292)
# Embarked ("", C, Q, S)

library(ggplot2)

ggplot(tdf, aes(x = Pclass, fill = Sex)) + 
  geom_bar() +
  xlab("Class")
ggplot(tdf[!is.na(tdf$Age), ], aes(x = as.factor(Pclass), y = Age)) + 
  geom_boxplot() +
  xlab("Class")
ggplot(tdf, aes(x = as.factor(Pclass), y = SibSp + Parch, color = Sex)) + 
  geom_jitter(position = position_jitter(0.2), size = 2, alpha = 0.3) + 
  labs(x = "Class", y = "Family size")
ggplot(tdf[tdf$Fare > 0, ], aes(x = as.factor(Pclass), y = Fare)) + 
  geom_boxplot() +
  xlab("Class")
ggplot(tdf[tdf$Embarked != "", ], aes(x = Embarked, fill = as.factor(Pclass))) + 
  geom_bar() +
  labs(fill = "Class")

ggplot(tdf[!is.na(tdf$Age), ], aes(x = Sex, y = Age)) + 
  geom_boxplot()
ggplot(tdf, aes(x = Sex, y = Fare, color = as.factor(Pclass))) + 
  geom_jitter(position = position_jitter(0.2), size = 2, alpha = 0.2) +
  labs(color = "Class")
ggplot(tdf[tdf$Embarked != "", ], aes(x = Embarked, fill = Sex)) + 
  geom_bar()

ggplot(tdf[!is.na(tdf$Age), ], aes(x = SibSp + Parch, y = Age, color = Sex)) + 
  geom_jitter(position = position_jitter(0.1), size = 3, alpha = 0.2) +
  xlab("Family Size")
ggplot(tdf[!is.na(tdf$Age), ], aes(x = Age, y = Fare, color = as.factor(Pclass))) + 
  geom_point(size = 2, alpha = 0.4) +
  labs(color = "Class")
ggplot(tdf[!is.na(tdf$Age) & tdf$Embarked != "", ], aes(x = Embarked, y = Age, color = Sex)) + 
  geom_jitter(position = position_jitter(0.1), size = 2, alpha = 0.3)

ggplot(tdf, aes(x = SibSp + Parch, y = Fare, color = as.factor(Pclass))) + 
  geom_jitter(position = position_jitter(0.3), size = 2, alpha = 0.3) +
  labs(color = "Class", x = "Family size")
ggplot(tdf[tdf$Embarked != "", ], aes(x = Embarked, y = SibSp + Parch, color = Sex)) + 
  geom_jitter(position = position_jitter(0.4), size = 3, alpha = 0.2) +
  ylab("Family size")

ggplot(tdf[tdf$Embarked != "", ], aes(x = Embarked, y = Fare, color = as.factor(Pclass))) + 
  geom_jitter(position = position_jitter(0.4), size = 3, alpha = 0.2) +
  labs(color = "Class")

ggplot(tdf, aes(x = as.factor(Pclass), fill = Survived == 1)) +
  geom_bar() +
  labs(x = "Class", fill = "Survived")
ggplot(tdf, aes(x = as.factor(Pclass), y = Fare, color = Survived == 1)) +
  geom_jitter(position = position_jitter(0.4), size = 3, alpha = 0.3) +
  labs(x = "Class", color = "Survived")
ggplot(tdf, aes(x = Sex, fill = Survived == 1)) +
  geom_bar() +
  labs(fill = "Survived")
ggplot(tdf[!is.na(tdf$Age), ], aes(x = SibSp + Parch, y = Age, color = Survived == 1)) +
  geom_jitter(position = position_jitter(0.2), size = 3, alpha = 0.3)+
  labs(x = "Family size", color = "Survived")
ggplot(tdf[!is.na(tdf$Age), ], aes(x = Age, y = Fare, color = Survived == 1)) +
  geom_point(size = 3, alpha = 0.3) +
  labs(color = "Survived")
ggplot(tdf[!is.na(tdf$Age), ], aes(x = Sex, y = Age, color = Survived == 1)) +
  geom_jitter(position = position_jitter(0.2), size = 3, alpha = 0.3) +
  labs(color = "Survived")
ggplot(tdf[tdf$Embarked != "", ], aes(x = Embarked, fill = Survived == 1)) +
  geom_bar() +
  labs(fill = "Survived")

library(caret)
taf = tdf[, c(
            "Survived",
            "Pclass",
            "Sex",
            "Age",
            "Fare",
            "Embarked"
          )]
taf$Family = tdf$SibSp + tdf$Parch
taf = taf[!is.na(taf$Age) & taf$Embarked != "", ]
taf$Pclass = as.factor(taf$Pclass)
#taf$Fare = log(taf$Fare + 1)
#taf$Age = scale(taf$Age)
set.seed(341)
train_ndx = createDataPartition(taf$Survived, p = 0.7, list = F)
taf$Fare = taf$Fare > median(taf[train_ndx, "Fare"])

GetAcc = function(pred, data){
  po = pred > 0.5
  ao = data$Survived == 1
  Acc = sum(po == ao)/nrow(data)
  Prec = sum(po == 1 & ao == 1)/sum(po)
  Rec = sum(po == 1 & ao == 1)/sum(ao)
  return(c(Accuracy = Acc, Precision = Prec, Recall = Rec))
}

# logistic regression
model_bin = glm(Survived ~ ., data = taf[train_ndx, ], family = "binomial")
summary(model_bin)
GetAcc(predict(model_bin, taf[-train_ndx, ]), taf[-train_ndx, ])

model_minbin = glm(Survived ~ Pclass + Sex + Age + Family, data = taf[train_ndx, ], family = "binomial")
summary(model_minbin)
GetAcc(predict(model_minbin, taf[-train_ndx, ]), taf[-train_ndx, ])

model_minbin2 = glm(Survived ~ Pclass + Sex + Age + Family + Fare, data = taf[train_ndx, ], family = "binomial")
summary(model_minbin2)
GetAcc(predict(model_minbin2, taf[-train_ndx, ]), taf[-train_ndx, ])
# best binomial model

# svm
library(e1071)
model_gaussvm = svm(Survived ~ ., data = taf[train_ndx, ])
GetAcc(predict(model_gaussvm, taf[-train_ndx, ]), taf[-train_ndx, ])

model_linsvm = svm(Survived ~ ., data = taf[train_ndx, ], kernel = "linear")
GetAcc(predict(model_linsvm, taf[-train_ndx, ]), taf[-train_ndx, ])

model_minsvm = svm(Survived ~ Pclass + Sex + Age + Family, data = taf[train_ndx, ], kernel = "linear")
GetAcc(predict(model_minsvm, taf[-train_ndx, ]), taf[-train_ndx, ])
# best svm model

# lda
library(MASS)
model_lda = lda(Survived ~ Pclass + Sex + Age + Family + Fare, data = taf[train_ndx, ])
GetAcc(predict(model_lda, taf[-train_ndx, ])$posterior[, 2], taf[-train_ndx, ])
# best lda model

model_minlda = lda(Survived ~ Pclass + Sex + Age + Family, data = taf[train_ndx, ])
GetAcc(predict(model_minlda, taf[-train_ndx, ])$posterior[, 2], taf[-train_ndx, ])

# qda
model_qda = qda(Survived ~ Pclass + Sex + Age + Family + Fare, data = taf[train_ndx, ])
GetAcc(predict(model_qda, taf[-train_ndx, ])$posterior[, 2], taf[-train_ndx, ])

model_minqda = qda(Survived ~ Pclass + Sex + Age + Family, data = taf[train_ndx, ])
GetAcc(predict(model_minqda, taf[-train_ndx, ])$posterior[, 2], taf[-train_ndx, ])
# best qda model

# gam
library(gam)
model_gam = gam(Survived ~ Pclass + Sex + s(Age, 6) + s(Family, 6) + Fare, data = taf[train_ndx, ])
GetAcc(predict(model_gam, taf[-train_ndx, ]), taf[-train_ndx, ])

# regularized logistic regression
library(glmnet)
mtrain = model.matrix(~., taf[train_ndx, -1])
mtest = model.matrix(~., taf[-train_ndx, -1])
model_ridgebin = cv.glmnet(mtrain, taf[train_ndx, 1], alpha = 0, family = "binomial")
GetAcc(predict(model_ridgebin, mtest, type = "response"), taf[-train_ndx, ])
# best regularized

model_lassobin = cv.glmnet(mtrain, taf[train_ndx, 1], alpha = 1, family = "binomial")
GetAcc(predict(model_lassobin, mtest, type = "response"), taf[-train_ndx, ])


# summary
GetAcc(predict(model_minbin2, taf[-train_ndx, ]), taf[-train_ndx, ])
GetAcc(predict(model_minsvm, taf[-train_ndx, ]), taf[-train_ndx, ])
GetAcc(predict(model_lda, taf[-train_ndx, ])$posterior[, 2], taf[-train_ndx, ])
GetAcc(predict(model_minqda, taf[-train_ndx, ])$posterior[, 2], taf[-train_ndx, ])
GetAcc(predict(model_gam, taf[-train_ndx, ]), taf[-train_ndx, ])
GetAcc(predict(model_ridgebin, mtest, type = "response"), taf[-train_ndx, ])
