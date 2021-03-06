setwd("/Users/hzdy1994/Desktop/Kaggle")
library(xgboost)


##################
load("data/new_feature_no_corr.RData")
#train_test[is.na(train_test)] = -1

train = train_test[train_test$data == "train", -2]
test = train_test[train_test$data != "train", -2]

train_x = train[,c(3:42)]
train_x = as.matrix(train_x)
train_y = as.vector(train$target)
train_x = xgb.DMatrix(data = train_x, label = train_y)
test_x = as.matrix(test[,c(3:42)])

start = Sys.time()
params <- list(booster = "gbtree", objective = "binary:logistic", 
               eta=0.01, gamma=0, max_depth=5, 
               min_child_weight=5, subsample=0.6, 
               colsample_bytree=0.7)

xgbcv <- xgb.cv(params = params, 
                data = train_x,
                nrounds = 1500, nfold = 5, showsd = T, 
                stratified = T, print_every_n = 5, 
                early_stop_round = 20, 
                metrics = 'auc',
                maximize = T)
Sys.time() - start

best = which.max(xgbcv$evaluation_log$test_auc_mean)
# 0.6407798, gini = 0.2815596, n = 1395
# 2.5hr


params <- list(booster = "gbtree", objective = "binary:logistic", 
               eta=0.01, gamma=0, max_depth=5, 
               min_child_weight=5, subsample=0.6, 
               colsample_bytree=0.7)

xg_model = xgb.train(params = params,
                     data = train_x,
                     nrounds = best,
                     verbose = 1,
                     save_name = "xgboost_default.model")

pred <- predict(xg_model, test_x)
prediction <- data.frame(cbind(test$id, pred))
colnames(prediction) = c("id", "target")
write.csv(prediction, "prediction.csv", row.names = FALSE)
# 0.274.....???

importance = xgb.importance(feature_names = colnames(train[,c(3:42)]), model = xg_model)
write.csv(importance, "importance3.csv", row.names = FALSE)


##################
load("data/one_hot_encoding_ver.RData")

train = train_test[train_test$data == "train", -2]
test = train_test[train_test$data != "train", -2]

train_x = train[,c(3:147)]
train_x = as.matrix(train_x)
train_y = as.vector(train$target)
train_x = xgb.DMatrix(data = train_x, label = train_y)
test_x = as.matrix(test[,c(3:147)])

params <- list(booster = "gbtree", objective = "binary:logistic", 
               eta=0.01, max_depth=4, 
               min_child_weight=6, subsample=0.8, 
               colsample_bytree=0.8, scale_pos_weight=1.6,
               gamma=10,
               reg_alpha=8,
               reg_lambda=1.3)

xgbcv <- xgb.cv(params = params, 
                data = train_x,
                nrounds = 1500, nfold = 5, showsd = T, 
                stratified = T, print_every_n = 5, 
                early_stop_round = 20, 
                metrics = 'auc',
                maximize = T)

## not good - only around 0.639x

#####################################
# select a subset of original features

load("data/one-hot-coding.RData")

# features based on https://www.kaggle.com/aharless/xgboost-cv-lb-284

train_test$ps_ind_10_bin = NULL
train_test$ps_ind_11_bin = NULL
train_test$ps_ind_13_bin = NULL
train_test$ps_calc_01 = NULL
train_test$ps_calc_02 = NULL
train_test$ps_calc_03 = NULL
train_test$ps_calc_04 = NULL
train_test$ps_calc_06 = NULL
train_test$ps_calc_07 = NULL
train_test$ps_calc_08 = NULL
train_test$ps_calc_10 = NULL
train_test$ps_calc_11 = NULL
train_test$ps_calc_12 = NULL
train_test$ps_calc_13 = NULL
train_test$ps_calc_14 = NULL
train_test$ps_calc_15_bin = NULL
train_test$ps_calc_16_bin = NULL
train_test$ps_calc_17_bin = NULL
train_test$ps_calc_18_bin = NULL
train_test$ps_calc_19_bin = NULL
train_test$ps_calc_20_bin = NULL
train_test$ps_car_10_cat0 = NULL
train_test$ps_car_10_cat1 = NULL
train_test$ps_car_10_cat2 = NULL

train = train_test[train_test$data == "train", -2]
test = train_test[train_test$data != "train", -2]

train_x = train[,c(3:93)]
train_x = as.matrix(train_x)
train_y = as.vector(train$target)
train_x = xgb.DMatrix(data = train_x, label = train_y)
test_x = as.matrix(test[,c(3:93)])

params <- list(booster = "gbtree", objective = "binary:logistic", 
               eta=0.05, max_depth=4, 
               min_child_weight=6, subsample=0.8, 
               colsample_bytree=0.8, scale_pos_weight=1.6,
               gamma=10,
               reg_alpha=8,
               reg_lambda=1.3)

xgbcv <- xgb.cv(params = params, 
                data = train_x,
                nrounds = 1000, nfold = 5, showsd = T, 
                stratified = T, print_every_n = 5, 
                early_stop_round = 20, 
                metrics = 'auc',
                maximize = T)

# n = 969, cv auc = 0.642129, gini = 0.2842
best = which.max(xgbcv$evaluation_log$test_auc_mean)
max(xgbcv$evaluation_log$test_auc_mean)

params <- list(booster = "gbtree", objective = "binary:logistic", 
               eta=0.01, gamma=0, max_depth=5, 
               min_child_weight=5, subsample=0.6, 
               colsample_bytree=0.7)

xg_model = xgb.train(params = params,
                     data = train_x,
                     nrounds = best,
                     verbose = 1,
                     save_name = "xgboost_default.model")

pred <- predict(xg_model, test_x)
prediction <- data.frame(cbind(test$id, pred))
colnames(prediction) = c("id", "target")
write.csv(prediction, "prediction.csv", row.names = FALSE)
# 0.275 ???

importance = xgb.importance(feature_names = colnames(train[,c(3:93)]), model = xg_model)
write.csv(importance, "importance.csv", row.names = FALSE)

Sys.time()
