setwd("~/github/research/scripts/r_related")

# import libraries
library(dplyr)
library(tidyr)
library(psych)
library(corrplot)
library(robustHD)

#### load train and test data ####
train_data = read.csv('../../data/train_test/train_data.csv')
train_restaurant = read.csv('../../data/train_test/train_restaurant.csv')
train_user = read.csv('../../data/train_test/train_user.csv')
train_review = read.csv('../../data/train_test/train_review.csv')

test_data = read.csv('../../data/train_test/test_data.csv')
test_restaurant = read.csv('../../data/train_test/test_restaurant.csv')
test_user = read.csv('../../data/train_test/test_user.csv')
test_review = read.csv('../../data/train_test/test_review.csv')

boxplot(train_restaurant %>% select(business_stars), ylab = 'Count of Reviews')
boxplot(train_user %>% select(user_average_stars), ylab = 'Average Rating')
boxplot(train_user %>% select(user_review_count), ylab = 'Total User Review')
boxplot(train_user %>% select(user_friends), ylab = 'Total Friends')
boxplot(train_user %>% select(user_yelping_days), ylab = 'Days Yelping')


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

boxplot(train_restaurant %>% select(business_review_count_win), ylab = 'Count of Reviews')
boxplot(train_restaurant %>% select(business_stars_win), ylab = 'Business Stars')
boxplot(train_review %>% select(review_date_days_win), ylab = 'Review Age')
boxplot(train_user %>% select(user_average_stars_win), ylab = 'Average Rating')
boxplot(train_user %>% select(user_review_count_win), ylab = 'Total User Review')
boxplot(train_user %>% select(user_friends_win), ylab = 'Total Friends')
boxplot(train_user %>% select(user_yelping_days_win), ylab = 'Days Yelping')


train_data = inner_join(inner_join(train_user, train_review, by = "user_id"), train_restaurant, by = "business_id")
train_data = train_data %>% select(review_id, business_id, user_id, business_stars, business_review_count, 
                                   user_fans, user_friends, user_yelping_days, user_compliments, user_votes, user_review_count, user_average_stars, 
                                   review_date_days, review_votes_cool, review_votes_funny, review_votes_useful, 
                                   review_stars, review_date)

test_data = inner_join(inner_join(test_user, test_review, by = "user_id"), test_restaurant, by = "business_id")
test_data = train_data %>% select(review_id, business_id, user_id, business_stars, business_review_count, 
                                  user_fans, user_friends, user_yelping_days, user_compliments, user_votes, user_review_count, user_average_stars, 
                                  review_date_days, review_votes_cool, review_votes_funny, review_votes_useful, 
                                  review_stars, review_date)

write.csv(train_review, file = '../../data/train_test/train_review_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")
write.csv(train_restaurant, file = '../../data/train_test/train_restaurant_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")
write.csv(train_user, file = '../../data/train_test/train_user_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")
write.csv(train_data, file = '../../data/train_test/train_data_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")

write.csv(test_review, file = '../../data/train_test/test_review_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")
write.csv(test_restaurant, file = '../../data/train_test/test_restaurant_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")
write.csv(test_user, file = '../../data/train_test/test_user_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")
write.csv(test_data, file = '../../data/train_test/test_data_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")

