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


#### descriptive stats from user data ####
describe(train_user)
describe(train_review)
describe(train_restaurant)


#### restaurant data ####
# bin review counts
bins = c(0, 25, 50, 75, seq(100, 700, 50))
hist(train_restaurant$business_review_count, breaks = bins, main = 'Distribution of Review Count / Restaurant', xlab = 'Total Reviews')
train_restaurant$business_review_count_bin = cut(train_restaurant$business_review_count, breaks = bins)
train_restaurant %>% select(business_review_count_bin) %>% distinct(business_review_count_bin)
train_restaurant %>% group_by(business_review_count_bin) %>% summarize(count=n(), perc=round(n()*100/781, 0))
# find restaurant with 657 reviews
train_restaurant %>% filter(business_review_count_bin == '(650,700]')
train_review %>% filter(business_id == 'SsGNAc9U-aKPZccnaDtFkA') %>% distinct(user_id) %>% summarize(n=n())

inner_join(train_review %>% filter(business_id == 'SsGNAc9U-aKPZccnaDtFkA') %>% distinct(user_id),
           train_user,
           by = 'user_id') %>% summarize(mean_review_count=mean(user_review_count), mean_rating = mean(user_average_stars))

train_restaurant %>% filter(business_review_count > 250) %>% summarize(mean = mean(business_stars))

inner_join(train_restaurant %>% filter(business_review_count > 250) %>% select(business_id),
           train_review,
           by = 'business_id'
) %>% 
  group_by(business_id) %>% 
  summarize(mean_votes_useful = mean(review_votes_useful), 
            min_votes_useful = min(review_votes_useful),
            max_votes_useful = max(review_votes_useful),
            pct_votes_useful = max(review_votes_useful)*100/n())

train_review %>% summarize(mean_votes_useful = mean(review_votes_useful))
boxplot(train_restaurant %>% filter(business_review_count < 250) %>% select(business_review_count), ylab = 'Count of Reviews')
boxplot(train_restaurant %>% select(business_review_count), ylab = 'Count of Reviews')
train_restaurant %>% filter(business_review_count < 250) %>% 
  summarize(mean_review_count = mean(business_review_count), mean_rating = mean(business_stars))

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
write.csv(train_review, file = '../../data/train_test/train_review_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")
write.csv(train_restaurant, file = '../../data/train_test/train_restaurant_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")
write.csv(train_user, file = '../../data/train_test/train_user_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")
write.csv(train_data, file = '../../data/train_test/train_data_post_winsorizing.csv', row.names=FALSE, quote = FALSE, eol = "\n")
