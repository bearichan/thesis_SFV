import numpy as np
import pandas as pd
import sys

in_to_reg_filename = r'in_to_reg.rpt'
reg_to_out_filename = r'reg_to_out.rpt'
reg_to_reg_filename = r'reg_to_reg.rpt'

pattern1 = r'End-point'
pattern2 = r'Start-point'
pattern3 = r'instances_hier'
feature_list = ['Rin', 'Rout', 'RRin', 'RRout', 'loop', 'length', 'hier_level', 'size']


def get_name(line, name_lists):
    lptr = line.index(r':') + 2
    if '[' in line:
        rptr = len(line) - 1
        while line[rptr] != r'[':
            rptr -= 1
    elif r'/' in line:
        rptr = len(line) - 1
        while line[rptr] != r'/':
            rptr -= 1
    else:
        rptr = len(line)
    signal_name = line[lptr:rptr]
    if signal_name not in name_lists:
        print('Unknown reg name: %s, please check!' % signal_name)
    return signal_name


if __name__ == '__main__':
    if len(sys.argv) < 2:
        csv_filename = 'res_lcd.csv'
    else:
        csv_filename = sys.argv[1]

    df = pd.read_csv(csv_filename)
    df = df[df['type'].isin([3])]
    df = df.reset_index()
    for i in range(len(df.loc[:, 'signal_name'])):
        temp = df.loc[i, 'signal_name'].split('/')
        temp2 = []
        for j, item in enumerate(temp):
            if item == pattern3:
                temp2.append(temp[j + 1])
        temp2.append(temp[-1])
        df.loc[i, 'signal_name'] = '/'.join(temp2)

    df = df.set_index(['signal_name'])
    df = df.reindex(columns=feature_list, fill_value=0)
    signal_names = np.array(df.index)

    for line in open(in_to_reg_filename, 'r'):
        if pattern1 in line:
            signal_name = get_name(line, signal_names)
            df.loc[signal_name, 'Rin'] += 1

    for line in open(reg_to_out_filename, 'r'):
        if pattern2 in line:
            signal_name = get_name(line, signal_names)
            df.loc[signal_name, 'Rout'] += 1

    reg_to_reg_file = []
    for line in open(reg_to_reg_filename, 'r'):
        reg_to_reg_file.append(line)

    for index, line in enumerate(reg_to_reg_file):
        if pattern2 in line:
            signal_name1 = get_name(line, signal_names)
            signal_name2 = get_name(reg_to_reg_file[index + 1], signal_names)
            df.loc[signal_name1, 'RRout'] += 1
            df.loc[signal_name2, 'RRin'] += 1
            if signal_name1 == signal_name2:
                df.loc[signal_name1, 'loop'] = 1

    pos = csv_filename.index('.')
    output_filename = csv_filename[:pos] + '_reg' + csv_filename[pos:]
    df.to_csv(output_filename)
    print('Data transfer finished!')

