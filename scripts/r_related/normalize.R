setwd("~/github/research/scripts/r_related")

# import libraries
library(dplyr)
library(tidyr)
library(psych)
library(corrplot)
library(robustHD)

#### load train and test data ####
train_data = read.csv('../../data/train_test/train_data_post_winsorizing.csv')
train_restaurant = read.csv('../../data/train_test/train_restaurant_post_winsorizing.csv')
train_user = read.csv('../../data/train_test/train_user_post_winsorizing.csv')
train_review = read.csv('../../data/train_test/train_review_post_winsorizing.csv')

test_data = read.csv('../../data/train_test/test_data_post_winsorizing.csv')
test_restaurant = read.csv('../../data/train_test/test_restaurant_post_winsorizing.csv')
test_user = read.csv('../../data/train_test/test_user_post_winsorizing.csv')
test_review = read.csv('../../data/train_test/test_review_post_winsorizing.csv')

train_restaurant$business_review_count = round((train_restaurant$business_review_count - min(train_restaurant$business_review_count))/(max(train_restaurant$business_review_count) - min(train_restaurant$business_review_count)), 4)
train_restaurant$business_stars = round((train_restaurant$business_stars - min(train_restaurant$business_stars))/(max(train_restaurant$business_stars) - min(train_restaurant$business_stars)), 4)

train_user$user_fans = round((train_user$user_fans - min(train_user$user_fans))/(max(train_user$user_fans) - min(train_user$user_fans)), 4)
train_user$user_average_stars = round((train_user$user_average_stars - min(train_user$user_average_stars))/(max(train_user$user_average_stars) - min(train_user$user_average_stars)), 4)
train_user$user_review_count = round((train_user$user_review_count - min(train_user$user_review_count))/(max(train_user$user_review_count) - min(train_user$user_review_count)), 4)
train_user$user_friends = round((train_user$user_friends - min(train_user$user_friends))/(max(train_user$user_friends) - min(train_user$user_friends)), 4)
train_user$user_compliments = round((train_user$user_compliments - min(train_user$user_compliments))/(max(train_user$user_compliments) - min(train_user$user_compliments)), 4)
train_user$user_votes = round((train_user$user_compliments - min(train_user$user_compliments))/(max(train_user$user_compliments) - min(train_user$user_compliments)), 4)
train_user$user_yelping_days = round((train_user$user_yelping_days - min(train_user$user_yelping_days))/(max(train_user$user_yelping_days) - min(train_user$user_yelping_days)), 4)

train_review$review_votes_cool = round((train_review$review_votes_cool - min(train_review$review_votes_cool))/(max(train_review$review_votes_cool) - min(train_review$review_votes_cool)), 4)
train_review$review_votes_funny = round((train_review$review_votes_funny - min(train_review$review_votes_funny))/(max(train_review$review_votes_funny) - min(train_review$review_votes_funny)), 4)
train_review$review_votes_useful = round((train_review$review_votes_useful - min(train_review$review_votes_useful))/(max(train_review$review_votes_useful) - min(train_review$review_votes_useful)), 4)
train_review$review_date_days = round((train_review$review_date_days - min(train_review$review_date_days))/(max(train_review$review_date_days) - min(train_review$review_date_days)), 4)


train_data = inner_join(inner_join(train_user, train_review, by = "user_id"), train_restaurant, by = "business_id")
train_data = train_data %>% select(review_id, business_id, user_id, business_stars, business_review_count, 
                                   user_fans, user_friends, user_yelping_days, user_compliments, user_votes, user_review_count, user_average_stars, 
                                   review_date_days, review_votes_cool, review_votes_funny, review_votes_useful, 
                                   review_stars, review_date)


test_restaurant$business_review_count = round((test_restaurant$business_review_count - min(test_restaurant$business_review_count))/(max(test_restaurant$business_review_count) - min(test_restaurant$business_review_count)), 4)
test_restaurant$business_stars = round((test_restaurant$business_stars - min(test_restaurant$business_stars))/(max(test_restaurant$business_stars) - min(test_restaurant$business_stars)), 4)

test_user$user_fans = round((test_user$user_fans - min(test_user$user_fans))/(max(test_user$user_fans) - min(test_user$user_fans)), 4)
test_user$user_average_stars = round((test_user$user_average_stars - min(test_user$user_average_stars))/(max(test_user$user_average_stars) - min(test_user$user_average_stars)), 4)
test_user$user_review_count = round((test_user$user_review_count - min(test_user$user_review_count))/(max(test_user$user_review_count) - min(test_user$user_review_count)), 4)
test_user$user_friends = round((test_user$user_friends - min(test_user$user_friends))/(max(test_user$user_friends) - min(test_user$user_friends)), 4)
test_user$user_compliments = round((test_user$user_compliments - min(test_user$user_compliments))/(max(test_user$user_compliments) - min(test_user$user_compliments)), 4)
test_user$user_votes = round((test_user$user_compliments - min(test_user$user_compliments))/(max(test_user$user_compliments) - min(test_user$user_compliments)), 4)
test_user$user_yelping_days = round((test_user$user_yelping_days - min(test_user$user_yelping_days))/(max(test_user$user_yelping_days) - min(test_user$user_yelping_days)), 4)

test_review$review_votes_cool = round((test_review$review_votes_cool - min(test_review$review_votes_cool))/(max(test_review$review_votes_cool) - min(test_review$review_votes_cool)), 4)
test_review$review_votes_funny = round((test_review$review_votes_funny - min(test_review$review_votes_funny))/(max(test_review$review_votes_funny) - min(test_review$review_votes_funny)), 4)
test_review$review_votes_useful = round((test_review$review_votes_useful - min(test_review$review_votes_useful))/(max(test_review$review_votes_useful) - min(test_review$review_votes_useful)), 4)
test_review$review_date_days = round((test_review$review_date_days - min(test_review$review_date_days))/(max(test_review$review_date_days) - min(test_review$review_date_days)), 4)


test_data = inner_join(inner_join(test_user, test_review, by = "user_id"), test_restaurant, by = "business_id")
test_data = test_data %>% select(review_id, business_id, user_id, business_stars, business_review_count, 
                                 user_fans, user_friends, user_yelping_days, user_compliments, user_votes, user_review_count, user_average_stars, 
                                 review_date_days, review_votes_cool, review_votes_funny, review_votes_useful, 
                                 review_stars, review_date)

write.csv(train_review, file = '../../data/train_test/train_review_post_normalizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")
write.csv(train_restaurant, file = '../../data/train_test/train_restaurant_post_normalizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")
write.csv(train_user, file = '../../data/train_test/train_user_post_normalizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")
write.csv(train_data, file = '../../data/train_test/train_data_post_normalizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")

write.csv(test_review, file = '../../data/train_test/test_review_post_normalizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")
write.csv(test_restaurant, file = '../../data/train_test/test_restaurant_post_normalizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")
write.csv(test_user, file = '../../data/train_test/test_user_post_normalizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")
write.csv(test_data, file = '../../data/train_test/test_data_post_normalizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")




