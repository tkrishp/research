import csv
import os
from pybrain.datasets.supervised import SupervisedDataSet
from pybrain.structure import FeedForwardNetwork, LinearLayer, SigmoidLayer, FullConnection, BiasUnit
from pybrain.supervised import BackpropTrainer

DATA_DIR = '/home/tulasi/github/research/data/train_test'
TRAIN_FN = os.path.join(DATA_DIR, 'train.csv')
TEST_FN = os.path.join(DATA_DIR, 'test.csv')


def create_datasets():
    train_ds = SupervisedDataSet(13, 1)
    test_ds = SupervisedDataSet(13, 1)

    with open(TRAIN_FN, 'r') as fn:
        for row in csv.reader(fn):
            input = [float(x) for x in row[:-1]]
            target = [int(row[-1])]
            train_ds.addSample(input, target)

    with open(TEST_FN, 'r') as fn:
        for row in csv.reader(fn):
            input = [float(x) for x in row[:-1]]
            target = [int(row[-1])]
            test_ds.addSample(input, target)

    return train_ds, test_ds


def ann_network():
    nn = FeedForwardNetwork()

    # define the activation function and # of nodes per layer
    in_layer = LinearLayer(13)
    hidden_layer = SigmoidLayer(5)
    bias_unit = BiasUnit(name='bias')
    out_layer = LinearLayer(1)

    # add modules to the network
    nn.addInputModule(in_layer)
    nn.addModule(hidden_layer)
    nn.addModule(bias_unit)
    nn.addOutputModule(out_layer)

    # define connections between the nodes
    hidden_with_bias = FullConnection(hidden_layer, bias_unit)
    in_to_hidden = FullConnection(in_layer, hidden_layer)
    hidden_to_out = FullConnection(hidden_layer, out_layer)

    # add connections to the network
    nn.addConnection(in_to_hidden)
    nn.addConnection(hidden_with_bias)
    nn.addConnection(hidden_to_out)

    # perform network interal initialization
    nn.sortModules()

    return nn


def main():
    print '----- loading train/test datasets -----'
    train_ds, test_ds = create_datasets()
    print '----- building the network -----'
    net = ann_network()
    trainer = BackpropTrainer(net, learningrate=0.1, momentum=0.1, verbose=True)
    print '----- training the model -----'
    trainer.trainOnDataset(train_ds)

    # print final parameters
    # print('Final weights:', net.params)


main()
