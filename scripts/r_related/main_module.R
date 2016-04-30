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

set.seed(12345)

load_orig_data = function() {
  # load yelp biz data
  biz = read.csv("../../data/yelp_academic_dataset_business.csv", sep="\t")
  review = read.csv("../../data/yelp_academic_dataset_review.csv", sep="\t")
  user = read.csv("../../data/yelp_academic_dataset_user.csv", sep="\t")
  
  #### User data modifications ####
  
  # replace NA's with 0
  user[is.na(user)] = 0
  # create one variable each for compliments and votes
  user$user_compliments = user$user_compliments_hot + user$user_compliments_more + user$user_compliments_cute + user$user_compliments_writer + user$user_compliments_note + user$user_compliments_hot + user$user_compliments_cool + user$user_compliments_profile + user$user_compliments_list + user$user_compliments_photos + user$user_compliments_funny
  user$user_votes = user$user_votes_cool + user$user_votes_funny + user$user_votes_useful
  # convert yelping_since to days from 1/1/2016
  user$user_yelping_since = paste0(user$user_yelping_since, '-01')
  user$user_yelping_days = as.numeric(as.Date('2016-01-01') - as.Date(user$user_yelping_since))
  
  # drop columns that are not needed
  user = select(user, -starts_with('user_compliments_'))
  user = select(user, -starts_with('user_votes_'))
  user = select(user, -user_friends, -user_type, -user_elite, -user_name)
  user = rename(user,  user_friends = user_tot_friends)
  
  
  #### Review data modifications
  review$review_date_days = as.numeric(as.Date('2016-01-01') - as.Date(paste0(review$review_date)))
  review = review %>% select(review_id, business_id, user_id, 
                                       review_votes_cool, review_votes_funny, review_votes_useful, 
                                       review_date_days, review_stars, review_date)
  
  
  #### Restaurant data modifications ####
  # select only needed columns for business
  state_freq = biz %>% filter(business_new_categories_restaurants == 'True' & business_open == 'True') %>% group_by(business_state) %>% summarize(n = n()) %>% arrange(desc(n))

  return (list(biz, user, review))
}

get_pa_data = function(biz, user, review) {
  # get PA restaurants
  pa_restaurant = biz %>% filter(business_new_categories_restaurants == 'True' & business_state == 'PA' & business_open == 'True')# %>% summarise(n=n())
  pa_restaurant = pa_restaurant %>% select(business_id, business_review_count, business_stars)
  
  return (list(pa_restaurant, user, review))
}

get_restaurants_for_states_with_atleast_n_restaurants = function(restaurant, n) {
  # get states with atleast n restaurants
  restaurant = biz %>% filter(business_new_categories_restaurants == 'True' & business_open == 'True')
  tmp = restaurant %>% filter(business_new_categories_restaurants == 'True') %>% group_by(business_state) %>% summarize(n = n()) %>% arrange(desc(n)) %>% filter(n > 100) %>% select (business_state)
  out = inner_join(restaurant, tmp, on='business_state')

  return (out)
}

create_train_test_split = function() {
  c(train_restaurant, test_restaurant) := train_test_split(restaurant)
  
  #### review data #### 
  train_review = select(inner_join(train_restaurant, review, by = "business_id"), business_id, user_id, starts_with("review"))
  test_review = select(inner_join(test_restaurant, review, by = "business_id"), business_id, user_id, starts_with("review"))
  
  #### user data #### 
  train_user = select(inner_join(train_review %>% distinct(user_id), user, by = "user_id"), starts_with("user"))
  test_user = select(inner_join(test_review %>% distinct(user_id), user, by = "user_id"), starts_with("user"))
  
  ##### train and test datasets #### 
  train = inner_join(inner_join(train_user, train_review, by = "user_id"), train_restaurant, by = "business_id")
  test = inner_join(inner_join(test_user, test_review, by = "user_id"), test_restaurant, by = "business_id")
  
  #### have columns in the correct order #### 
  train = train %>% select(review_id, business_id, user_id, business_state, business_stars, business_review_count, user_fans, user_friends, 
                           user_yelping_days, user_compliments, user_votes, user_review_count, user_average_stars, 
                           review_date_days, review_votes_cool, review_votes_funny, review_votes_useful, 
                           review_stars, review_date)
  
  test = test %>% select(review_id, business_id, user_id, business_state, business_stars, business_review_count, 
                         user_fans, user_friends, user_yelping_days, user_compliments, user_votes, user_review_count, 
                         user_average_stars, review_date_days, review_votes_cool, review_votes_funny, review_votes_useful,
                         review_stars, review_date)
  
  return (list(train_restaurant, train_user, train_review, train, 
               test_restaurant, test_user, test_review, test))
}

