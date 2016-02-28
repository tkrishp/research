

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


