import re
import sys

if __name__ == '__main__':
    raw_data = []
    if len(sys.argv) < 3:
        filename = 'test.vcd'
        offset = 10
    else:
        filename = sys.argv[1]
        offset = int(sys.argv[2])

    try:
        for line in open(filename, "r"):
            raw_data.append(line[:-1])
    except IOError as e:
        print('Datafile open failed!')
        raise e

    new_data = []
    pattern = r'#(\d+)$'
    for item in raw_data:
        number = re.findall(pattern, item)
        if number:
            new_line = '#' + str((int(number[0]) + offset))
        else:
            new_line = item
        new_data.append(new_line+'\n')

    pos = filename.index('.')
    new_filename = filename[:pos]+ '_new' +filename[pos:]
    with open(new_filename, 'w') as f:
        f.writelines(new_data)

