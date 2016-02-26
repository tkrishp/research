set.seed(12345)

train_test_split = function(pa_user) {
  
  # split user data into train and test
  smp_size = floor(0.70 * nrow(pa_user))
  train_ind = sample(seq_len(nrow(pa_user)), size = smp_size)
  
  train_user = pa_user[train_ind, ]
  test_user = pa_user[-train_ind, ]

  return (list(train_user, test_user))
}
