import pandas as pd
import os


class DataLoader(object):

    def __init__(self, data_dir):
        self._data_dir = data_dir
        self.train = None
        self.test = None
        self.train_dataset = {}
        self.test_dataset = {}

    def load_train_test(self):
        self.train = pd.read_csv(os.path.join(self._data_dir, 'train.csv'))
        self.test = pd.read_csv(os.path.join(self._data_dir, 'test.csv'))
        self._separate_data_state()

    def _separate_data_state(self):
        for state in self.train['business_state'].unique():
            print 'loading train data for [%s]' % state
            self.train_dataset[state] = self.train[self.train['business_state'] == state].drop(['business_state'], axis=1)

        for state in self.test['business_state'].unique():
            print 'loading test data for [%s]' % state
            self.test_dataset[state] = self.test[self.train['business_state'] == state].drop(['business_state'], axis=1)
