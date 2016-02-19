# -*- coding: utf-8 -*-
"""Convert the Yelp Dataset Challenge dataset from json format to csv.
For more information on the Yelp Dataset Challenge please visit http://yelp.com/dataset_challenge
"""
import argparse
import collections
import csv
import simplejson as json

# Reference: https://github.com/Yelp/dataset-examples/blob/master/json_to_csv_converter.py


def read_and_write_file(json_file_path, csv_file_path, column_names):
    """Read in the json dataset file and write it out to a csv file, given the column names."""
    with open(csv_file_path, 'wb+') as fout:
        csv_file = csv.writer(fout, delimiter='|', quotechar='"')

        r = {'&': "", ' ': "", '/': "", '-': "", "'": "", '(': '', ')': '', '.': ''}
        col_names_wo_special = map(lambda x: "".join([r.get(c, c) for c in x.lower()]), column_names)
        csv_file.writerow(col_names_wo_special)

        # write old and new column names to a file
        f = open(args.data_path + '/' + data_label + "_old_new_col_names.csv", "w")
        f.write("old_column,new_column\n")
        for i in range(len(list(column_names))):
            f.write(list(column_names)[i] + "," + col_names_wo_special[i] + "\n")
        f.close()

        with open(json_file_path) as fin:
            for line in fin:
                line_contents = json.loads(line)
                csv_file.writerow(get_row(line_contents, column_names))


def get_superset_of_column_names_from_file(json_file_path):
    """Read in the json dataset file and return the superset of column names."""
    column_names = set()
    with open(json_file_path) as fin:
        for line in fin:
            line_contents = json.loads(line)
            column_names.update(set(get_column_names(line_contents).keys()))
    return column_names


def get_column_names(line_contents, parent_key=''):
    """Return a list of flattened key names given a dict.
    Example:
        line_contents = {
            'a': {
                'b': 2,
                'c': 3,
                },
        }
        will return: ['a.b', 'a.c']
    These will be the column names for the eventual csv file.
    """
    column_names = []
    for k, v in line_contents.iteritems():
        column_name = "{0}____{1}".format(parent_key, k) if parent_key else k
        if isinstance(v, collections.MutableMapping):
            column_names.extend(
                    get_column_names(v, column_name).items()
                    )
        else:
            column_names.append((column_name, v))
    return dict(column_names)


def get_nested_value(d, key):
    """Return a dictionary item given a dictionary `d` and a flattened key from `get_column_names`.

    Example:
        d = {
            'a': {
                'b': 2,
                'c': 3,
                },
        }
        key = 'a.b'
        will return: 2

    """
    if '.' not in key:
        if key not in d:
            return None
        return d[key]
    base_key, sub_key = key.split('.', 1)
    if base_key not in d:
        return None
    sub_dict = d[base_key]
    return get_nested_value(sub_dict, sub_key)


def get_row(line_contents, column_names):
    """Return a csv compatible row given column names and a dict."""
    row = []
    for column_name in column_names:
        line_value = get_nested_value(
                        line_contents,
                        column_name,
                        )
        if isinstance(line_value, unicode):
            row.append('{0}'.format(line_value.encode('utf-8')))
        elif line_value is not None:
            row.append('{0}'.format(line_value))
        else:
            row.append('')
    return row


def conv_list_to_dict(json_file_path, new_json_file_path):
    outfile = open(new_json_file_path, 'w')
    with open(json_file_path) as fin:
        for line in fin:
            line_contents = json.loads(line)
            if data_label == 'business':
                line_contents['new_categories'] = {}
                line_contents['new_neighborhoods'] = {}
                for category in line_contents['categories']:
                    line_contents['new_categories'][category.replace(',', '')] = True
                for neighborhood in line_contents['neighborhoods']:
                    line_contents['new_neighborhoods'][neighborhood.replace(',', '')] = True
            else:
                if data_label == 'user':
                    line_contents['tot_friends'] = len(line_contents['friends'])
            json.dump(line_contents, outfile)
            outfile.write('\n')
    outfile.close()
    return


def get_data_label(file_name):
    return file_name[file_name.rfind('_')+1:file_name.find('.json')]


if __name__ == '__main__':
    """Convert a yelp dataset file from json to csv."""

    parser = argparse.ArgumentParser(description='Convert Yelp Dataset Challenge data from JSON format to CSV.',)
    parser.add_argument('data_path', type=str, help='director of data files')
    parser.add_argument('json_file', type=str, help='The json file to convert.',)
    args = parser.parse_args()

    data_label = get_data_label(args.json_file)
    print data_label
    json_file = args.data_path + '/' + args.json_file
    csv_file = '{0}.csv'.format(json_file.split('.json')[0])
    if data_label != 'review':
        new_json_file = '{0}_new.json'.format(json_file.split('.json')[0])
    else:
        new_json_file = json_file

    conv_list_to_dict(json_file, new_json_file)
    column_names = get_superset_of_column_names_from_file(new_json_file)
    read_and_write_file(new_json_file, csv_file, column_names)

