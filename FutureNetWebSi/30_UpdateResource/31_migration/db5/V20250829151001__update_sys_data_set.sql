DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-132, -111, -499);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-132, 'WITH ord_main_data AS ( 
   ( SELECT (to_number(ind_cond_info:: json ->''26'' ->> ''value'', ''9999.99'')+
to_number(ind_cond_info:: json ->''28'' ->> ''value'', ''9999.99''))::TEXT AS anti_coagulant_amount, pat_id
    FROM ord_main 
    WHERE ord_no = @ordNo)
		union 
				   ( SELECT (to_number(ind_cond_info:: json ->''26'' ->> ''value'', ''9999.99'')+
to_number(ind_cond_info:: json ->''28'' ->> ''value'', ''9999.99''))::TEXT AS anti_coagulant_amount, pat_id
    FROM ord_main_restore
    WHERE ord_no = @ordNo
		and (select count(1) from  ord_main 
    WHERE ord_no = @ordNo) = ''0''
		ORDER BY del_date desc limit 1)
)
, ini_data AS (
    SELECT COALESCE
        ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_setting 
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
    WHERE
        facility_cd = @facilityCd
     
        AND is_del = ''0''
                -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
                AND COALESCE(info ->> ''key0'', '''') = @key0
                -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end 
        AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
        AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
) 
, dialysis_date AS (
    SELECT
        REPLACE(MIN(I.period_start_date) :: TEXT, ''-'', '''') AS dialysis_start_date
    FROM
        pat_unique U
        CROSS JOIN LATERAL jsonb_to_recordset(U.in_out_visit_history_info) AS I
        (   ctl_no bigint,
            period_start_date date,
            period_start_day bigint,
            period_start_month bigint,
            period_start_year bigint,
            move_in_out smallint
        )
    WHERE pat_id = (SELECT pat_id FROM ord_main_data)
    AND U.is_del = ''0''
    AND I.period_start_day IS NOT NULL
    AND I.period_start_month IS NOT NULL
    AND I.period_start_year IS NOT NULL
    AND I.period_start_date IS NOT NULL
    AND I.move_in_out = 1
) 
, hospital_date AS (
    SELECT 
        REPLACE(MAX(I.period_start_date) :: TEXT, ''-'', '''') AS hospital_start_date
    FROM
        pat_unique U
        CROSS JOIN LATERAL jsonb_to_recordset(U.in_out_visit_history_info) AS I
        (   ctl_no bigint,
            period_start_date date,
            from_facility bigint,
            move_in_out smallint
        )
    WHERE pat_id = (SELECT pat_id FROM ord_main_data)
    AND U.is_del = ''0''
    AND I.period_start_date IS NOT NULL
    AND ((I.move_in_out = 1 AND I.from_facility IS NULL)
    OR  I.move_in_out = 2)
)
SELECT dialysis_date.dialysis_start_date, hospital_date.hospital_start_date, ini_data.default_setting,
(CASE ord_main_data.anti_coagulant_amount::FLOAT >= 1
    WHEN TRUE THEN
        LPAD(split_part((ord_main_data.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
    ELSE
        (
        CASE ini_data.default_setting
    WHEN ''0'' THEN
        LPAD(split_part((ord_main_data.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
    WHEN ''1'' THEN
        LPAD(LPAD(split_part((ord_main_data.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 3, ''0''), 8, '' '')
  END
    )
END
) AS calculate_one_shot_amount
FROM ord_main_data, ini_data, dialysis_date, hospital_date', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '汎用）指示）透析条件', '2022-08-18 15:49:19.638', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-111, 'SELECT info ->>''period_start_date'' AS start_date
FROM 
(
	SELECT jsonb_array_elements(in_out_visit_history_info) AS info 
	FROM pat_unique 
	WHERE pat_id = @patId
) AS history
WHERE ((info ->>''move_in_out'' = ''1'' AND info ->>''from_facility'' IS null)
OR info ->>''move_in_out'' = ''2'')
AND info ->>''period_start_date'' IS NOT NULL
ORDER BY info ->>''period_start_date'' DESC
LIMIT 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, '日機装 透析実績[送信]当院開始日', '2022-06-10 11:59:15.000', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-499, 'select
		replace(min(I.period_start_date)::text,''-'','''') as dialysis_start_date
	from
		pat_unique U
			cross join lateral jsonb_to_recordset(U.in_out_visit_history_info) as I
			(ctl_no bigint,
			period_start_date date,
			period_start_day bigint,
			period_start_month bigint,
			period_start_year bigint,
			move_in_out smallint
 			)
 		left join ord_main ord on ord.pat_id = U.pat_id 
		where
			ord.ord_no = @ordNo
			and U.is_del = ''0''
			and (I.period_start_day is not null)
			and I.period_start_month is not null
			and I.period_start_year is not null
			and I.move_in_out = 1', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'で送信する透析導入日', '2023-06-16 17:45:38.506', CURRENT_TIMESTAMP, NULL);