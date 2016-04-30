setwd("~/github/research/scripts/r_related")

# import libraries
library(dplyr)
library(tidyr)
library(psych)
library(corrplot)
library(robustHD)


plots = function() {
  boxplot(train_restaurant %>% select(business_stars), ylab = 'Count of Reviews')
  boxplot(train_user %>% select(user_average_stars), ylab = 'Average Rating')
  boxplot(train_user %>% select(user_review_count), ylab = 'Total User Review')
  boxplot(train_user %>% select(user_friends), ylab = 'Total Friends')
  boxplot(train_user %>% select(user_yelping_days), ylab = 'Days Yelping')
  
  boxplot(train_restaurant %>% select(business_review_count_win), ylab = 'Count of Reviews')
  boxplot(train_restaurant %>% select(business_stars_win), ylab = 'Business Stars')
  boxplot(train_review %>% select(review_date_days_win), ylab = 'Review Age')
  boxplot(train_user %>% select(user_average_stars_win), ylab = 'Average Rating')
  boxplot(train_user %>% select(user_review_count_win), ylab = 'Total User Review')
  boxplot(train_user %>% select(user_friends_win), ylab = 'Total Friends')
  boxplot(train_user %>% select(user_yelping_days_win), ylab = 'Days Yelping')
  
  
}
load_data = function(data_dir) {
  #### load train and test data ####
  train = read.csv(paste0(data_dir, '/', 'train_data.csv'))
  train_restaurant = read.csv(paste0(data_dir, '/', 'train_restaurant.csv'))
  train_user = read.csv(paste0(data_dir, '/', 'train_user.csv'))
  train_review = read.csv(paste0(data_dir, '/', 'train_review.csv'))
  
  test = read.csv(paste0(data_dir, '/', 'test_data.csv'))
  test_restaurant = read.csv(paste0(data_dir, '/', 'test_restaurant.csv'))
  test_user = read.csv(paste0(data_dir, '/', 'test_user.csv'))
  test_review = read.csv(paste0(data_dir, '/', 'test_review.csv'))
}

winsorize_data = function() {
  #### winsorizing ####
  train_restaurant$business_review_count = winsorize(train_restaurant$business_review_count, standardized = FALSE)
  train_restaurant$business_stars = winsorize(train_restaurant$business_stars, standardized = FALSE)
  train_review$review_date_days = winsorize(train_review$review_date_days, standardized = FALSE)
  train_user$user_average_stars = winsorize(train_user$user_average_stars, standardized = FALSE)
  train_user$user_review_count = winsorize(train_user$user_review_count, standardized = FALSE)
  train_user$user_friends = winsorize(train_user$user_friends, standardized = FALSE)
  train_user$user_yelping_days = winsorize(train_user$user_yelping_days, standardized = FALSE)
  
  test_restaurant$business_review_count = winsorize(test_restaurant$business_review_count, standardized = FALSE)
  test_restaurant$business_stars = winsorize(test_restaurant$business_stars, standardized = FALSE)
  test_review$review_date_days = winsorize(test_review$review_date_days, standardized = FALSE)
  test_user$user_average_stars = winsorize(test_user$user_average_stars, standardized = FALSE)
  test_user$user_review_count = winsorize(test_user$user_review_count, standardized = FALSE)
  test_user$user_friends = winsorize(test_user$user_friends, standardized = FALSE)
  test_user$user_yelping_days = winsorize(test_user$user_yelping_days, standardized = FALSE)

  return (list(train_restaurant, train_user, train_review, 
               test_restaurant, test_user, test_review))    
}

save_data = function(data_dir) {
  write.csv(train_review, file = paste0(data_dir, '/', 'train_review_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n"))
  write.csv(train_restaurant, file = paste0(data_dir, '/', 'train_test/train_restaurant_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n"))
  write.csv(train_user, file = paste0(data_dir, '/', 'train_user_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n"))
  write.csv(train, file = paste0(data_dir, '/', 'train_data_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n"))
  
  write.csv(test_review, file = paste0(data_dir, '/', 'test_review_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n"))
  write.csv(test_restaurant, file = paste0(data_dir, '/', 'test_restaurant_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n"))
  write.csv(test_user, file = paste0(data_dir, '/', 'test_user_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n"))
  write.csv(test, file = paste0(data_dir, '/', 'test_data_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n"))
}
