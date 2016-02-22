# import libraries
library(dplyr)
library(tidyr)

# load yelp biz data
biz_data = read.csv("../../data/yelp_academic_dataset_business.csv", sep="\t")
review_data = read.csv("../../data/yelp_academic_dataset_review.csv", sep="\t")
user_data = read.csv("../../data/yelp_academic_dataset_user.csv", sep="\t")

# convert yelping_since to date datatype
user_data$user_yelping_since = as.Date(user_data$user_yelping_since, format="%Y-%M")


state_freq = biz_data %>% select(business_state) %>% group_by(business_state) %>% summarize(n = n()) %>% arrange(desc(n))
plot(state_freq)
biz_data %>% group_by(business_state, business_new_categories_restaurants) %>% summarize(n = n())
biz_data %>% group_by(business_hours_wednesday_open) %>% summarize(n = n()) %>% arrange(desc(n))

# find all restaurants
biz_data %>% select(business_state, business_new_categories_restaurants) %>% filter(business_new_categories_restaurants == 'True') %>% group_by(business_state, business_new_categories_restaurants) %>% summarize(n = n()) %>% arrange(desc(n))

# get PA restaurants
pa_restaurants = biz_data %>% filter(business_new_categories_restaurants == 'True' & business_state == 'PA')# %>% summarise(n=n())

# get reviews for AZ restaurants
pa_restaurants_with_reviews = inner_join(pa_restaurants, review_data, by = "business_id")

# get users that wrote reviews for AZ restaurants
pa_users =  select(inner_join(user_data, (pa_restaurants_with_reviews %>% select(user_id) %>% distinct()), by = "user_id"),
                   starts_with("user_"))

# join users, reviews and restaurants for az
pa_restaurants_with_reviews_and_users = inner_join(pa_restaurants_with_reviews, user_data, by = "user_id")


# find all users that have more than one review for a business
pa_restaurants_with_reviews_and_users %>% group_by(user_id, business_id) %>% summarize(n=n()) %>% filter(n>1)


### plots ####
hist(pa_restaurants$business_review_count, breaks = 50, main = "Histogram of review count", xlab = "Review Count")


#### analyse attributes columns #####
# for each column that starts with 'business_attributes_', get a frequency table' 
# for dynamic columns, end regular statements with _ 
for (column_name in colnames(select(pa_restaurants, starts_with("business_attributes_")))) { 
  print (column_name)
  x = pa_restaurants %>% select_(column_name) %>% group_by_(column_name) %>% summarize(n=n())
  print (x)
}

pa_restaurants %>% select(business_attributes_alcohol, business_stars, business_review_count) %>% group_by(business_attributes_alcohol) %>% summarize(count = n(), min_rating = min(business_stars), max_rating = max(business_stars), mean_rating = mean(business_stars), min_rev_count = min(business_review_count), max_rev_count = max(business_review_count), mean_rev_count = mean(business_review_count))

