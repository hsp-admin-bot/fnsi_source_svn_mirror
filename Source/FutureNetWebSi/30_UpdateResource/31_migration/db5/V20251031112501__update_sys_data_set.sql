DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-317112, -317113, -317114);
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
          btrim(
            COALESCE(user_last_name_1, '''')
            || COALESCE(user_first_name_1, '''')
          )
        from
          puncture_user_info),'''')
      ,(
			  coalesce(nullif(
          (select
            btrim(
              COALESCE(user_last_name_2, '''')
              || COALESCE(user_first_name_2, '''')
            )
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
          btrim(
            COALESCE(user_last_name_2, '''')
            || COALESCE(user_first_name_2, '''')
          )
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
	end as e01', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携穿刺者取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
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
          btrim(
            COALESCE(user_last_name_1, '''')
            || COALESCE(user_first_name_1, '''')
          )
        from
          return_user_info),'''')
      ,(
		coalesce(nullif(
          (select
            btrim(
              COALESCE(user_last_name_2, '''')
              || COALESCE(user_first_name_2, '''')
            )
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
          btrim(
            COALESCE(user_last_name_2, '''')
            || COALESCE(user_first_name_2, '''')
          )
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
	end as e01', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携回収者取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-317114, '
with charge_user_value as(
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
charge_user_info as (
    select
        ord.rst_charge_user_info ->>''user_last_name_1'' as user_last_name_1,
        ord.rst_charge_user_info ->>''user_first_name_1'' as user_first_name_1,
        ord.rst_charge_user_info ->>''user_last_name_2'' as user_last_name_2,
        ord.rst_charge_user_info ->>''user_first_name_2'' as user_first_name_2
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
            charge_user_value
        where
            key2 = ''CHARGE_USER_CLASSIFICATION''
    )
        when ''0'' then coalesce(
      nullif(
        (select
          btrim(
            COALESCE(user_last_name_1, '''')
            || COALESCE(user_first_name_1, '''')
          )
        from
          charge_user_info),'''')
      ,(
        coalesce(nullif(
          (select
            btrim(
              COALESCE(user_last_name_2, '''')
              || COALESCE(user_first_name_2, '''')
            )
          from
            charge_user_info),'''')
            ,(
            select
                value
                  from
                      charge_user_value
                  where
                      key2 = ''FIXED_DOCTOR_NAME1''
          )
        )
      )
    )
        when ''1'' then coalesce(
      nullif(
        (select
          btrim(
            COALESCE(user_last_name_2, '''')
            || COALESCE(user_first_name_2, '''')
          )
        from
          charge_user_info),'''')
        ,(
                select
                    value
                from
                    charge_user_value
                where
                    key2 = ''FIXED_DOCTOR_NAME1''
        ))
        when ''2'' then (
            select
                value
            from
                charge_user_value
            where
                key2 = ''FIXED_DOCTOR_NAME1''
        )
        when ''3'' then(
            select
                value
            from
                charge_user_value
            where
                key2 = ''FIXED_DOCTOR_NAME2''
        )
        when ''4'' then(
            select
                value
            from
                charge_user_value
            where
                key2 = ''FIXED_NURSE_NAME1''
        )
        when ''5'' then(
            select
                value
            from
                charge_user_value
            where
                key2 = ''FIXED_NURSE_NAME2''
        )
    end as e01', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom透析経過データ連携担当者取得SQL', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);