save_train_test_split = function(data_dir, train_restaurant, train_user, train_review, train, 
                                 test_restaurant, test_user, test_review, test) {

  #### save training/test data #### 
  write.csv(train_review, file = paste0(data_dir, '/', 'train_review.csv'), row.names=FALSE, quote = FALSE, eol = "\n")
  write.csv(train_restaurant, file = paste0(data_dir, '/', 'train_restaurant.csv'), row.names=FALSE, quote = FALSE, eol = "\n")
  write.csv(train_user, file = paste0(data_dir, '/', 'train_user.csv'), row.names=FALSE, quote = FALSE, eol = "\n")
  write.csv(train, file = paste0(data_dir, '/', 'train.csv'), row.names=FALSE, quote = FALSE, eol = "\n")

  write.csv(test_review, file = paste0(data_dir, '/', 'test_review.csv'), row.names=FALSE, quote = FALSE, eol = "\n")
  write.csv(test_restaurant, file = paste0(data_dir, '/', 'test_restaurant.csv'), row.names=FALSE, quote = FALSE, eol = "\n")
  write.csv(test_user, file = paste0(data_dir, '/', 'test_user.csv'), row.names=FALSE, quote = FALSE, eol = "\n")
  write.csv(test, file = paste0(data_dir, '/', 'test.csv'), row.names=FALSE, quote = FALSE, eol = "\n")
}

# Run this step only when loading from orginial data files and
# to create new set of train/test files
# otherwise use train/test files already created
c(biz, user, review) := load_orig_data()
restaurant = get_restaurants_for_states_with_atleast_n_restaurants(biz, 100)
c(train_restaurant, train_user, train_review, train, 
  test_restaurant, test_user, test_review, test) := create_train_test_split()

dir_name = format(Sys.time(), "%m%d%Y_%H%M%S")
dir = paste0('/home/tulasi/github/research/data/train_test_', dir_name)
sub_dir1 = paste0(dir, '/', 'orig')
sub_dir2 = paste0(dir, '/', 'processed')
dir.create(dir, showWarnings = TRUE, recursive = TRUE, mode = "0777")
dir.create(sub_dir1, showWarnings = TRUE, recursive = TRUE, mode = "0777")
dir.create(sub_dir2, showWarnings = TRUE, recursive = TRUE, mode = "0777")

save_train_test_split(sub_dir1,
                      train_restaurant, train_user, train_review, train, 
                      test_restaurant, test_user, test_review, test)

source("winsorizing.R")
c(train_restaurant, train_user, train_review, test_restaurant, test_user, test_review) := winsorize_data()

source("normalize.R")
c(train_restaurant, train_user, train_review, test_restaurant, test_user, test_review) := normalize_data()

train = inner_join(inner_join(train_user, train_review, by = "user_id"), train_restaurant, by = "business_id")
train = train %>% select(review_id, business_id, user_id, business_stars, business_review_count, 
                         user_fans, user_friends, user_yelping_days, user_compliments, user_votes, user_review_count, user_average_stars, 
                         review_date_days, review_votes_cool, review_votes_funny, review_votes_useful, 
                         review_stars, review_date)

test = inner_join(inner_join(test_user, test_review, by = "user_id"), test_restaurant, by = "business_id")
test = train %>% select(review_id, business_id, user_id, business_stars, business_review_count, 
                        user_fans, user_friends, user_yelping_days, user_compliments, user_votes, user_review_count, user_average_stars, 
                        review_date_days, review_votes_cool, review_votes_funny, review_votes_useful, 
                        review_stars, review_date)
save_train_test_split(sub_dir2,
                      train_restaurant, train_user, train_review, train, 
                      test_restaurant, test_user, test_review, test)
