# import libraries
library(dplyr)
library(tidyr)

# load scripts
source("train_test_split.R")
source("multi_return.R")

# load yelp biz data
biz_data = read.csv("../../data/yelp_academic_dataset_business.csv", sep="\t")
review_data = read.csv("../../data/yelp_academic_dataset_review.csv", sep="\t")
user_data = read.csv("../../data/yelp_academic_dataset_user.csv", sep="\t")

# convert yelping_since to date datatype
user_data$user_yelping_since = as.Date(user_data$user_yelping_since, format="%Y-%M")

state_freq = biz_data %>% filter(business_new_categories_restaurants == 'True' & business_open == 'True') %>% group_by(business_state) %>% summarize(n = n()) %>% arrange(desc(n))
plot(state_freq)
biz_data %>% group_by(business_state, business_new_categories_restaurants) %>% summarize(n = n())
biz_data %>% group_by(business_hours_wednesday_open) %>% summarize(n = n()) %>% arrange(desc(n))

# find all restaurants
biz_data %>% select(business_state, business_new_categories_restaurants) %>% filter(business_new_categories_restaurants == 'True') %>% group_by(business_state, business_new_categories_restaurants) %>% summarize(n = n()) %>% arrange(desc(n))

# get PA restaurants
pa_restaurant = biz_data %>% filter(business_new_categories_restaurants == 'True' & business_state == 'PA' & business_open == 'True')# %>% summarise(n=n())

# get reviews for AZ restaurants
pa_restaurant_with_review = inner_join(pa_restaurant, review_data, by = "business_id")

# get users that wrote reviews for AZ restaurants
pa_user =  select(inner_join(user_data, (pa_restaurant_with_review %>% select(user_id) %>% distinct()), by = "user_id"),
                   starts_with("user_"))


c(train_user, test_user) := train_test_split(pa_user)
train_review = select(inner_join(train_user, review_data, by = "user_id"), business_id, user_id, starts_with("review"))
test_review = select(inner_join(test_user, review_data, by = "user_id"), business_id, user_id, starts_with("review"))

train_restaurant = select(inner_join(train_review %>% distinct(business_id), biz_data, by = "business_id"), starts_with("business"))
test_restaurant = select(inner_join(test_review %>% distinct(business_id), biz_data, by = "business_id"), starts_with("business"))

train_all = inner_join(inner_join(train_user, train_review, by = "user_id"), train_restaurant, by = "business_id")
test_all = inner_join(inner_join(test_user, test_review, by = "user_id"), test_restaurant, by = "business_id")




















#### plots ####

# join users, reviews and restaurants for az
pa_restaurant_with_review_and_users = inner_join(pa_restaurant_with_review, user_data, by = "user_id")


# find all users that have more than one review for a business
pa_restaurant_with_review_and_users %>% group_by(user_id, business_id) %>% summarize(n=n()) %>% filter(n>1)
hist(pa_restaurant$business_review_count, 
     breaks = 50, 
     main = "Histogram of review count", 
     xlab = "Review Count")

x = pa_user$user_average_stars
hist(x, 
     breaks = 50, 
     main = "Histogram of average stars",
     xlab = "Average Stars")
hist(x, prob=TRUE)            # prob=TRUE for probabilities not counts
lines(density(x))             # add a density estimate with defaults

boxplot(pa_user$user_average_stars)
boxplot(pa_user$user_review_count)


hist(x, prob=TRUE)            # prob=TRUE for probabilities not counts
lines(density(x))             # add a density estimate with defaults

# compute number of months the user has been yelping
monnb <- function(d) { lt <- as.POSIXlt(as.Date(d, origin="1900-01-01")); lt$year*12 + lt$mon }
mondf <- function(d1, d2) { monnb(d2) - monnb(d1) }
pa_user$yelping_since_months = mondf(paste0(pa_user$user_yelping_since, "-01"), "2016-01-01")
hist(pa_user$user_review_count/pa_user$yelping_since_months, 
     breaks = 100, 
     main = "Histogram of Review Counts",
     xlab = "Review Count"
)


#### analyse attributes columns #####
# for each column that starts with 'business_attributes_', get a frequency table' 
# for dynamic columns, end regular statements with _ 
for (column_name in colnames(select(pa_restaurant, starts_with("business_attributes_")))) { 
  print (column_name)
  x = pa_restaurant %>% select_(column_name) %>% group_by_(column_name) %>% summarize(n=n())
  print (x)
}

pa_restaurant %>% select(business_attributes_alcohol, business_stars, business_review_count) %>% group_by(business_attributes_alcohol) %>% summarize(count = n(), min_rating = min(business_stars), max_rating = max(business_stars), mean_rating = mean(business_stars), min_rev_count = min(business_review_count), max_rev_count = max(business_review_count), mean_rev_count = mean(business_review_count))


