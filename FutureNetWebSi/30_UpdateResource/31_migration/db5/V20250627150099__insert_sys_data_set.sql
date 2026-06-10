DELETE FROM ntss.sys_data_set
WHERE sql_cd=-1102026;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102026, 'select
	-- 日付をYYYY/MM/DD形式に整形
	TO_CHAR(
    TO_DATE(jsonb_extract_path_text(save_2, @fileKind || ''_send_day''), ''YYYYMMDD''),
    ''YYYY-MM-DD''
  ) as occur_date,
	-- 時刻をHH24:MI:SS形式に整形
	TO_CHAR(
    TO_TIMESTAMP(jsonb_extract_path_text(save_2, @fileKind || ''_seq_no''), ''HH24MISS''),
    ''HH24:MI:SS''
  ) as occur_time
from
	pat_coop_detail
where
	facility_cd = @facilityCd
	and pat_id = @patId
	and (save_2 ->> ''ord_no'')::integer = @ordNo
	and (save_2 ->> ''coop_cd'') = @coopCd
order by
	up_date desc
limit 1;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析指示連携 削除時の発生日/SEQ番号', current_timestamp, current_timestamp, NULL);