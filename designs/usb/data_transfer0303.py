import numpy as np
import pandas as pd
import re
import sys

sample_size = 11
divide_symbol = r'instances_hier'
if __name__ == '__main__':
    temp = []
    if len(sys.argv) < 2:
        filename = 'test2.rpt'
    else:
        filename = sys.argv[1]

    try:
        for line in open(filename, "r"):
            temp.append(line[:-1])
    except IOError as e:
        print('Datafile open failed!')
        raise e

    data_length = len(temp) // sample_size
    try:
        raw_data = np.array(temp).reshape(data_length, sample_size)
    except Exception as e:
        print('Data format is invalid!')
        raise e
    raw_data = np.column_stack((raw_data, np.array([1 for i in range(data_length)])))
    print(raw_data.shape)

    pattern = r'(.*)\[\d+\]\d*$'
    multi_signal_dict = {}
    for i in range(data_length):
        signal_name = re.findall(pattern, raw_data[i, 0])
        if signal_name:
            if signal_name[0] in multi_signal_dict:
                multi_signal_dict[signal_name[0]].append(i)
            else:
                multi_signal_dict[signal_name[0]] = [i]

    delete_list = []
    for signal_name in multi_signal_dict:
        temp = np.array([0 for i in range(sample_size + 1)])
        for index in multi_signal_dict[signal_name]:
            delete_list.append(index)
            temp[1:7] = temp[1:7] + (raw_data[index][1:7]).astype(np.int)  # 前6维信号相加
            if int(raw_data[index][7]) == 1:  # loop信号
                temp[7] = 1
        temp[8:11] = raw_data[multi_signal_dict[signal_name][0]][8:11].astype(np.int)  # 3个size信息
        temp[11] = len(multi_signal_dict[signal_name])  # length
        raw_data = np.row_stack((raw_data, np.append(np.array(signal_name), temp[1:])))

    raw_data = np.delete(raw_data, delete_list, axis=0)

    # raw_data = np.column_stack((raw_data, np.array([data_length for i in range(raw_data.shape[0])])))

    df = pd.DataFrame(raw_data,
                      columns=['signal_name', 'Rin', 'Rout', 'fanin', 'fanout', 'fanin_v', 'fanout_v', 'loop',
                               'size_in', 'size_out', 'size_reg', 'length',
                               ])

    for i in range(len(df.loc[:, 'signal_name'])):
        temp = df.loc[i, 'signal_name'].split('/')
        temp2 = []
        for j, item in enumerate(temp):
            if item == divide_symbol:
                temp2.append(temp[j + 1])
        temp2.append(temp[-1])
        df.loc[i, 'signal_name'] = '/'.join(temp2)

    df.to_csv('Result3.csv', index=0)
    print('Data transfer finished!')
