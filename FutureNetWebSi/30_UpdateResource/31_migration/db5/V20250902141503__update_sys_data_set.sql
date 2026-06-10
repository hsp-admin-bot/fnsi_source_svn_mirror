DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-306102,-306104,-310001,-317106,-317112,-317113,-317124,-317140);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-306102, 'WITH id_info AS(
    SELECT
        coop.hosp_pat_id as hosp_pat_id
    FROM
        sys_coop_journal AS coop
    WHERE
        coop.pat_id  = @patId
),
item_info AS(
    SELECT
        UNNEST(string_to_array(COALESCE(
                    NULLIF(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) AS VALUE
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = ''P_hosp''
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''ACCEPT_SEND''
    AND info ->> ''key2'' = ''FILENAME_NUMBER''
)
SELECT
    TO_CHAR(current_timestamp, ''YYYYMMDD_HH24MISS'') || ''_'' || VALUE || ''_'' || LTRIM(
        hosp_pat_id::TEXT,
        ''0''
    ) || ''.dat'' AS filename
FROM
    id_info,item_info', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom再来受付連携ファイル名取得', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-306104, 'with pat_info as(
select
    staff_info ->> ''ctl_no'' as ctl_no,
    staff_info ->> ''disp_order'' as disp_order,
    staff_info ->> ''staff_cd'' as staff_cd,
    staff_info ->> ''is_main'' as is_main,
    staff_info ->> ''is_charge'' as is_charge,
    staff_info ->> ''is_puncture'' as is_puncture
from
    pat_main as pat
cross join
            lateral json_array_elements(
                pat.charge_staff_info::json
            ) staff_info
where
    pat.pat_id = @patId
    and staff_info ->> ''is_main'' = ''1''
order by
    staff_info ->> ''disp_order'' asc
limit 1
),
accept_send as(
select
    info ->> ''key2'' as key2,
    unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as VALUE
from
    mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
    facility_cd = @facilityCd
    and is_del = ''0''
    and info ->> ''key0'' = @key0
    and info ->> ''key1'' = ''ACCEPT_SEND''
)
select
    case
        (
        select
            VALUE
        from
            accept_send
        where
            key2 = ''DOCTOR_CLASSIFICATION''
        )
        when ''0'' then coalesce(staff_cd,(
        select
            VALUE
                from
                    accept_send
                where
                    key2 = ''FIXED_DOCTOR_CODE1''
            ))
        -- 0：患者の担当医１ （取得できない場合は固定医師コード1）
        when ''1'' then(
        select
            VALUE
        from
            accept_send
        where
            key2 = ''FIXED_DOCTOR_CODE1''
        )
        --1：固定医師コード１
        when ''2'' then(
        select
            VALUE
        from
            accept_send
        where
            key2 = ''FIXED_DOCTOR_CODE2''
        )
        --2：固定医師コード２
        when ''3'' then ''''
        --3：空白   
        else ''''
    end as staff_cd,
    (case
        when
        (
        select
            value
        from
            accept_send
        where
            key2 = ''DOCTOR_CLASSIFICATION''
        ) = ''0''
        and staff_cd is not null then 1
        else 0
    end) as is_transformation
from
    (
    select
        (
        select
            staff_cd
        from
            pat_info
            ) as staff_cd
    ) as T01', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom受付情報の「医師１」事前実行SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310001, 'SELECT
        UNNEST(string_to_array(COALESCE(
                    NULLIF(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) AS exam_institution_cd
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''EXAM_INSTITUTION_CD''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査オーダ連携用の[連携設定→検査機関コード]値取得', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317106, '
with admission_info AS(
    SELECT
        UNNEST(string_to_array(
                        info ->> ''value'','','')) AS ADMISSION_VALUE
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''KARTE_ORD_SEND''
    AND info ->> ''key2'' = ''ADMISSION_SUPPORTED''
),
device_info AS(
    SELECT
        UNNEST(string_to_array(COALESCE(
                    NULLIF(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) AS DEVICE_VALUE
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(
                ini.coop_ini_info::json
            ) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''KARTE_ORD_SEND''
    AND info ->> ''key2'' = ''DEVICE_IDENTIFICATION_NAME''
)
SELECT
    TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS'') || CASE ADMISSION_VALUE
        WHEN ''0'' THEN ''.xml''        
        WHEN ''1'' THEN ''_'' || ADMISSION_VALUE || ''_'' || DEVICE_VALUE || ''.xml''
    END AS filename
FROM
    admission_info, device_info', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicomカルテ記載連携(透析経過データ連携)ファイル名取得', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317112, 'with puncture_user_value as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as value
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = @key0
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
),
puncture_user_info as (
	select
        ord.rst_puncture_user_info ->>''user_last_name_1'' as user_last_name_1,
        ord.rst_puncture_user_info ->>''user_first_name_1'' as user_first_name_1,
        ord.rst_puncture_user_info ->>''user_last_name_2'' as user_last_name_2,
        ord.rst_puncture_user_info ->>''user_first_name_2'' as user_first_name_2
    from
        ord_main as ord
    where
		ord.ord_no = @ordNo
)
select
	case (
		select
			value
		from
			puncture_user_value
		where
			key2 = ''PUNCTURE_USER_CLASSIFICATION''
	)
		when ''0'' then coalesce(
      nullif(
        (select
          user_last_name_1 || user_first_name_1
        from
          puncture_user_info),'''')
      ,(
			  coalesce(nullif(
          (select
            user_last_name_2 || user_first_name_2
          from
            puncture_user_info),'''')
		    ,(
          	select
          		value
			      from
				      puncture_user_value
			      where
				      key2 = ''FIXED_DOCTOR_NAME1''
          )
        )
      )
    )
		when ''1'' then coalesce(
      nullif(
        (select 
          user_last_name_2 || user_first_name_2
        from 
          puncture_user_info),'''')
        ,(
    			select
		    		value
			    from
				    puncture_user_value
			    where
				    key2 = ''FIXED_DOCTOR_NAME1''
		))
		when ''2'' then (
			select
				value
			from
				puncture_user_value
			where
				key2 = ''FIXED_DOCTOR_NAME1''
		)
		when ''3'' then(
			select
				value
			from
				puncture_user_value
			where
				key2 = ''FIXED_DOCTOR_NAME2''
		)
		when ''4'' then(
			select
				value
			from
				puncture_user_value
			where
				key2 = ''FIXED_NURSE_NAME1''
		)
		when ''5'' then(
			select
				value
			from
				puncture_user_value
			where
				key2 = ''FIXED_NURSE_NAME2''
		)
	end as e01', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携穿刺者取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317113, '
with return_user_value as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as value
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = @key0
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
),
return_user_info as (
	select
		ord.rst_return_user_info ->>''user_last_name_1'' as user_last_name_1,
		ord.rst_return_user_info ->>''user_first_name_1'' as user_first_name_1,
		ord.rst_return_user_info ->>''user_last_name_2'' as user_last_name_2,
		ord.rst_return_user_info ->>''user_first_name_2'' as user_first_name_2
	from 
		ord_main as ord
where
	ord.ord_no = @ordNo	
)
select
	case (
		select
			value
		from
			return_user_value
		where
			key2 = ''RECOVERY_USER_CLASSIFICATION''
	)
		when ''0'' then coalesce(
      nullif(
        (select
          user_last_name_1 || user_first_name_1
        from
          return_user_info),'''')
      ,(
		coalesce(nullif(
          (select
            user_last_name_2 || user_first_name_2
          from
            return_user_info),'''')
		    ,(
          	select
          		value
			      from
				      return_user_value
			      where
				      key2 = ''FIXED_DOCTOR_NAME1''
          )
        )
      )
    )
		when ''1'' then coalesce(
      nullif(
        (select 
          user_last_name_2 || user_first_name_2
        from 
          return_user_info),'''')
        ,(
    			select
		    		value
			    from
				    return_user_value
			    where
				    key2 = ''FIXED_DOCTOR_NAME1''
		))
		when ''2'' then (
			select
				value
			from
				return_user_value
			where
				key2 = ''FIXED_DOCTOR_NAME1''
		)
		when ''3'' then(
			select
				value
			from
				return_user_value
			where
				key2 = ''FIXED_DOCTOR_NAME2''
		)
		when ''4'' then(
			select
				value
			from
				return_user_value
			where
				key2 = ''FIXED_NURSE_NAME1''
		)
		when ''5'' then(
			select
				value
			from
				return_user_value
			where
				key2 = ''FIXED_NURSE_NAME2''
		)
	end as e01', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携回収者取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317124, '
with info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as value
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = @key0
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
	(
		select
			value
		from
			info
		where
			key2 = ''COMMENT''
	) as e01,--入力内容を表すコメント
	(
		select
			value
		from
			info
		where
			key2 = ''MEDICAL_INTERVIEWS_INPUT_DATA_FILE_INFO_ID''
	) as e02,--問診入力データファイル情報ＩＤ
	(
		select
			value
		from
			info
		where
			key2 = ''DESCRIBED_CONTENT_TYPE''
	) as e03--記載内容種別', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携コメント・問診入力データファイル情報ID・記載内容種別取得SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317140, 'with mst_coop_ini_info as(
select
	info ->> ''key2'' as key2,
	unnest(string_to_array(coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ), '','')) as VALUE
from
	mst_coop_ini as ini
cross join
            lateral json_array_elements(
                ini.coop_ini_info::json
            ) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and info ->> ''key0'' = @key0
	and info ->> ''key1'' = ''KARTE_ORD_SEND''
)
select
	(
	select
		value
	from
		mst_coop_ini_info
	where
		key2 = ''ADMISSION_SUPPORTED''
	) as admission_supported,
	(
	select
		value
	from
		mst_coop_ini_info
	where
		key2 = ''ELAPSED_DATA_OUTPUT''
	) as elapsed_data_output
', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携出力有無事前取得用SQL', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
