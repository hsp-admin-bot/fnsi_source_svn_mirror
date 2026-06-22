INSERT INTO ntss.sys_data_set (sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
	 (-307127,'WITH oxygen_procedure_value as(
	--酸素手技コードと酸素手技名称
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as value,
        info ->> ''key2'' as key2
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''OXYGEN_PROCEDURE''
)
, ord_rst_treatment_info as (
	--酸素数量
    select
        ord_rst_treatment_info ->> ''oxygen_amount'' as count
    from
        ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) ord_rst_treatment_info
    where
        ord_no = @ordNo
        and ord_main.is_del = ''0''
)
, oxygen_item_value as(
	--酸素薬剤コードと薬剤名
    select
        unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info ->> ''value'',
                        ''''
                    ),
                    info ->> ''default_v''
                ),
                '',''
            )
        ) as value,
        info ->> ''key2'' as key2
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''OXYGEN''
)
, ord_medi_infos as (
	--通常薬剤の実施済みの治療情報.実績：投与薬剤情報
	select
		100 + t.idx as registration_order,
		ord_medi_info ->> ''cd'' as medicine_cd,
		round((ord_medi_info ->> ''amount'') :: numeric, 2) as amount,
		mst_medicine.class_cd as class_cd,
		ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
	from
		ord_main
		cross join lateral json_array_elements(ord_main.rst_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
		LEFT JOIN mst_medicine on ord_medi_info ->> ''cd'' = mst_medicine.medicine_cd :: text
		LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
	where
		ord_no = @ordNo
		and ord_main.is_del = ''0''
		and ord_medi_info ->> ''effect_flg'' = ''1''
		and ord_medi_info ->> ''medicine_type'' = ''1''
		and (ord_medi_info ->> ''amount'') :: numeric > 0
		and (
			ord_medi_info ->> ''procedure_name'' is null
			OR ord_medi_info ->> ''procedure_name'' NOT IN (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
		)
		and (
			mst_medicine_class.class_name is null
			or mst_medicine_class.class_name not in(''内服'',''頓服'',''外用'',''自己注射'',''手術・麻酔'',''処置'')
		)
	UNION
	ALL
    --通常薬剤の治療情報.実績：愁訴処置情報
	select
		200 + t.idx as registration_order,
		ord_treatment_info ->> ''treat_medicine_cd'' as medicine_cd,
		round((ord_treatment_info ->> ''amount'') :: numeric, 2) as amount,
		mst_medicine.class_cd as class_cd,
		ord_treatment_info->>''medicine_type'' as medicine_type,
		null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
		null as date_interval
	from
		ord_main
		cross join lateral json_array_elements(ord_main.rst_treatment_info :: json) WITH ORDINALITY as t(ord_treatment_info, idx)
		LEFT JOIN mst_medicine on ord_treatment_info ->> ''treat_medicine_cd'' = mst_medicine.medicine_cd :: text
		LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
	where
		ord_no = @ordNo
		and ord_main.is_del = ''0''
		and ord_treatment_info ->> ''medicine_type'' = ''1''
		and (ord_treatment_info ->> ''amount'') :: numeric > 0
		and (
			ord_treatment_info ->> ''procedure_name'' is null
			OR ord_treatment_info ->> ''procedure_name'' NOT IN (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
		)
		and (
			mst_medicine_class.class_name is null
			or mst_medicine_class.class_name not in(''内服'',''頓服'',''外用'',''自己注射'',''手術・麻酔'',''処置'')
		)
	UNION
	ALL
    --調整薬剤の治療情報.実績：投与薬剤情報
	select
		100 + t.idx as registration_order,
		medi_mix_info ->> ''cd'' as medicine_cd,
		CASE
			medi_mix_info ->> ''solvent''
			WHEN ''0'' THEN round(
				(ord_medi_info ->> ''amount'') :: NUMERIC * (medi_mix_info ->> ''amount'') :: NUMERIC,
				2
			)
			WHEN ''1'' THEN round((medi_mix_info ->> ''amount'') :: NUMERIC, 2)
		END as amount,
		mst_medicine.class_cd as class_cd,
		ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
	from
		ord_main
		cross join lateral json_array_elements(ord_main.rst_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
		LEFT JOIN mst_medicine_mix on ord_medi_info ->> ''cd'' = mst_medicine_mix.medicine_mix_cd :: text
		LEFT JOIN json_array_elements(mst_medicine_mix.mix_info :: json) medi_mix_info on true
		LEFT JOIN mst_medicine on medi_mix_info ->> ''cd'' = mst_medicine.medicine_cd :: text
		LEFT JOIN mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
	where
		ord_no = @ordNo
		and ord_main.is_del = ''0''
		and ord_medi_info ->> ''effect_flg'' = ''1''
		and ord_medi_info ->> ''medicine_type'' = ''2''
		and (ord_medi_info ->> ''amount'') :: numeric > 0
		and (
			ord_medi_info ->> ''procedure_name'' is null
			OR ord_medi_info ->> ''procedure_name'' NOT IN (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
		)
		and (
			mst_medicine_class.class_name is null
			or mst_medicine_class.class_name not in(''内服'',''頓服'',''外用'',''自己注射'',''手術・麻酔'',''処置'')
		)
	UNION
	ALL
    --調整薬剤の治療情報.実績：愁訴処置情報
	select
		200 + t.idx as registration_order,
		medi_mix_info ->> ''cd'' as medicine_cd,
		CASE
			medi_mix_info ->> ''solvent''
			WHEN ''0'' THEN round(
				(ord_treatment_info ->> ''amount'') :: NUMERIC * (medi_mix_info ->> ''amount'') :: NUMERIC,
				2
			)
			WHEN ''1'' THEN round((medi_mix_info ->> ''amount'') :: NUMERIC, 2)
		END as amount,
		mst_medicine.class_cd as class_cd,
		ord_treatment_info->>''medicine_type'' as medicine_type,
		null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
		null as date_interval
	from
		ord_main
		cross join lateral json_array_elements(ord_main.rst_treatment_info :: json)  WITH ORDINALITY as t(ord_treatment_info, idx)
		LEFT JOIN mst_medicine_mix on ord_treatment_info ->> ''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd :: text
		LEFT JOIN json_array_elements(mst_medicine_mix.mix_info :: json) medi_mix_info on true
		LEFT JOIN mst_medicine on medi_mix_info ->> ''cd'' = mst_medicine.medicine_cd :: text
		LEFT JOIN mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
	where
		ord_no = @ordNo
		and ord_main.is_del = ''0''
		and ord_treatment_info ->> ''medicine_type'' = ''2''
		and (ord_treatment_info ->> ''amount'') :: numeric > 0
		and (
			ord_treatment_info ->> ''procedure_name'' is null
			OR ord_treatment_info ->> ''procedure_name'' NOT IN (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
		)
		and (
			mst_medicine_class.class_name is null
			or mst_medicine_class.class_name not in(''内服'',''頓服'',''外用'',''自己注射'',''手術・麻酔'',''処置'')
		)
 )
 , medicine_in_hospital_cd_no as (
	--薬剤マスタの参照する連携コード
	select
		coalesce(
			nullif(info ->> ''value'', ''''),
			info ->> ''default_v''
		) as value
	from
		mst_coop_ini as ini
		cross join LATERAL json_array_elements(ini.coop_ini_info :: json) info
	where
		facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MST''
		and info ->> ''key2'' = ''MEDICINE_IN_HOSPITAL_CD_NO''
 )
 , medicine_add_flag as (
	--薬剤合算フラグ
	select
		coalesce(
			nullif(info ->> ''value'', ''''),
			info ->> ''default_v''
		) as value
	from
		mst_coop_ini as ini
		cross join LATERAL json_array_elements(ini.coop_ini_info :: json) info
	where
		facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
		and info ->> ''key2'' = ''DISTINCT_MEDICINE_FLAG''
 )
 , facility_medicine_order as (
    -- 施設設定マスタ(No.107)
    select 
		row_number () over () as setting_order, -- 適用順 
        TO_NUMBER(datt.setting_value::text, ''999999999999'') as setting_value -- 設定値
    from (
            select TO_NUMBER(
                    (
                        unnest(
                            string_to_array(
                                (
                                    select mst_f.value as rtt
                                    from mst_facility_setting as mst_f
                                    where mst_f.facility_setting_no = ''3007''
                                        and mst_f.facility_cd = @facilityCd
                                ),
                                '',''
                            )
                        )
                    ),
                    ''999999999999''
                ) as setting_value
        ) as datt
 )
 , medi_order as (
    -- 薬剤マスタの並び順
    select index_no::int as medi_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_code,
        order_cd->>''name'' as name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine''
 )
 , medi_class_order as (
    -- 薬剤分類マスタの並び順
    select index_no::int as medi_class_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_class_code,
        order_cd->>''name'' as class_name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine_class''
 )
 , timing_order as (
    -- 投与タイミングマスタの並び順
  select
    index_no ::int as timing_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') as timing_code
  from mst_selector
  cross join LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality as tmp(order_cd, index_no)
  where facility_cd = @facilityCd
    and master_physical_name = ''mst_medicate_timing''
 )
 , procedure_order as (
    -- 手技マスタの並び順
  select
    index_no ::int as procedure_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') as procedure_code
  from mst_selector
  cross join LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality as tmp(order_cd, index_no)
  where facility_cd = @facilityCd
    and master_physical_name = ''mst_procedure''
 )
 , mst_medi as (
    select medicine_cd,
        medicine_name,
        class_cd,
        medi_class_order.class_name as class_name,
        unit,
        in_hospital_cd_1,
        in_hospital_cd_2,
        in_hospital_cd_3,
        in_hospital_cd_4,
        medi_order.medi_code_order,
        medi_class_order.medi_class_code_order
    from mst_medicine mmd
        left join medi_order on mmd.medicine_cd = medi_order.medi_code
        left join medi_class_order on mmd.class_cd = medi_class_order.medi_class_code
    where facility_cd = @facilityCd
 )
 , final_medi_info as (
	select
		CASE
			(
				select
					value
				from
					medicine_in_hospital_cd_no
			)
			WHEN ''1'' THEN left(med.in_hospital_cd_1, 20)
			WHEN ''2'' THEN left(med.in_hospital_cd_2, 20)
			WHEN ''3'' THEN left(med.in_hospital_cd_3, 20)
			WHEN ''4'' THEN left(med.in_hospital_cd_4, 20)
		END as code,
		left(med.medicine_name, 80) as name,
		TRIM(
			TO_CHAR(
				SUM(amount),
				''FM99999.99''
			),
			''.''
		) as count,
		MIN(med.unit) as unit,
        MIN(med.class_cd) as class_cd,
		MIN(omi.registration_order) as registration_order,
        MIN(mst_medi.medi_code_order) as medi_code_order,
        MIN(mst_medi.medi_class_code_order) as class_code_order,
        MIN(omi.medicine_type::int) as medicine_type_order,
        MIN(t.timing_code_order) as timing_code_order,
        MIN(p.procedure_code_order) as procedure_code_order,
        MIN(omi.date_interval::int) as date_interval 
	from
		ord_medi_infos omi
		LEFT JOIN mst_medicine med on omi.medicine_cd = med.medicine_cd :: text
		left join mst_medi on med.class_cd = mst_medi.class_cd and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
	where
		(
			select
				value
			from
				medicine_add_flag
		) = ''1''
	group by
		code,
		name
		union all
	select
		CASE
			(
				select
					value
				from
					medicine_in_hospital_cd_no
			)
			WHEN ''1'' THEN left(med.in_hospital_cd_1, 20)
			WHEN ''2'' THEN left(med.in_hospital_cd_2, 20)
			WHEN ''3'' THEN left(med.in_hospital_cd_3, 20)
			WHEN ''4'' THEN left(med.in_hospital_cd_4, 20)
		END as code,
		left(med.medicine_name, 80) as name,
		TRIM(
			TO_CHAR(
				amount,
				''FM99999.99''
			),
			''.''
		) as count,
		med.unit,
		med.class_cd,
		omi.registration_order as registration_order,
        mst_medi.medi_code_order as medi_code_order,
        mst_medi.medi_class_code_order as class_code_order,
        omi.medicine_type::int as medicine_type_order,
        t.timing_code_order as timing_code_order,
        p.procedure_code_order as procedure_code_order,
        omi.date_interval::int as date_interval 
	from
		ord_medi_infos omi
		LEFT JOIN mst_medicine med on omi.medicine_cd = med.medicine_cd :: text
		left join mst_medi on med.class_cd = mst_medi.class_cd and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
	where
		(
			select
				value
			from
				medicine_add_flag
		) = ''0''
 )
 , oxygen_all as (
	--酸素手技
	select
		1 as item_sort_no,
    	(
        select
            value
        from
            oxygen_procedure_value
        where
            key2 = ''MEDI_CD''
    	) as code,
    	(
        select
            value
        from
            oxygen_procedure_value
        where
            key2 = ''MEDI_NAME''
    	) as name,
    	null as count,
    	null as unit,
    	null as cutoff,
    	null as sort_key
	union all
	--酸素
	select
		2 as item_sort_no,
    	(
        select
            value
        from
            oxygen_item_value
        where
            key2 = ''MEDI_CD''
    	) as code,
    	(
        select
            value
        from
            oxygen_item_value
        where
            key2 = ''MEDI_NAME''
    	) as name,
    	TRIM(
        	TO_CHAR(
            	ROUND(SUM(ord_rst_treatment_info.count :: numeric), 2),
            	''FM99999.99''
        	),
        	''.''
    	) as count,
    	(
        select
            value
        from
            oxygen_item_value
        where
            key2 = ''UNIT''
    	) as unit,
    	null as cutoff,
    	null as sort_key
	from
    	ord_rst_treatment_info
	union all
	--薬剤分類が未確認の薬剤
	select 
		3 as item_sort_no,
		f.code as code,
        f.name as name,
        f.count as count,
        f.unit as unit,
		null as cutoff,
        ROW_NUMBER() OVER(
            order by 
            case  
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval end
        )::text as sort_key
 from final_medi_info f
 )
 select oxygen_all.code as code,
    oxygen_all.name as name,
    oxygen_all.count as count,
    oxygen_all.unit as unit,
    oxygen_all.cutoff as cutoff,
    row_number() over (
        order by item_sort_no,
            sort_key
    ) as seq_no
from oxygen_all
order by seq_no',2,'[]','0','{"applications": [4]}',NULL,NULL,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);
