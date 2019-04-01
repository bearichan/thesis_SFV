from setting import *
from CFF import CFF, SingleInfo
import pandas as pd
import sys
import re


def show_list(list_name):
    for reg in list_name:
        print(reg)


def has_info(info_list, line):
    res = False
    for keyword in info_list:
        if keyword in line:
            res = True
            break
    return res


def has_condition_statement(line):
    for pattern in condition_pattern:
        if re.findall(pattern, line):
            return re.findall(pattern, line)[0]
    return ''


def delete_reg_logo(dataframe):
    for i in range(dataframe.shape[0]):
        if dataframe.loc[i, 'signal_name'][-4:] == r'_reg':
            dataframe.loc[i, 'signal_name'] = dataframe.loc[i, 'signal_name'][0:-4]


def split_reg(s):
    lptr = 0
    index = 0
    res = []
    while index < len(s):
        if s[index] in operator_list:
            if index > lptr:
                res.append(s[lptr:index])
            lptr = index + 1
        index += 1
    res.append(s[lptr:])
    return res


if __name__ == '__main__':
    if len(sys.argv) < 2:
        score_filename = 'NN_rocket.csv'
        parse_filename = 'test.v'
    else:
        score_filename = sys.argv[1]
        parse_filename = sys.argv[2]

    df = pd.read_csv(score_filename)
    for i in range(df.shape[0]):
        df.loc[i, 'signal_name'] = df.loc[i, 'signal_name'].split('/')[-1]
    df2 = df.sort_values(by='score2', ascending=False)[['signal_name', 'score2']]
    df2 = df2[df2['score2'] > NN_score_threshold]
    df2 = df2.reset_index(drop=True)
    # delete_reg_logo(df2)
    df2 = df2.set_index(['signal_name'])
    df2 = df2.reindex(columns=['score2', 'C', 'SL', 'SR'], fill_value=[])
    CFF_list = df2.index
    # print(CFF_list)

    parse_list = []
    for name in df2.index:
        parse_list.append(CFF(name))

    v_file = []
    try:
        for line in open(parse_filename, "r"):
            if line.find(r'//') >= 0:
                v_file.append(line[:line.find(r'//')].replace(" ", ""))
            else:
                v_file.append(line[:-1].replace(" ", ""))
    except IOError as e:
        print('Datafile open failed!')
        raise e

    if not machine_nickname:
        for reg in parse_list:
            pattern = r'assign(.*)=%s;' % reg.name
            for line_number, item in enumerate(v_file):
                nickname = re.findall(pattern, item)
                if nickname:
                    reg.add_nickname(nickname[0])
    else:
        nickname_dict = {}
        for line_number, item in enumerate(v_file):
            if item.startswith('assign'):
                if (not has_info(judge_list, item)) and (r',' not in item):
                    LV_value = re.findall(r'assign(.*)=.*;', item)[0]
                    RV_list = split_reg(re.findall(r'assign.*=(.*);', item)[0])
                    # print(line_number, LV_value, RV_list)
                    if LV_value in nickname_dict.keys():
                        nickname_dict[LV_value].extend(RV_list)
                    else:
                        nickname_dict[LV_value] = RV_list

        for reg in parse_list:
            nickname_to_find = reg.nickname
            search_level = 0
            while nickname_to_find and (search_level < nickname_search_level):
                temp = []
                for key in nickname_dict.keys():
                    for item in nickname_dict[key]:
                        if (item in nickname_to_find) and (key not in reg.nickname):
                            reg.add_nickname(key)
                            temp.append(key)
                nickname_to_find = temp
                search_level += 1

        for line_number, item in enumerate(v_file):
            if (item.startswith('assign')) and (has_info(judge_list, item)):
                RV_value = item[item.index(r'=')+1:-1]
                RV_list = split_reg(RV_value)
                for reg in parse_list:
                    for nickname in reg.nickname:
                        if nickname in RV_list:
                            if replace_nickname:
                                reg.add_combination_logic1(
                                    SingleInfo(RV_value.replace(nickname, reg.name), line_number + 1))
                            else:
                                reg.add_combination_logic1(SingleInfo(RV_value, line_number + 1))

    Combination_Logic_Content = []  # flag = 0表示
    Sequential_Logic_Content = []  # flag = 1表示
    type_flag = 0
    lptr = 0

    for line_number, item in enumerate(v_file):
        if has_info(v_file_keyword_list, item):
            if type_flag == 0:
                Combination_Logic_Content.append((lptr, line_number))
            else:
                Sequential_Logic_Content.append((lptr, line_number))
            lptr = line_number
            if has_info(clock_list, item):
                type_flag = 1
            else:
                type_flag = 0

    # print(v_file[30])

    for line_numbers in Combination_Logic_Content:
        for line_number in range(line_numbers[0], line_numbers[1]):
            condition_statement = has_condition_statement(v_file[line_number])
            if condition_statement:
                for reg in parse_list:
                    for nickname in reg.nickname:
                        if nickname in condition_statement:
                            if replace_nickname:
                                reg.add_combination_logic1(
                                    SingleInfo(condition_statement.replace(nickname, reg.name), line_number + 1))
                            else:
                                reg.add_combination_logic1(SingleInfo(condition_statement, line_number + 1))

    for line_numbers in Sequential_Logic_Content:
        for line_number in range(line_numbers[0], line_numbers[1]):
            condition_statement = has_condition_statement(v_file[line_number])
            if condition_statement:
                for reg in parse_list:
                    for nickname in reg.nickname:
                        if nickname in condition_statement:
                            if replace_nickname:
                                reg.add_sequential_logic1(
                                    SingleInfo(condition_statement.replace(nickname, reg.name), line_number + 1))
                            else:
                                reg.add_sequential_logic1(SingleInfo(condition_statement, line_number + 1))

    CFF_extend_list = []
    for reg in parse_list:
        for nickname in reg.nickname:
            CFF_extend_list.append(nickname)

    LV_pattern = r'(.*)<='
    RV_pattern = r'<=(.*);'
    for line_numbers in Sequential_Logic_Content:
        for line_number in range(line_numbers[0], line_numbers[1]):
            if (r'<=' in v_file[line_number]) and (v_file[line_number].endswith(r';')):
                LV = re.findall(LV_pattern, v_file[line_number])[0]
                if r')' in LV:
                    LV = LV[LV.index(')') + 1:]
                RV = re.findall(RV_pattern, v_file[line_number])[0]
                for reg in parse_list:
                    for nickname in reg.nickname:
                        if (nickname in split_reg(RV)) and (LV in CFF_list):
                            expression = "(%s)##1(%s)" % (RV, LV)
                            if replace_nickname:
                                reg.add_sequential_logic2(
                                    SingleInfo(expression.replace(nickname, reg.name), line_number + 1))
                            else:
                                reg.add_sequential_logic2(SingleInfo(expression, line_number + 1))
    show_list(parse_list)
