UPDATE mst_addition
SET add_cnt_1 = 1
WHERE (addition_limit_type = '1' AND add_cnt_1 IS NULL) OR add_cnt_1 = 0;
UPDATE mst_addition
SET addition_limit = 1
WHERE addition_limit = 0;
