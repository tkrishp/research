import argparse
import os
import plotter as plt
from time import strftime, localtime
import csv

seed = 12356
import numpy as np
np.random.seed(seed)

from keras.models import Sequential
from keras.layers.core import Dense, Dropout
from keras.utils import np_utils
from keras.regularizers import l1l2, l2
from default_optimizers import def_sgd, def_adagrad, def_adadelta, def_adamax, def_adam
import data_processor as dp


class NeuralNetModel(object):
    def __init__(self, data_dir, epoch):
        self.X = None
        self.y = None
        self.X_test = None
        self.y_test = None
        self._model = None
        self._sgd = def_sgd
        self._adagrad = def_adagrad
        self._adadelta = def_adadelta
        self._adamax = def_adamax
        self._adam = def_adam
        self.proba = None
        self._data_dir = data_dir
        self._final_results = {}
        self.epoch = epoch

        self._final_results['epoch'] = range(1, self.epoch + 1)

    def set_opt(self, opt):
        self.opt = opt

    def prepare_data(self, train, test):

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
        self._model.add(Dense(16,
                              input_shape=(self.X.shape[1], ),
                              init='uniform',
                              W_regularizer=l2(l=0.01),
                              b_regularizer=l2(l=0.01),
                              activation='tanh'))
        # self._model.add(Dropout(0.2))

        self._model.add(Dense(16,
                              W_regularizer=l2(l=0.01),
                              b_regularizer=l2(l=0.01),
                              activation='tanh'))
        # self._model.add(Dropout(0.2))

        # output layer with sigmoid activation
        self._model.add(Dense(5, activation='softmax'))

    def save_results(self):
        results = self._final_results
        results_dir = os.path.join(self._data_dir, 'results_' + strftime("%m%d%Y_%H%M%S", localtime()))
        results_file = os.path.join(results_dir, 'results.tsv')
        os.mkdir(results_dir)

        with open(results_file, 'wb') as f:
            w = csv.writer(f, delimiter='\t')
            header = results.keys()
            header.append('seed')
            w.writerow(header)
            print results.keys()
            for i in range(0, self.epoch):
                row = [str(results[key][i]) for key in results.keys()]
                row.append(seed)
                w.writerow(row)

    def train_and_predict(self, epoch, opt):
        self._model.compile(loss='categorical_crossentropy', optimizer=opt)
        hist = self._model.fit(self.X, self.y, nb_epoch=epoch, validation_split=0.3, show_accuracy=True)
        # self.show_plots(hist.history)
        results = hist.history

        if self.opt == 'sgd':
            self._final_results['sgd_loss'] = results['loss']
            self._final_results['sgd_val_loss'] = results['val_loss']
            self._final_results['sgd_acc'] = results['acc']
            self._final_results['sgd_val_acc'] = results['val_acc']
        if self.opt == 'adagrad':
            self._final_results['adagrad_loss'] = results['loss']
            self._final_results['adagrad_val_loss'] = results['val_loss']
            self._final_results['adagrad_acc'] = results['acc']
            self._final_results['adagrad_val_acc'] = results['val_acc']
        if self.opt == 'adadelta':
            self._final_results['adadelta_loss'] = results['loss']
            self._final_results['adadelta_val_loss'] = results['val_loss']
            self._final_results['adadelta_acc'] = results['acc']
            self._final_results['adadelta_val_acc'] = results['val_acc']
        if self.opt == 'adamax':
            self._final_results['adamax_loss'] = results['loss']
            self._final_results['adamax_val_loss'] = results['val_loss']
            self._final_results['adamax_acc'] = results['acc']
            self._final_results['adamax_val_acc'] = results['val_acc']
        if self.opt == 'adam':
            self._final_results['adam_loss'] = results['loss']
            self._final_results['adam_val_loss'] = results['val_loss']
            self._final_results['adam_acc'] = results['acc']
            self._final_results['adam_val_acc'] = results['val_acc']

        self.proba = self._model.predict_proba(self.X_test, batch_size=32)
        loss, accuracy = self._model.evaluate(self.X_test, self.y_test, show_accuracy=True, verbose=0)
        print 'loss: %f, accuracy: %f' % (loss, accuracy)

    def execute(self, data_loader):
        if not data_loader.train_dataset:
            self.prepare_data(data_loader.train, data_loader.test)
            self.run()
        else:
            for state in data_loader.train_dataset.keys():
                print 'processing state [%s] ' % state
                self.prepare_data(data_loader.train_dataset[state], data_loader.test_dataset[state])
                self.run()

    def run(self):
        print('----- Build model -----')
        self.build_network()

        if self.opt == 'sgd':
            print('----- Training model [%s]-----' % self.opt)
            self.train_and_predict(self.epoch, self._sgd)

        if self.opt == 'adagrad':
            print('----- Training model [%s]-----' % self.opt)
            self.train_and_predict(self.epoch, self._adagrad)

        if self.opt == 'adadelta':
            print('----- Training model [%s]-----' % self.opt)
            self.train_and_predict(self.epoch, self._adadelta)

        if self.opt == 'adamax':
            print('----- Training model [%s]-----' % self.opt)
            self.train_and_predict(self.epoch, self._adamax)

        if self.opt == 'adam':
            print('----- Training model [%s]-----' % self.opt)
            self.train_and_predict(self.epoch, self._adam)

    def show_plots(self, data):
        plt.plot_epoch_vs_logloss(range(1, self.epoch), data['loss'][1:], xlabel='epoch', ylabel='Training loss')


def main():
    parser = argparse.ArgumentParser(prog='ANN Model', description='ANN model for predicting restaurant stars')
    parser.add_argument('--epoch', type=int, default=10, help='Number of epochs to run the ANN')
    parser.add_argument('--opt', type=str, default='sgd', help='Optimizier to use. Valid values are [sgd|adagrad|adadelta|adamax')
    parser.add_argument('--data-dir', type=str, help='Directory with train and test datasets')
    args = parser.parse_args()

    print '----- load train/test data -----'
    data_loader = dp.DataLoader(args.data_dir)
    data_loader.load_train_test()

    nn = NeuralNetModel(args.data_dir, args.epoch)
    if args.opt == 'all':
        for opt in ['sgd', 'adagrad', 'adadelta', 'adamax', 'adam']:
            nn.set_opt(opt)
            nn.execute(data_loader)
    else:
        nn = NeuralNetModel(args.data_dir, args.epoch)
        nn.set_opt(args.opt)
        nn.execute(data_loader)

    nn.save_results()


if __name__ == '__main__':
    main()
