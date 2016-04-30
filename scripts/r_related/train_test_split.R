
train_test_split = function(restaurant) {
  
  # split user data into train and test
  smp_size = floor(0.70 * nrow(restaurant))
  train_ind = sample(seq_len(nrow(restaurant)), size = smp_size)
  
  train_restaurant = restaurant[train_ind, ]
  test_restaurant = restaurant[-train_ind, ]

  return (list(train_restaurant, test_restaurant))
}
