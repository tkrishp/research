setwd("~/github/research/scripts/r_related")

# import libraries
library(dplyr)
library(tidyr)
library(psych)
library(corrplot)
library(robustHD)


# load scripts
source("train_test_split.R")
source("multi_return.R")

load_orig_data = function() {
  # load yelp biz data
  biz_data = read.csv("../../data/yelp_academic_dataset_business.csv", sep="\t")
  review_data = read.csv("../../data/yelp_academic_dataset_review.csv", sep="\t")
  user_data = read.csv("../../data/yelp_academic_dataset_user.csv", sep="\t")
  
  #### User data modifications ####
  
  # replace NA's with 0
  user_data[is.na(user_data)] = 0
  # create one variable each for compliments and votes
  user_data$user_compliments = user_data$user_compliments_hot + user_data$user_compliments_more + user_data$user_compliments_cute + user_data$user_compliments_writer + user_data$user_compliments_note + user_data$user_compliments_hot + user_data$user_compliments_cool + user_data$user_compliments_profile + user_data$user_compliments_list + user_data$user_compliments_photos + user_data$user_compliments_funny
  user_data$user_votes = user_data$user_votes_cool + user_data$user_votes_funny + user_data$user_votes_useful
  # convert yelping_since to days from 1/1/2016
  user_data$user_yelping_since = paste0(user_data$user_yelping_since, '-01')
  user_data$user_yelping_days = as.numeric(as.Date('2016-01-01') - as.Date(user_data$user_yelping_since))
  
  # drop columns that are not needed
  user_data = select(user_data, -starts_with('user_compliments_'))
  user_data = select(user_data, -starts_with('user_votes_'))
  user_data = select(user_data, -user_friends, -user_type, -user_elite, -user_name)
  user_data = rename(user_data,  user_friends = user_tot_friends)
  
  
  #### Review data modifications
  review_data$review_date_days = as.numeric(as.Date('2016-01-01') - as.Date(paste0(review_data$review_date)))
  review_data = review_data %>% select(review_id, business_id, user_id, 
                                       review_votes_cool, review_votes_funny, review_votes_useful, 
                                       review_date_days, review_stars, review_date)
  
  
  #### Restaurant data modifications ####
  
  # select only needed columns for business
  state_freq = biz_data %>% filter(business_new_categories_restaurants == 'True' & business_open == 'True') %>% group_by(business_state) %>% summarize(n = n()) %>% arrange(desc(n))
  plot(state_freq)
  biz_data %>% group_by(business_state, business_new_categories_restaurants) %>% summarize(n = n())
  biz_data %>% group_by(business_hours_wednesday_open) %>% summarize(n = n()) %>% arrange(desc(n))
  
  # find all restaurants
  biz_data %>% select(business_state, business_new_categories_restaurants) %>% filter(business_new_categories_restaurants == 'True') %>% group_by(business_state, business_new_categories_restaurants) %>% summarize(n = n()) %>% arrange(desc(n))
  
  # get PA restaurants
  pa_restaurant = biz_data %>% filter(business_new_categories_restaurants == 'True' & business_state == 'PA' & business_open == 'True')# %>% summarise(n=n())
  pa_restaurant = pa_restaurant %>% select(business_id, business_review_count, business_stars)
  
  return (list(pa_restaurant, user_data, review_data))
}

create_train_test_data = function(pa_restaurant, user_data, review_data) {
  c(train_restaurant, test_restaurant) := train_test_split(pa_restaurant)
  
  #### review data #### 
  train_review = select(inner_join(train_restaurant, review_data, by = "business_id"), business_id, user_id, starts_with("review"))
  test_review = select(inner_join(test_restaurant, review_data, by = "business_id"), business_id, user_id, starts_with("review"))
  
  #### user data #### 
  train_user = select(inner_join(train_review %>% distinct(user_id), user_data, by = "user_id"), starts_with("user"))
  test_user = select(inner_join(test_review %>% distinct(user_id), user_data, by = "user_id"), starts_with("user"))
  
  ##### train and test datasets #### 
  train_data = inner_join(inner_join(train_user, train_review, by = "user_id"), train_restaurant, by = "business_id")
  test_data = inner_join(inner_join(test_user, test_review, by = "user_id"), test_restaurant, by = "business_id")
  
  #### have columns in the correct order #### 
  train_data = train_data %>% select(review_id, business_id, user_id, business_stars, business_review_count, 
                                     user_fans, user_friends, user_yelping_days, user_compliments, user_votes, user_review_count, user_average_stars, 
                                     review_date_days, review_votes_cool, review_votes_funny, review_votes_useful, 
                                     review_stars, review_date)
  
  test_data = test_data %>% select(review_id, business_id, user_id, business_stars, business_review_count, 
                                     user_fans, user_friends, user_yelping_days, user_compliments, user_votes, user_review_count, user_average_stars, 
                                     review_date_days, review_votes_cool, review_votes_funny, review_votes_useful, 
                                     review_stars, review_date)
  
  
  #### save training/test data #### 
  write.csv(train_review, file = '../../data/train_test/train_review.csv', row.names=FALSE, quote = FALSE, eol = "\n")
  write.csv(train_restaurant, file = '../../data/train_test/train_restaurant.csv', row.names=FALSE, quote = FALSE, eol = "\n")
  write.csv(train_user, file = '../../data/train_test/train_user.csv', row.names=FALSE, quote = FALSE, eol = "\n")
  write.csv(train_data, file = '../../data/train_test/train_data.csv', row.names=FALSE, quote = FALSE, eol = "\n")
  
  write.csv(test_review, file = '../../data/train_test/test_review.csv', row.names=FALSE, quote = FALSE, eol = "\n")
  write.csv(test_restaurant, file = '../../data/train_test/test_restaurant.csv', row.names=FALSE, quote = FALSE, eol = "\n")
  write.csv(test_user, file = '../../data/train_test/test_user.csv', row.names=FALSE, quote = FALSE, eol = "\n")
  write.csv(test_data, file = '../../data/train_test/test_data.csv', row.names=FALSE, quote = FALSE, eol = "\n")
  
}

# Run this step only when loading from orginial data files and
# to create new set of train/test files
# otherwise use train/test files already created
#c(pa_restaurant, user_data, review_data) := load_orig_data()
#create_train_test_data(pa_restaurant, user_data, review_data)


