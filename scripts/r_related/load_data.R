setwd("~/github/research/scripts/r_related")

# import libraries
library(dplyr)
library(tidyr)

train_data = read.csv('../../data/train_test/train_data_post_normalizing.csv')
train_restaurant = read.csv('../../data/train_test/train_restaurant_post_normalizing.csv')
train_user = read.csv('../../data/train_test/train_user_post_normalizing.csv')
train_review = read.csv('../../data/train_test/train_review_post_normalizing.csv')

test_data = read.csv('../../data/train_test/test_data_post_normalizing.csv')
test_restaurant = read.csv('../../data/train_test/test_restaurant_post_normalizing.csv')
test_user = read.csv('../../data/train_test/test_user_post_normalizing.csv')
test_review = read.csv('../../data/train_test/test_review_post_normalizing.csv')


# remove features not needed for training
train = train_data %>% select(-review_id, -business_id, -user_id, -review_date)
test = test_data %>% select(-review_id, -business_id, -user_id, -review_date)

# save final datasets
options(scipen=10)
write.table(train, file = '../../data/train_test/train.csv', row.names=FALSE, quote = FALSE, eol = "\n", col.names = TRUE, sep = ",")
write.table(test, file = '../../data/train_test/test.csv', row.names=FALSE, quote = FALSE, eol = "\n", col.names = TRUE, sep = ",")
