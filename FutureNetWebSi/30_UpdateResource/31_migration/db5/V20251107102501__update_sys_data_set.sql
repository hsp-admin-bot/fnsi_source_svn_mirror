DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-1100018);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1100018, 'WITH params AS (
SELECT 
 CASE
  WHEN  @coopCd in(''ind_dial'',''rst_dial'')  THEN 2
  WHEN  @coopCd in(''exam_ord'',''rad_ord'')   THEN 1
 END AS coopCd
)
SELECT 
split_part(split_part(save_2 ->> ''memo'', ''#'', coopCd), ''|'', @position)   AS send_day,
split_part(split_part(save_2 ->> ''memo'', ''#'', coopCd), ''|'', @position+1) AS seq_no,
 
 CASE 
  WHEN  @coopCd in(''ind_dial'',''rst_dial'')  THEN split_part(split_part(save_2 ->> ''memo'', ''#'', coopCd+2), ''|'', @position) 
  END AS K_send_day,
  
  CASE
    WHEN  @coopCd in(''ind_dial'',''rst_dial'')  THEN split_part(split_part(save_2 ->> ''memo'', ''#'', coopCd+2), ''|'', @position+1) 
  END AS K_seq_no
FROM
 pat_coop_detail as detail,params
WHERE
 facility_cd = @facilityCd
 AND pat_id = @patId
 AND (save_2 ->> ''ord_no'')::integer = @ordNo
 AND (save_2 ->> ''coop_cd'') = @coopCd
ORDER BY
up_date DESC
LIMIT 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 送信履歴メモから発生日/SEQ番号の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
