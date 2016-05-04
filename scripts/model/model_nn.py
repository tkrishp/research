import argparse
import numpy as np
import os

from keras.models import Sequential
from keras.layers.core import Dense, Dropout
from keras.utils import np_utils

from default_optimizers import def_sgd, def_adagrad, def_adadelta, def_adamax
import data_processor as dp


class NeuralNetModel(object):
    def __init__(self, data_dir):
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
        self._data_dir = data_dir

    def process_train_test(self, train, test):

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
        hist = self._model.fit(self.X, self.y, nb_epoch=epoch, validation_split=0.2)
        print hist.history
        self.proba = self._model.predict_proba(self.X_test, batch_size=32)
        loss, accuracy = self._model.evaluate(self.X_test, self.y_test, show_accuracy=True, verbose=0)
        print 'loss: %f, accuracy: %f' % (loss, accuracy)

    def execute(self, epoch, opt):

        print '----- load train/test data -----'
        data_loader = dp.DataLoader(self._data_dir)
        data_loader.load_train_test()

        for state in data_loader.train_dataset.keys():
            print '\n\n'
            print '\t> processing state [%s] ' % state
            self.process_train_test(data_loader.train_dataset[state], data_loader.test_dataset[state])

            print('\t\t----- Build model -----')
            self.build_network()

            print('\t\t----- Training model -----')
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
    parser.add_argument('--data-dir', type=str, help='Directory with train and test datasets')
    args = parser.parse_args()

    nn = NeuralNetModel(args.data_dir)
    nn.execute(epoch=args.epoch, opt=args.opt)

if __name__ == '__main__':
    main()
