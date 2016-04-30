import argparse
import pandas as pd
import numpy as np
import os

from keras.models import Sequential
from keras.layers.core import Dense, Dropout
from keras.utils import np_utils

from default_optimizers import def_sgd, def_adagrad, def_adadelta, def_adamax

MAIN_DIR = '/home/tulasi/github/research'
DATA_DIR = os.path.join(MAIN_DIR, 'data/train_test')


class NeuralNetModel(object):
    def __init__(self):
        self.X = None
        self.y = None
        self.X_test = None
        self.y_test = None
        self._model = None
        self._sgd = def_sgd
        self._adagrad = def_adagrad
        self._adadelta = def_adadelta
        self._adamax = def_adamax
        self.proba = None

    def load_train_test(self):
        train = pd.read_csv(os.path.join(DATA_DIR, 'train.csv'))
        test = pd.read_csv(os.path.join(DATA_DIR, 'test.csv'))

        self.X = train.values.copy()
        # to_categorical expects 0 indexed continous values for class, so, -1 on review star
        self.y = np_utils.to_categorical(train['review_stars']-1, 5)

        self.X_test = test.values.copy()
        self.y_test = np_utils.to_categorical(test['review_stars']-1, 5)

        self.X = self.X.astype(np.float32)
        self.X_test = self.X_test.astype(np.float32)

    def build_network(self):
        self._model = Sequential()

        # Add 1st hidden layer; it should also accept input vector dimension
        # Dense is a fully connected layer with tanh as the activation function
        self._model.add(Dense(32, input_shape=(self.X.shape[1], ), init='uniform', activation='tanh'))
        self._model.add(Dropout(0.5))

        self._model.add(Dense(64, activation='tanh'))
        self._model.add(Dropout(0.5))

        # output layer with sigmoid activation
        self._model.add(Dense(5, activation='softmax'))

    def train_and_predict(self, epoch, opt):
        self._model.compile(loss='categorical_crossentropy', optimizer=opt)
        self._model.fit(self.X, self.y, nb_epoch=epoch, show_accuracy=True, validation_split=0.8)
        self.proba = self._model.predict_proba(self.X_test, batch_size=32)
        np.set_printoptions(suppress=True)
        np.savetxt('results.csv', np.around(self.proba, 5), delimiter=",")
        loss, accuracy = self._model.evaluate(self.X_test, self.y_test, show_accuracy=True, verbose=0)
        print 'loss: %f, accuracy: %f' % (loss, accuracy)

    def execute(self, epoch, opt):
        print '----- load train/test data -----'
        self.load_train_test()

        print('----- Build model -----')
        self.build_network()

        print('----- Training model -----')
        if opt == 'sgd':
            self.train_and_predict(epoch, self._sgd)

        if opt == 'adagrad':
            self.train_and_predict(epoch, self._adagrad)

        if opt == 'adadelta':
            self.train_and_predict(epoch, self._adadelta)

        if opt == 'adamax':
            self.train_and_predict(epoch, self._adamax)


def main():
    parser = argparse.ArgumentParser(prog='ANN Model', description='ANN model for predicting restaurant stars')
    parser.add_argument('--epoch', type=int, default=10, help='Number of epochs to run the ANN')
    parser.add_argument('--opt', type=str, default='sgd', help='Optimizier to use. Valid values are [sgd|adagrad|adadelta|adamax')
    args = parser.parse_args()

    nn = NeuralNetModel()
    nn.execute(epoch=args.epoch, opt=args.opt)

if __name__ == '__main__':
    main()
