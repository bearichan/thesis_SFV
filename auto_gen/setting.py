NN_score_threshold = 0.8
v_file_keyword_list = ['always', 'assign', 'endmodule']
clock_list = ['clk', 'clock', 'CLK', 'CLOCK']
condition_pattern = [r'if\((.*)\)', r'case\((.*)\)']
replace_nickname = False
operator_list = ['&', '|', '^', '=', '<', '>', '|', '!']
judge_list = ['==', '<', '>', '!=', '^=', '&=', '|=', '===', '!==']
machine_nickname = True
nickname_search_level = 1  # machine_nickname为True的情况下才有用
