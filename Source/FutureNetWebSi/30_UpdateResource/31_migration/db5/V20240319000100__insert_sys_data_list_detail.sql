-- add 9987 by kangjie 20230110 start
INSERT INTO sys_data_list_detail SELECT
                                   205,
                                   6,
                                   37,
                                   '調製薬剤',
                                   '2',
                                   NULL,
                                   '調製薬剤',
                                   '2',
                                   NULL,
                                   NULL,
                                   NULL
FROM
  ( SELECT 1 ) tmp
WHERE
  NOT EXISTS ( SELECT 1 FROM sys_data_list_detail WHERE data_list_detail_cd = 205 AND disp_order = 6 AND category_cd = 37 AND master_display_name = '調製薬剤' )
-- add 9987 by kangjie 20240110 end
