def list_help(list):
    if len(list) == 0:
        return ''
    res = list[0].__str__()
    for i in range(1, len(list)):
        res = res + list[i].__str__()
        if i % 5 == 0:
            res = res + '\n     '
    return res


class SingleInfo:
    def __init__(self, content, line_number):
        self.content = content
        self.line_number = line_number

    def __str__(self):
        return "L%s(%s) " % (self.line_number, self.content)


class CFF:
    def __init__(self, name):
        self.name = name
        self.nickname = [self.name]
        self.Combination_Logic1 = []
        self.Sequential_Logic1 = []
        self.Sequential_Logic2 = []

    def __str__(self):
        s1 = self.name
        s2 = ''
        for i in range(len(self.nickname)):
            if i % 5 == 4:
                s2 = s2 + self.nickname[i] + '\n'
            else:
                s2 = s2 + self.nickname[i] + ','
        s3 = list_help(self.Combination_Logic1)
        s4 = list_help(self.Sequential_Logic1)
        s5 = list_help(self.Sequential_Logic2)
        return "Flip_Flop: %s \nNickname: %s \nCL1: %s \nSL1: %s \nSL2: %s\n" % (s1, s2, s3, s4, s5)

    def add_nickname(self, nickname):
        self.nickname.append(nickname)

    def add_combination_logic1(self, info):
        self.Combination_Logic1.append(info)

    def add_sequential_logic1(self, info):
        self.Sequential_Logic1.append(info)

    def add_sequential_logic2(self, info):
        self.Sequential_Logic2.append(info)

    def show_nickname(self):
        s1 = self.name
        s2 = ','.join(self.nickname)
        print("Flip_Flop: %s Nickname: %s" % (s1, s2))
