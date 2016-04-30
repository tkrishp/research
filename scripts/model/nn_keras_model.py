from __future__ import print_function
import numpy as np
import pandas as pd
import os

from keras.models import Sequential
from keras.layers.core import Dense, Dropout, Activation
from keras.layers.normalization import BatchNormalization
from keras.layers.advanced_activations import PReLU
from keras.utils import np_utils, generic_utils
from keras.optimizers import SGD

from sklearn.preprocessing import LabelEncoder
from sklearn.preprocessing import StandardScaler

np.random.seed(201604)
DATA_DIR = '/home/tulasi/github/research/data/train_test'


def load_data(csv_file):
    df = pd.read_csv(csv_file)
    X = df.values.copy()

    # shuffle training data
    np.random.shuffle(X)
    return X[:, 0:-1].astype(np.float32), X[:, -1]


def preprocess_labels(labels, encoder=None, categorical=True):
    if not encoder:
        encoder = LabelEncoder()
        encoder.fit(labels)
    y = encoder.transform(labels).astype(np.int32)
    if categorical:
        y = np_utils.to_categorical(y)
    return y, encoder


print('Loading data...')
# Load training data and extract ratings data
# encode ratings as int32
X, ratings = load_data(os.path.join(DATA_DIR, 'train.csv'))
y, encoder = preprocess_labels(ratings, categorical=False)

X_test, ratings = load_data(os.path.join(DATA_DIR, 'test.csv'))
y_test, encoder = preprocess_labels(ratings, categorical=False)

dims = X.shape[1]
print(dims, 'dims')

print('Building model...')

model = Sequential()

# Add 1st hidden layer; it should also accept input vector dimension
# Dense is a fully connected layer with sigmoid logistic as the activation layer
model.add(Dense(64, input_shape=(dims,), init='uniform', activation='tanh'))
model.add(Dropout(0.5))

# output layer with linear activation
model.add(Dense(1, activation='relu'))

# define the optimizer
sgd = SGD(lr=0.1, decay=1e-6, momentum=0.9, nesterov=True)
model.compile(loss='mean_squared_error', optimizer=sgd)

print('Training model...')
model.fit(X, y, nb_epoch=20, batch_size=128, validation_split=0.15)

print (model)

score = model.evaluate(X_test, y_test, batch_size=128)
print (score)
model.predict(X_test)