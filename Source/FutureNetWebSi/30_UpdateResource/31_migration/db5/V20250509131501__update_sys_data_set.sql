DELETE FROM sys_data_set WHERE sql_cd IN (-306001, -307001, -307002, -307003, -307004, -307008, -307009, -307016, -307017, -307033, -307063, -307064, -307065, -307066, -307068, -307069, -307071, -307073, -307074, -307075, -307076, -307077, -307078, -307079, -307080, -307081, -307082, -307083, -307084, -307085, -307086, -307087, -307088, -307089, -307090, -307091, -307092, -307093, -307094, -307095, -307096, -307097, -307098, -307099, -307101, -307102, -307103, -307104, -307105, -307106, -307107, -307108, -307109, -307110, -307111, -307112, -307113, -307114, -307115, -307116, -307117, -307118, -307119, -307120, -307121, -307122, -307123, -307124, -307125, -307126, -307127, -307128, -307129, -307130, -307131, -307132, -307133, -307134, -307135, -307136, -307137, -307138, -307139, -307140, -458);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307140, 'with model_type as (
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) as info
    where ini.facility_cd = @facilityCd
        and ini.is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''MODEL_TYPE''
)

select
  to_char(ord.rst_start_date,''YYYYMMDDHH24MISS'') as rst_start_date,--透析開始日時
  (select value from model_type) as model_type--モデルタイプ
from
  ord_main as ord
where
  ord.ord_no = @ordNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307139, 'select
  @modelType ||
  ''_'' ||
  case when ltrim(ppm.hosp_pat_id,''0'')='''' then ''0''
  else ltrim(ppm.hosp_pat_id,''0'') end ||
  ''_'' ||
  @rstStartDate ||
	''_'' ||
  to_char(current_timestamp, ''YYYYMMDDHH24MISS_'') ||
  ''0001'' ||
  ''.xml'' as filename
from
  ntss.pat_personal_main as ppm
where
  pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 新規/更新 ファイル名取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307140, "field_name": "rst_start_date", "replace_var": "@rstStartDate"}, {"sql_cd": -307140, "field_name": "model_type", "replace_var": "@modelType"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307138, 'WITH application_name as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' = ''TREATMENT''
),
default_medicine_group as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''DEFAULT_MEDICINE_GROUP''
),
-- 
-- 投与情報
-- 
medicine_order_units_num as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
medicine_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from medicine_order_units_num,
        generate_series(1, medicine_order_units_num.value) as i
),
medicine_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_MEDICINE_INFO
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
),
medicine_classes as (
    -- 投与薬剤として出力される薬剤分類名
    select idx.suffix,
        msi.value
    from medicine_setting_info as msi
        join medicine_unit_indices as idx on msi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 注射情報
-- 
injection_order_units_num as (
    -- 出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
injection_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from injection_order_units_num,
        generate_series(1, injection_order_units_num.value) as i
),
injection_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_INJECTION_INFOを取得
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
),
injection_procedure_names as (
    -- 注射情報として出力する手技名を取得
    select idx.suffix,
        isi.value
    from injection_setting_info as isi
        join injection_unit_indices as idx on isi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 手術・麻酔
-- 
surgery_medicine_class_name as (
    -- 手術・麻酔として出力する薬剤分類名を取得
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' = ''SURGERY''
),
-- 
-- 処置
-- 
treatment_num as (
    -- 処置として出力する対象の薬剤分類の数 (TREATMENT_NUM)
    select unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' = ''TREATMENT_NUM''
    limit 1
), treatment_number_series as (
    -- TREATMENT_NUMの数を基にTREATMENT_NAME_{0:D2} を生成
    select LPAD(n::text, 2, ''0'') as padded_num
    from generate_series(
            1,
            (
                select value
                from treatment_num
            )::numeric
        ) as t(n)
),
treatment_name_keys as (
    -- TREATMENT_NAME_{0:D2} の key を生成
    select ''TREATMENT_NAME_'' || padded_num as name_key
    from treatment_number_series
),
treatment_key_value_pairs as (
    -- TREATMENT_NAME_{0:D2} の key/value の組み合わせを出力
    select info->>''key2'' as key,
        unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' like ''TREATMENT_NAME_%''
),
treatment_names as (
    -- TREATMENT_NAME_{0:D2} の名前を取得
    select treatment_name_keys.name_key,
        kv.value as treatment_name
    from treatment_name_keys
        join treatment_key_value_pairs kv on kv.key = treatment_name_keys.name_key
),
class_names as (
    select treatment_name as value
    from treatment_names
    union
    select value
    from surgery_medicine_class_name
    union
    select value
    from medicine_classes
),
unreferenced_medicines as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
),
treatment_in_hospital_cd_alpha AS (
	-- 使用する治療方法の連携コードアルファベット
	SELECT coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) AS alpha_value
	FROM mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
	WHERE facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info->>''key0'', '''') = @key0
		AND info->>''key1'' = ''MST''
		AND info->>''key2'' = ''TREATMENT_IN_HOSPITAL_CD_ALPHA''
),
treatment_in_hospital_cd_no AS (
	-- 使用する治療方法の連携コード番号
	SELECT coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) AS no_value
	FROM mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
	WHERE facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info->>''key0'', '''') = @key0
		AND info->>''key1'' = ''MST''
		AND info->>''key2'' = ''TREATMENT_IN_HOSPITAL_CD_NO''
),
addition_in_hospital_cd_no AS (
	-- 使用する加算/管理科項目の連携コード番号
	SELECT coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) AS no_value
	FROM mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
	WHERE facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info->>''key0'', '''') = @key0
		AND info->>''key1'' = ''MST''
		AND info->>''key2'' = ''ADDITION_IN_HOSPITAL_CD_NO''
),
pat_dial_diff_data AS (
	-- 患者の透析困難情報
	SELECT obj->>''is_main'' AS is_main,
		obj->>''dial_diff_cd'' AS dial_diff_cd
	FROM (
			SELECT jsonb_array_elements(replace(@dialDiffCds, '''''''', ''"'')::jsonb) AS obj
		) t
),
mst_selector_dial_diff_data as (
	-- マスタ並び順から取得した透析困難
	select row_number() over () as sort_no,
		item->>''code'' as code,
		item->>''name'' as name,
		item->>''isDel'' as is_del,
		item->>''isDisp'' as is_disp
	from (
			select jsonb_array_elements(order_settings->''items'') as item
			from mst_selector
			where facility_cd = @facilityCd
				and master_physical_name = ''mst_dialysis_difficulty''
		) t
),
dial_diff_in_hospital_cd_no as (
	-- 使用する透析困難の連携コード番号
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as no_value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''MST''
		and info->>''key2'' = ''DIALYSIS_DIFFICULTY_HOSPITAL_CD_NO''
),
dialysis_output_setting as (
	-- 透析困難コメント・透析時間の出力設定
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as no_value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DIFFCOMMENT_DIALTIME_FLG''
),
addition_info as(
	-- オーダから取得した加算・管理科情報
	select ord_addition_info->>''cd'' as code
	from ord_main
		cross join lateral json_array_elements(ord_main.addition_info::json) ord_addition_info
	where ord_main.ord_no = @ordNo
),
addition_key_value as(
	-- 加算項目キー
	select unnest(
			string_to_array(
				coalesce(
					nullif(info->>''value'', ''''),
					info->>''default_v''
				),
				'',''
			)
		) as VALUE
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_RECE_MNG_INFO''
		and info->>''key2'' = ''RECE_MNG_GENERAL_KEY''
),
add_treat_item_num as (
	-- 追加する治療項目数を取得
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''ADD_TREAT_ITEM_NUM''
),
key_nums as (
	-- 追加する治療項目数の数値"{0:D2}"を生成
	select LPAD(n::text, 2, ''0'') as padded_num
	from generate_series(
			1,
			(
				select value::integer
				from ADD_TREAT_ITEM_NUM
			)
		) as t(n)
),
target_keys as (
	-- 追加する治療項目のコードと名称を連携設定から取得するためのkeyを生成
	select ''ADD_TREAT_ITEM_CODE_'' || padded_num as code_key,
		''ADD_TREAT_ITEM_NAME_'' || padded_num as name_key
	from key_nums
),
flat_kv as (
	--	ADD_TREAT_ITEM_CODEとADD_TREAT_ITEM_NAMEのkey/valueの組み合わせを出力
	select info->>''key2'' as key,
		unnest(
			string_to_array(
				coalesce(
					nullif(info->>''value'', ''''),
					info->>''default_v''
				),
				'',''
			)
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
),
code_values as (
	-- flat_kvからADD_TREAT_ITEM_CODEの値のみ抽出
	select key_nums.padded_num,
		kv.value as code
	from key_nums
		join target_keys on target_keys.code_key = ''ADD_TREAT_ITEM_CODE_'' || key_nums.padded_num
		join flat_kv kv on kv.key = target_keys.code_key
),
name_values as (
	-- flat_kvからADD_TREAT_ITEM_NAMEの値のみ抽出
	select key_nums.padded_num,
		kv.value as name
	from key_nums
		join target_keys on target_keys.name_key = ''ADD_TREAT_ITEM_NAME_'' || key_nums.padded_num
		join flat_kv kv on kv.key = target_keys.name_key
),
dialyzer_unit as (
	-- ダイアライザの単位
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as unit
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DIALYZER_UNIT''
),
dialyzer_in_hospital_cd_no as (
	--　使用するダイアライザの連携コード番号
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''MST''
		and info->>''key2'' = ''DIALYZER_IN_HOSPITAL_CD_NO''
),
primary_membrane_info as (
	--１次膜の取得
	select rst_cond_info->''7''->>''value'' as equipment_cd
	from ord_main
	where ord_no = @ordNo
		and is_del = ''0''
),
secondary_membrane_info as (
	--2次膜の取得
	select rst_cond_info->''8''->>''value'' as equipment_cd
	from ord_main
	where ord_no = @ordNo
		and is_del = ''0''
),
equipment_in_hospital_cd_no as (
	--医療材料マスタの参照する連携コード
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''MST''
		and info->>''key2'' = ''EQUIPMENT_IN_HOSPITAL_CD_NO''
),
column_count as (
	-- 吸着カラムの数量
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''COLUMN_COUNT''
	limit 1
), column_info as (
	--吸着カラムの取得
	select null as idx,
		rst_cond_info->''6''->>''value'' as equipment_cd,
		cc.value as count
	from ord_main
		cross join column_count cc
	where ord_no = @ordNo
	and rst_cond_info->''6''->>''value'' != ''null''
),
equipment_info as (
	--穿刺針(SN)、穿刺針(SN以外)を除外した医療材料の取得
	select t.idx,
		t.equip_info->>''cd'' as equipment_cd,
		t.equip_info->>''amount'' as count
	from ord_main
		cross join lateral json_array_elements(ord_main.rst_equip_info::json) with ordinality as t(equip_info, idx)
	where ord_no = @ordNo
		and is_del = ''0''
		and equip_info->>''class_type'' not in (''2'', ''3'')
),
medi_hospital_cd as (
	-- 使用する薬剤の連携コード番号
	select unnest(
			string_to_array(
				coalesce(
					nullif(info->>''value'', ''''),
					info->>''default_v''
				),
				'',''
			)
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''MST''
		and info->>''key2'' = ''MEDICINE_IN_HOSPITAL_CD_NO''
),
dialysate_info as (
	-- 透析液を取得
	select ord_main.rst_cond_info,
		mst_medicine.medicine_cd,
		mst_medicine.medicine_name,
		mst_medicine.unit_second,
		mst_medicine.in_hospital_cd_1,
		mst_medicine.in_hospital_cd_2,
		mst_medicine.in_hospital_cd_3,
		mst_medicine.in_hospital_cd_4,
		mst_treatment.device_mode
	from ord_main
		left join mst_medicine on mst_medicine.medicine_cd::text = ord_main.rst_cond_info->''15''->>''value''
		left join mst_treatment on ord_main.rst_treatment_cd = mst_treatment.treatment_cd
	where ord_main.ord_no = @ordNo
		and ord_main.is_del = ''0''
		and ord_main.rst_cond_info->''15''->>''medicine_type'' = ''1''
),
infusion_info as (
	-- 補液情報の抽出
	select mst_medicine.medicine_cd,
		mst_medicine.medicine_name,
		mst_medicine.unit_second,
		mst_medicine.in_hospital_cd_1,
		mst_medicine.in_hospital_cd_2,
		mst_medicine.in_hospital_cd_3,
		mst_medicine.in_hospital_cd_4,
		ord_main.rst_cond_info->''22''->>''value'' as raw_count_value
	from ord_main
		left join mst_medicine on mst_medicine.medicine_cd::text = ord_main.rst_cond_info->''19''->>''value''
		left join mst_treatment on ord_main.rst_treatment_cd = mst_treatment.treatment_cd
	where ord_main.ord_no = @ordNo
		and ord_main.is_del = ''0''
		and ord_main.rst_cond_info->''19''->>''medicine_type'' = ''1'' 
		and mst_treatment.device_mode not in (4, 7, 8, 10) -- 治療方法（装置モード）が（OHF、OHDF、HD+補液、プログラム補液）の場合、補液は透析液に合算するため出力しない
),
anticoagulant_info as (
	-- 抗凝固剤を抽出
	select ord_main.rst_cond_info->''25''->>''value'' as medicine_cd,
		ord_main.rst_cond_info->''25''->>''medicine_type'' as medicine_type,
		ord_main.rst_cond_info->''26''->>''value'' as one_shot,
		ord_main.rst_cond_info->''28''->>''value'' as total_dose
	from ord_main
	where ord_main.ord_no = @ordNo
),
direct_anticoagulant as (
	-- 通常薬剤の抗凝固剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		left(med.medicine_name, 80) as name,
		ai.one_shot::numeric + ai.total_dose::numeric as count,
		med.unit as unit,
		mmc.class_type as class_type
	from anticoagulant_info ai
		left join mst_medicine med on ai.medicine_cd = med.medicine_cd::TEXT
		left join mst_medicine_class mmc on med.class_cd = mmc.class_cd
	where ai.medicine_type = ''1''
),
mixed_anticoagulant as (
	-- 調製薬剤の抗凝固剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		med.medicine_name as name,
		case
			when mi.value->>''amount'' = ''0'' or mi.value->>''amount'' = ''null'' then null
			when mi.value->>''solvent'' = ''1'' then (mi.value->>''amount'')::numeric
			when mi.value->>''solvent'' = ''0'' then ((ai.one_shot)::numeric + (ai.total_dose)::numeric ) * (mi.value->>''amount'')::numeric
			else null
		end as count,
		med.unit as unit,
		mmc.class_type as class_type
	from mst_medicine_mix mmm
		inner join anticoagulant_info ai on ai.medicine_cd::integer = mmm.medicine_mix_cd
		cross join lateral jsonb_array_elements(mmm.mix_info) as mi(value)
		left join mst_medicine med on med.medicine_cd = (mi.value->>''cd'')::integer
		left join mst_medicine_class mmc on med.class_cd = mmc.class_cd
	where ai.medicine_type = ''2''
),
medicine_add_flag as (
	-- 薬剤合算フラグ
	select unnest(
			string_to_array(
				coalesce(
					nullif(info->>''value'', ''''),
					info->>''default_v''
				),
				'',''
			)
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
		and info->>''key2'' = ''DISTINCT_MEDICINE_FLAG''
	limit 1
), ord_medi_info as (
	-- 投与薬剤情報
	select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
		ord_medi_info->>''cd'' as cd,
		ord_medi_info->>''name'' as name,
		ord_medi_info->>''amount'' as amount,
		ord_medi_info->>''unit'' as unit,
		mst_medicine.class_cd as class_cd,
		ord_medi_info->>''class_name'' as class_name,
		ord_medi_info->>''medicine_type'' as medicine_type,
		ord_medi_info->>''timing_cd'' as timing_cd,
		ord_medi_info->>''procedure_cd'' as procedure_cd,
		ord_medi_info->>''date_interval'' as date_interval
	from ord_main
		cross join lateral json_array_elements(ord_main.rst_medi_info::json) ord_medi_info
		inner join mst_medicine on (ord_medi_info->>''cd'')::numeric = mst_medicine.medicine_cd
	where ord_no = @ordNo
		and ord_medi_info->>''effect_flg'' = ''1''
	order by registration_order
),
ord_treat_info as (
	-- 愁訴処置情報
	select LPAD(ord_treat_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treat_info->>''row_no'', 10, ''0'') as registration_order,
		ord_treat_info->>''treat_medicine_cd'' as cd,
		ord_treat_info->>''treat_medicine_name'' as name,
		ord_treat_info->>''amount'' as amount,
		ord_treat_info->>''unit'' as unit,
		mst_medicine.class_cd as class_cd,
		mst_medicine_class.class_name as class_name,
		ord_treat_info->>''medicine_type'' as medicine_type,
		ord_treat_info->>''procedure_cd'' as procedure_cd
	from ord_main
		cross join lateral json_array_elements(ord_main.rst_treatment_info::json) ord_treat_info
		inner join mst_medicine on (ord_treat_info->>''treat_medicine_cd'')::numeric = mst_medicine.medicine_cd
        inner join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
	where ord_no = @ordNo
        and (ord_treat_info->>''medicine_type'')::numeric = 1
	union all
	select LPAD(ord_treat_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treat_info->>''row_no'', 10, ''0'') as registration_order,
		ord_treat_info->>''treat_medicine_cd'' as cd,
		ord_treat_info->>''treat_medicine_name'' as name,
		ord_treat_info->>''amount'' as amount,
		ord_treat_info->>''unit'' as unit,
		mst_medicine_mix.class_cd as class_cd,
		mst_medicine_class.class_name as class_name,
		ord_treat_info->>''medicine_type'' as medicine_type,
		ord_treat_info->>''procedure_cd'' as procedure_cd
	from ord_main
		cross join lateral json_array_elements(ord_main.rst_treatment_info::json) ord_treat_info
		left join mst_medicine_mix on (ord_treat_info->>''treat_medicine_cd'')::numeric = mst_medicine_mix.medicine_mix_cd
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
	where ord_no = @ordNo
        and (ord_treat_info->>''medicine_type'')::numeric = 2
),
facility_medicine_order as (
	-- 施設設定マスタ(No.107)
	select row_number () over () as setting_order -- 適用順 
,
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
),
medi_order as (
	-- 薬剤マスタの並び順
	select index_no::int as medi_code_order,
		TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_code,
		order_cd->>''name'' as name
	from mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
	where facility_cd = @facilityCd
		and master_physical_name = ''mst_medicine''
),
medi_class_order as (
	-- 薬剤分類マスタの並び順
	select index_no::int as medi_class_code_order,
		TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_class_code,
		order_cd->>''name'' as class_name
	from mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
	where facility_cd = @facilityCd
		and master_physical_name = ''mst_medicine_class''
),
timing_order as (
	select index_no::int as timing_code_order,
		TO_NUMBER(order_cd->>''code'', ''999999999999'') as timing_code
	from mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
	where facility_cd = @facilityCd
		and master_physical_name = ''mst_medicate_timing''
),
procedure_order as (
	select index_no::int as procedure_code_order,
		TO_NUMBER(order_cd->>''code'', ''999999999999'') as procedure_code
	from mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
	where facility_cd = @facilityCd
		and master_physical_name = ''mst_procedure''
),
mst_medi as (
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
),
ord_treat_medi_info as (
	-- 投与薬剤情報 通常薬剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		left(med.medicine_name, 80) as name,
		omi.amount::numeric as count,
		med.unit as unit,
		mst_medi.class_cd as class_cd,
		mst_medi.class_name as class_name,
		omi.registration_order as registration_order,
		mst_medi.medi_code_order as medi_code_order,
		mst_medi.medi_class_code_order as class_code_order,
		omi.medicine_type as medicine_type_order,
		t.timing_code_order::text as timing_code_order,
		p.procedure_code_order::text as procedure_code_order,
		omi.date_interval as date_interval
	from ord_medi_info omi
		left join mst_medicine med on omi.cd = med.medicine_cd::TEXT
		left join mst_medi on med.class_cd = mst_medi.class_cd
		and med.medicine_cd = mst_medi.medicine_cd
		left join timing_order t on t.timing_code = omi.timing_cd::numeric
		left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
	where omi.medicine_type = ''1''
	union all
	-- 投与薬剤情報 調製薬剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		med.medicine_name as name,
		case
			when mi.value->>''amount'' = ''0'' or mi.value->>''amount'' = ''null'' then null
			when mi.value->>''solvent'' = ''1'' then (mi.value->>''amount'')::numeric
			when mi.value->>''solvent'' = ''0'' then (omi.amount)::numeric * (mi.value->>''amount'')::numeric
			else null
		end as count,
		med.unit as unit,
		mst_medi.class_cd as class_cd,
		omi.class_name as class_name,
		omi.registration_order as registration_order,
		mst_medi.medi_code_order as medi_code_order,
		mst_medi.medi_class_code_order as class_code_order,
		omi.medicine_type as medicine_type_order,
		t.timing_code_order::text as timing_code_order,
		p.procedure_code_order::text as procedure_code_order,
		omi.date_interval as date_interval
	from mst_medicine_mix mmm
		inner join ord_medi_info omi on omi.cd::integer = mmm.medicine_mix_cd
		cross join lateral jsonb_array_elements(mmm.mix_info) as mi(value)
		left join mst_medicine med on med.medicine_cd = (mi.value->>''cd'')::integer
		left join mst_medi on med.class_cd = mst_medi.class_cd
		and med.medicine_cd = mst_medi.medicine_cd
		left join timing_order t on t.timing_code = omi.timing_cd::numeric
		left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
	where omi.medicine_type = ''2''
	union all
	-- 愁訴処置情報 通常薬剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		left(med.medicine_name, 80) as name,
		oti.amount::numeric as count,
		med.unit as unit,
		mst_medi.class_cd as class_cd,
		mst_medi.class_name as class_name,
		oti.registration_order as registration_order,
		mst_medi.medi_code_order as medi_code_order,
		mst_medi.medi_class_code_order as class_code_order,
		oti.medicine_type as medicine_type_order,
		null as timing_code_order,
		p.procedure_code_order::text as procedure_code_order,
		null as date_interval
	from ord_treat_info oti
		left join mst_medicine med on oti.cd = med.medicine_cd::TEXT
		left join mst_medi on med.class_cd = mst_medi.class_cd
		and med.medicine_cd = mst_medi.medicine_cd
		left join procedure_order p on p.procedure_code = oti.procedure_cd::numeric
	where oti.medicine_type = ''1''
	union all
	-- 愁訴処置情報 調製薬剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		med.medicine_name as name,
		case
			when mi.value->>''amount'' = ''0'' or mi.value->>''amount'' = ''null'' then null
			when mi.value->>''solvent'' = ''1'' then (mi.value->>''amount'')::numeric
			when mi.value->>''solvent'' = ''0'' then (oti.amount)::numeric * (mi.value->>''amount'')::numeric
			else null
		end as count,
		med.unit as unit,
		mst_medi.class_cd as class_cd,
		oti.class_name as class_name,
		oti.registration_order as registration_order,
		mst_medi.medi_code_order as medi_code_order,
		mst_medi.medi_class_code_order as class_code_order,
		oti.medicine_type as medicine_type_order,
		null as timing_code_order,
		p.procedure_code_order::text as procedure_code_order,
		null as date_interval
	from mst_medicine_mix mmm
		inner join ord_treat_info oti on oti.cd::integer = mmm.medicine_mix_cd
		cross join lateral jsonb_array_elements(mmm.mix_info) as mi(value)
		left join mst_medicine med on med.medicine_cd = (mi.value->>''cd'')::integer
		left join mst_medi on med.class_cd = mst_medi.class_cd
		and med.medicine_cd = mst_medi.medicine_cd
		left join procedure_order p on p.procedure_code = oti.procedure_cd::numeric
	where oti.medicine_type = ''2''
),
unreferenced_medicines_with_order as (
	-- 投薬済みで投薬情報、注射情報、手術麻酔、処置に出力されなかった薬剤
	select case
				(
					select value
					from medi_hospital_cd
				)
				when ''1'' then left(med.in_hospital_cd_1, 20)
				when ''2'' then left(med.in_hospital_cd_2, 20)
				when ''3'' then left(med.in_hospital_cd_3, 20)
			end as code,
			left(med.medicine_name, 80) as name,
			um.amount::numeric as count,
			med.unit as unit,
			mst_medi.class_cd as class_cd,
			mst_medi.class_name as class_name,
			um.registration_order::text as registration_order,
			mst_medi.medi_code_order as medi_code_order,
			mst_medi.medi_class_code_order as class_code_order,
			um.medicine_type as medicine_type_order,
			t.timing_code_order::text as timing_code_order,
			p.procedure_code_order::text as procedure_code_order,
			um.date_interval as date_interval
		from
			unreferenced_medicines um
			left join mst_medicine med on med.medicine_cd = um.medicine_cd::numeric
			left join mst_medi on med.class_cd = mst_medi.class_cd and med.medicine_cd = mst_medi.medicine_cd
			left join timing_order t on t.timing_code = um.timing_cd::numeric
			left join procedure_order p on p.procedure_code = um.procedure_cd::numeric
		where
			(
			select
				value
			from
				default_medicine_group
		        ) = (select value from application_name)
),
final_treatment_info as (
	-- 処置として出力する対象の薬剤
	select o.code,
		o.name,
		SUM(o.count::numeric) as count,
		-- group byに含めたくないので単一項目を取得するために集計関数MINを指定している
		MIN(o.unit) as unit,
		MIN(o.class_cd) as class_cd,
		MIN(o.registration_order) as registration_order,
		MIN(o.medi_code_order) as medi_code_order,
		MIN(o.class_code_order) as class_code_order,
		MIN(o.medicine_type_order) as medicine_type_order,
		MIN(o.timing_code_order) as timing_code_order,
		MIN(o.procedure_code_order) as procedure_code_order,
		MIN(date_interval) as date_interval
	from (
			select ord.code,
				ord.name,
				ord.count,
				ord.unit,
				ord.class_cd,
				ord.class_name,
				ord.registration_order,
				ord.medi_code_order,
				ord.class_code_order,
				ord.medicine_type_order,
				ord.timing_code_order,
				ord.procedure_code_order,
				ord.date_interval
			from ord_treat_medi_info ord
			where (
					select value
					from medicine_add_flag
				) = ''1'' -- medicine_add_flagが1の場合にのみ薬剤の合算を行う
			) as o
	where o.class_name in (
			select treatment_name
			from treatment_names
		)
	group by o.code,
		o.name
	union all
	select o.code,
		o.name,
		o.count,
		o.unit,
		o.class_cd,
		o.registration_order,
		o.medi_code_order,
		o.class_code_order,
		o.medicine_type_order,
		o.timing_code_order,
		o.procedure_code_order,
		o.date_interval
	from ord_treat_medi_info o
	where (
			select value
			from medicine_add_flag
		) = ''0''
		and o.class_name in (
			select treatment_name
			from treatment_names
		)
	union all
	-- 投薬済みで投薬情報、注射情報、手術麻酔、処置に出力されなかった薬剤
	-- DEFAULT_MEDICINE_GROUP=''処置''の時のみ出力		
	select o.code,
		o.name,
		SUM(o.count::numeric) as count,
		-- group byに含めたくないので単一項目を取得するために集計関数MINを指定している
		MIN(o.unit) as unit,
		MIN(o.class_cd) as class_cd,
		MIN(o.registration_order) as registration_order,
		MIN(o.medi_code_order) as medi_code_order,
		MIN(o.class_code_order) as class_code_order,
		MIN(o.medicine_type_order) as medicine_type_order,
		MIN(o.timing_code_order) as timing_code_order,
		MIN(o.procedure_code_order) as procedure_code_order,
		MIN(date_interval) as date_interval
	from (
			select um.code,
				um.name,
				um.count,
				um.unit,
				um.class_cd,
				um.class_name,
				um.registration_order,
				um.medi_code_order,
				um.class_code_order,
				um.medicine_type_order,
				um.timing_code_order,
				um.procedure_code_order,
				um.date_interval
			from unreferenced_medicines_with_order um
			where (
					select value
					from medicine_add_flag
				) = ''1'' 
			) as o
		group by o.code,o.name
	union all
	select um.code,
		um.name,
		um.count,
		um.unit,
		um.class_cd,
		um.registration_order,
		um.medi_code_order,
		um.class_code_order,
		um.medicine_type_order,
		um.timing_code_order,
		um.procedure_code_order,
		um.date_interval
	from unreferenced_medicines_with_order um
	where (
			select value
			from medicine_add_flag
		) = ''0''
	),
facility_equipment_order as (
	select row_number () over () as setting_order,
		TO_NUMBER(datt.a1::text, ''999999999999'') as setting_value
	from (
			select TO_NUMBER(
					(
						unnest(
							string_to_array(
								(
									select mst_f.value as rtt
									from mst_facility_setting as mst_f
									where mst_f.facility_setting_no = ''3006''
										and mst_f.facility_cd = @facilityCd
								),
								'',''
							)
						)
					),
					''999999999999''
				) as a1
		) as datt
),
equip_order as (
	select index_no::int as meq_code_order,
		TO_NUMBER(order_cd->>''code'', ''999999999999'') as meq_code
	from mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
	where facility_cd = @facilityCd
		and master_physical_name = ''mst_equipment''
),
equip_class_order as (
	select index_no::int as meq_class_code_order,
		TO_NUMBER(order_cd->>''code'', ''999999999999'') as meq_class_code
	from mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
	where facility_cd = @facilityCd
		and master_physical_name = ''mst_equipment_class''
),
mst_equip as (
	select equipment_cd,
		equipment_name,
		class_cd,
		unit,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4,
		equip_order.meq_code_order,
		equip_class_order.meq_class_code_order
	from mst_equipment meq
		left join equip_order on meq.equipment_cd = equip_order.meq_code
		left join equip_class_order on meq.class_cd = equip_class_order.meq_class_code
	where facility_cd = @facilityCd
),
ord_equip_info as (
	select case
			(
				select value
				from equipment_in_hospital_cd_no
			)
			when ''1'' then left(mst_equip.in_hospital_cd_1, 20)
			when ''2'' then left(mst_equip.in_hospital_cd_2, 20)
			when ''3'' then left(mst_equip.in_hospital_cd_3, 20)
			when ''4'' then left(mst_equip.in_hospital_cd_4, 20)
		end as code,
		left(mst_equip.equipment_name, 80) as name,
		column_info.count::numeric as count,
		mst_equip.unit,
		column_info.idx as registration_order,
		mst_equip.meq_code_order,
		mst_equip.meq_class_code_order
	from column_info
		left join mst_equip on column_info.equipment_cd = mst_equip.equipment_cd::text
	union all
	select case
			(
				select value
				from equipment_in_hospital_cd_no
			)
			when ''1'' then left(mst_equip.in_hospital_cd_1, 20)
			when ''2'' then left(mst_equip.in_hospital_cd_2, 20)
			when ''3'' then left(mst_equip.in_hospital_cd_3, 20)
			when ''4'' then left(mst_equip.in_hospital_cd_4, 20)
		end as code,
		left(mst_equip.equipment_name, 80) as name,
		equipment_info.count::numeric as count,
		mst_equip.unit,
		equipment_info.idx::text as registration_order,
		mst_equip.meq_code_order,
		mst_equip.meq_class_code_order
	from equipment_info
		left join mst_equip on equipment_info.equipment_cd = mst_equip.equipment_cd::text
),
treatment_unit as (
	-- 治療項目単位
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''TREATMENT_UNIT''
	limit 1
), disability_allowance as (
	-- 障害者加算
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DISABILITY_ALLOWANCE''
	limit 1
), diffcomment_count as (
	-- 透析困難コメントの数量
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DIFFCOMMENT_COUNT''
	limit 1
), dialyzer_count as (
	-- ダイアライザの数量
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DIALYZER_COUNT''
	limit 1
), val_filter_count as (
	-- １次膜、２次膜の数量
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''VAL_FILTER_COUNT''
	limit 1
)
, treat_all as (
	--治療項目情報
	select 1 as item_sort_no,
		case
			when iha.alpha_value = ''A''
			and ihn.no_value = ''1'' then mtt.in_hospital_cd_a1
			when iha.alpha_value = ''A''
			and ihn.no_value = ''2'' then mtt.in_hospital_cd_a2
			when iha.alpha_value = ''A''
			and ihn.no_value = ''3'' then mtt.in_hospital_cd_a3
			when iha.alpha_value = ''A''
			and ihn.no_value = ''4'' then mtt.in_hospital_cd_a4
			when iha.alpha_value = ''B''
			and ihn.no_value = ''1'' then mtt.in_hospital_cd_b1
			when iha.alpha_value = ''B''
			and ihn.no_value = ''2'' then mtt.in_hospital_cd_b2
			when iha.alpha_value = ''B''
			and ihn.no_value = ''3'' then mtt.in_hospital_cd_b3
			when iha.alpha_value = ''B''
			and ihn.no_value = ''4'' then mtt.in_hospital_cd_b4
			else mtt.in_hospital_cd_a1
		end as code,
		ord.rst_treatment_name as name,
		(ord.rst_cond_info->''1''->>''value'')::numeric as count,
		tu.value as unit,
		null as cutoff,
		null as sort_key
	from ord_main as ord
		cross join treatment_unit tu
		left outer join mst_treatment as mtt on mtt.treatment_cd = ord.rst_treatment_cd
		left join treatment_in_hospital_cd_alpha iha on true
		left join treatment_in_hospital_cd_no ihn on true
	where ord.ord_no = @ordNo
	union all
	-- 障害者加算
	select 2 as item_sort_no,
		case
			when ihn.no_value = ''1'' then madd.in_hospital_cd_1
			when ihn.no_value = ''2'' then madd.in_hospital_cd_2
			when ihn.no_value = ''3'' then madd.in_hospital_cd_3
			else null
		end as code,
		da.value as name,
		null as count,
		null as unit,
		null as cutoff,
		null as sort_key
	from ord_main as ord
		cross join lateral json_array_elements(ord.addition_info::json) oadd
		cross join disability_allowance da
		left outer join mst_addition as madd on madd.addition_cd = to_number(oadd->>''cd'', ''9999999999'')
		left join addition_in_hospital_cd_no ihn on true
	where ord.ord_no = @ordNo
		and madd.addition_class = ''2''
	union all
	-- 透析困難コメント
	select 3 as item_sort_no,
		left(
			case
				when (
					select no_value
					from dial_diff_in_hospital_cd_no
				)::INTEGER = 1 then mst_dialysis_difficulty.in_hospital_cd_1::VARCHAR
				when (
					select no_value
					from dial_diff_in_hospital_cd_no
				)::INTEGER = 2 then mst_dialysis_difficulty.in_hospital_cd_2::VARCHAR
				else null
			end,
			20
		) as code,
		left(
			mst_dialysis_difficulty.dialysis_difficulty_name,
			256
		) as name,
		dc.value::numeric as count,
		null as unit,
		null as cutoff,
		lpad(
			(
				case
					when eddt.is_main = ''1'' then ''0''
					else ''1''
				end
			) || lpad(fddt.sort_no::text, 3, ''0''),
			4,
			''0''
		) as sort_key -- 並び順キー：is_main優先 → sort_no
	from mst_dialysis_difficulty
		cross join diffcomment_count dc
		inner join pat_dial_diff_data eddt on mst_dialysis_difficulty.dialysis_difficulty_cd = (eddt.dial_diff_cd)::INTEGER
		inner join mst_selector_dial_diff_data fddt on mst_dialysis_difficulty.dialysis_difficulty_cd = (fddt.code)::INTEGER
	where (
			select no_value
			from dialysis_output_setting
		) = ''0'' -- dialysis_output_setting が 「0」の場合のみ出力を行う。
	union all
	-- 透析液水質確保加算
	select 4 as item_sort_no,
		left(
			case
				coalesce(
					(
						select no_value::INTEGER
						from addition_in_hospital_cd_no
					),
					1
				)
				when 1 then mst_addition.in_hospital_cd_1::VARCHAR
				when 2 then mst_addition.in_hospital_cd_2::VARCHAR
				when 3 then mst_addition.in_hospital_cd_3::VARCHAR
				else mst_addition.in_hospital_cd_1::VARCHAR
			end,
			20
		) as code,
		left(mst_addition.addition_name, 256) as name,
		null as count,
		null as unit,
		null as cutoff,
		null as sort_key
	from addition_info
		inner join mst_addition on addition_info.code = mst_addition.addition_cd::text
	where addition_info.code = mst_addition.addition_cd::text
		and mst_addition.addition_class = ''1''
	union all
	-- 下肢抹消動脈疾患指導管理加算
	select 5 as item_sort_no,
		left(
			case
				coalesce(
					(
						select no_value::INTEGER
						from addition_in_hospital_cd_no
					),
					1
				)
				when 1 then mst_addition.in_hospital_cd_1::VARCHAR
				when 2 then mst_addition.in_hospital_cd_2::VARCHAR
				when 3 then mst_addition.in_hospital_cd_3::VARCHAR
				else mst_addition.in_hospital_cd_1::VARCHAR
			end,
			20
		) as code,
		left(mst_addition.addition_name, 256) as name,
		null as count,
		null as unit,
		null as cutoff,
		null as sort_key
	from addition_info
		inner join mst_addition on addition_info.code = mst_addition.addition_cd::text
		inner join addition_key_value on mst_addition.in_hospital_cd_2 in (
			addition_key_value.value::text
		)
	union all
	-- その他加算
	select 6 as item_sort_no,
		left(
			case
				coalesce(
					(
						select no_value::INTEGER
						from addition_in_hospital_cd_no
					),
					1
				)
				when 1 then mst_addition.in_hospital_cd_1::VARCHAR
				when 2 then mst_addition.in_hospital_cd_2::VARCHAR
				when 3 then mst_addition.in_hospital_cd_3::VARCHAR
				else mst_addition.in_hospital_cd_1::VARCHAR
			end,
			20
		) as code,
		left(mst_addition.addition_name, 256) as name,
		null as count,
		null as unit,
		null as cutoff,
		null as sort_key
	from mst_addition
	where mst_addition.facility_cd = @facilityCd
		and mst_addition.addition_cd::TEXT in (
			select code
			from addition_info
		)
		and (
			not exists (
				select 1
				from addition_key_value akv
				where mst_addition.in_hospital_cd_2 = akv.value
			)
			or mst_addition.in_hospital_cd_2 is null
		)
		and addition_class::numeric not in (1,2,9,10,11,13)
	union all
	-- 加算する治療項目
	select 7 as item_sort_no,
		code_values.code as code,
		name_values.name as name,
		null as count,
		null as unit,
		null as cutoff,
		code_values.padded_num::text as sort_key
	from code_values
		join name_values on code_values.padded_num = name_values.padded_num
	union all
	-- 抗凝固剤 
	select 8 as item_sort_no,
		anticoagulant.code as code,
		anticoagulant.name as name,
		anticoagulant.count as count,
		anticoagulant.unit as unit,
		null as cutoff,
		lpad(anticoagulant.code, 20, ''0'') as sort_key
	from (
			select *
			from direct_anticoagulant
			union all
			select *
			from mixed_anticoagulant
		) anticoagulant
	where class_type = 1
	union all
	-- 透析液
	select 9 as item_sort_no,
		case
			(
				select value
				from medi_hospital_cd
				limit 1
			)
			when ''1'' then left(in_hospital_cd_1, 20)
			when ''2'' then left(in_hospital_cd_2, 20)
			when ''3'' then left(in_hospital_cd_3, 20)
			when ''4'' then left(in_hospital_cd_4, 20)
		end as code,
		left(medicine_name, 80) as name,
		case
			-- 治療方法（装置モード）が（OHF、OHDF、HD+補液、プログラム補液）の場合、補液は透析液に合算
			when device_mode in (4, 7, 8, 10) then 
				case
					when rst_cond_info->''17''->>''value'' is null
					or rst_cond_info->''22''->>''value'' is null then null
					else (rst_cond_info->''17''->>''value'')::numeric + (rst_cond_info->''22''->>''value'')::numeric
				end
			else (rst_cond_info->''17''->>''value'')::numeric
			end as count,
		unit_second as unit,
		null as cutoff,
		null as sort_key
	from dialysate_info
	union all
	-- 補液
	select 10 as item_sort_no,
		case
			(
				select value
				from medi_hospital_cd
				limit 1
			)
			when ''1'' then left(in_hospital_cd_1, 20)
			when ''2'' then left(in_hospital_cd_2, 20)
			when ''3'' then left(in_hospital_cd_3, 20)
			when ''4'' then left(in_hospital_cd_4, 20)
		end as code,
		left(medicine_name, 80) as name,
		raw_count_value::numeric as count,
		unit_second as unit,
		null as cutoff,
		null as sort_key
	from infusion_info
	union all
	-- 処置
	select 11 as item_sort_no,
		f.code as code,
		f.name as name,
		f.count::numeric as count,
		f.unit as unit,
		null as cotoff,
		row_number() over(
			order by case
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval::numeric
				end
		)::text as sort_key
	from final_treatment_info f
	union all
	-- 消耗品
	select 12 as item_sort_no,
		oei.code as code,
		oei.name as name,
		oei.count::numeric as count,
		oei.unit as unit,
		null as cutoff,
		row_number() over(
			order by case
					when ( select setting_value from facility_equipment_order where setting_order = 1 ) = 0 then oei.registration_order::numeric
					when ( select setting_value from facility_equipment_order where setting_order = 1 ) = 1 then oei.meq_class_code_order
					when ( select setting_value from facility_equipment_order where setting_order = 1 ) = 2 then oei.meq_code_order
				end,
				case
					when ( select setting_value from facility_equipment_order where setting_order = 2 ) = 0 then oei.registration_order::numeric
					when ( select setting_value from facility_equipment_order where setting_order = 2 ) = 1 then oei.meq_class_code_order
					when ( select setting_value from facility_equipment_order where setting_order = 2 ) = 2 then oei.meq_code_order
				end,
				case
					when ( select setting_value from facility_equipment_order where setting_order = 3 ) = 0 then oei.registration_order::numeric
					when ( select setting_value from facility_equipment_order where setting_order = 3 ) = 1 then oei.meq_class_code_order
					when ( select setting_value from facility_equipment_order where setting_order = 3 ) = 2 then oei.meq_code_order
				end
		)::text as sort_key
	from ord_equip_info oei
	union all
	-- ダイアライザ
	select 13 as item_sort_no,
		case
			when ihn.value = ''1'' then md.in_hospital_cd_1
			when ihn.value = ''2'' then md.in_hospital_cd_2
			when ihn.value = ''3'' then md.in_hospital_cd_3
			when ihn.value = ''4'' then md.in_hospital_cd_4
			else md.in_hospital_cd_1
		end as code,
		md.model_number as name,
		dc.value::numeric as count,
		du.unit as unit,
		null as cutoff,
		null as sort_key
	from (
			select rst_cond_info->''5'' as cond_info_5
			from ord_main
			where ord_no = @ordNo
		) t
		inner join mst_dialyzer md on md.dialyzer_cd = (t.cond_info_5->>''value'')::integer
		cross join dialyzer_unit du
		cross join dialyzer_count dc
		left join dialyzer_in_hospital_cd_no ihn on true
	union all
	-- １次膜、２次膜
	select 14 as item_sort_no,
		ord_info.code as code,
		ord_info.name as name,
		vfc.value::numeric as count,
		ord_info.unit as unit,
		null as cutoff,
		ord_info.sort_key as sort_key
	from (
			select case
					(
						select value
						from equipment_in_hospital_cd_no
					)
					when ''1'' then left(mst_equipment.in_hospital_cd_1, 20)
					when ''2'' then left(mst_equipment.in_hospital_cd_2, 20)
					when ''3'' then left(mst_equipment.in_hospital_cd_3, 20)
					when ''4'' then left(mst_equipment.in_hospital_cd_4, 20)
				end as code,
				left(mst_equipment.equipment_name, 80) as name,
				mst_equipment.unit,
				''1'' as sort_key
			from primary_membrane_info,
				mst_equipment
			where primary_membrane_info.equipment_cd = mst_equipment.equipment_cd::text
			union all
			select case
					(
						select value
						from equipment_in_hospital_cd_no
					)
					when ''1'' then left(mst_equipment.in_hospital_cd_1, 20)
					when ''2'' then left(mst_equipment.in_hospital_cd_2, 20)
					when ''3'' then left(mst_equipment.in_hospital_cd_3, 20)
					when ''4'' then left(mst_equipment.in_hospital_cd_4, 20)
				end as code,
				left(mst_equipment.equipment_name, 80) as name,
				mst_equipment.unit,
				''2'' as sort_key
			from secondary_membrane_info,
				mst_equipment
			where secondary_membrane_info.equipment_cd = mst_equipment.equipment_cd::text
		) ord_info
		cross join val_filter_count vfc
)

select
	true as "exists",
    @ordNo as ord_no,
    @facilityCd as facility_cd, 
    @key0 as key0,
    @patId as pat_id,
    ''02'' as detail_id
where exists (
	select *
	from treat_all 
)', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom処方薬剤連携(処置・治療項目情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307033, "field_name": "dial_diff_cds", "replace_var": "@dialDiffCds"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307137, 'with input_code_class as (
-- 検査入力者コード区分
-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 1：患者連携情報．連携情報カラム２→依頼医名コード（利用者マスタ．表示用利用者ID）
-- 2：固定医師コード1より取得
-- 3：固定医師コード2より取得
-- 4：固定担当看護師コード1より取得
-- 5：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_EXAM_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
,
fixed_doctors as (
select
	(info ->> ''key2'') as key,
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' in (
    ''FIXED_DOCTOR_CODE1'', ''FIXED_DOCTOR_NAME1'',
    ''FIXED_DOCTOR_CODE2'', ''FIXED_DOCTOR_NAME2'',
    ''FIXED_NURSE_CODE1'', ''FIXED_NURSE_NAME1'',
    ''FIXED_NURSE_CODE2'', ''FIXED_NURSE_NAME2''
  )
)
,disp_user_ids AS (
  SELECT 
    jsonb_array_elements(
      @ids
      ::jsonb
    ) AS elem
),
user_names AS (
  SELECT 
    jsonb_array_elements(
      @names
      ::jsonb
    ) AS elem
)
, 
pat_coop_detail_users as (
select
	du.elem ->> ''coop_save_no'' as coop_save_no,
	du.elem ->> ''disp_user_id'' as disp_user_id,
	un.elem ->> ''user_name'' as user_name
from
	disp_user_ids du
join 
  user_names un 
  on
	(du.elem ->> ''coop_save_no'') = (un.elem ->> ''coop_save_no'')
left join 
  pat_coop_detail pcd 
  on
	pcd.coop_save_no = (du.elem ->> ''coop_save_no'')::numeric
), 
order_units_id_min as (
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_EXAM_INFO''
	and info ->> ''key2'' = ''ORDER_UNITS_ID_MIN''
limit 1
), 
order_units_id_max as (
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_EXAM_INFO''
	and info ->> ''key2'' = ''ORDER_UNITS_ID_MAX''
limit 1
)
,
examination as (
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_DETAILS''
	and info ->> ''key2'' = ''EXAMINATION''
limit 1
),
order_units_wrapper as (
select
	pcd.coop_save_no,
	LPAD(pcd.save_2 ->> ''ord_no'', 8, ''0'') || LPAD((row_number() over (order by pcd.coop_save_no) - 1 + oui_min.value::numeric )::text, 2, ''0'') as order_units_id,
	examination.value as application,
	case input_code_class.value::numeric
    	when 0 then 
            case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
            else @dispUserId
            end
		when 1 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1)
		else null
	end as input_user_code,
		case input_code_class.value::numeric
    	when 0 then 
            case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
            else @userName
            end
		when 1 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME2'' limit 1)
		else null
	end as input_user_name,
	(pcd.save_2 ->> ''exam_date'') || (pcd.save_2 ->> ''exam_time'') || ''00'' as input_time,
	TO_CHAR(NOW(), ''YYYYMMDDHH24MISS'') as last_update_time,
	row_number() over (order by pcd.coop_save_no) - 1 + oui_min.value::numeric as order_units_id_suffix
from
	pat_coop_detail pcd
cross join examination
cross join input_code_class
cross join order_units_id_min oui_min
cross join order_units_id_max oui_max
left join pat_coop_detail_users pcdu on pcdu.coop_save_no::numeric = pcd.coop_save_no
where
	facility_cd = @facilityCd
	and pat_id = @patId
	and (save_2 ->> ''ord_no'')::numeric = @ordNo)
	

select
	true as "exists",
    @ordNo as ord_no,
    @facilityCd as facility_cd, 
    @key0 as key0,
    @patId as pat_id,
    ''01'' as detail_id
where exists (
    select
        coop_save_no,
        order_units_id,
        application,
        input_user_code,
        input_user_name,
        input_time,
        last_update_time,
        ''01'' as detail_id,
        @ordNo as ord_no,
        @facilityCd as facility_cd,
        @key0 as key0
    from order_units_wrapper
    cross join order_units_id_max oui_max
    cross join order_units_id_min oui_min
    where
        (order_units_id_suffix::numeric) between oui_min.value::numeric and oui_max.value::numeric
    order by
        coop_save_no,
        order_units_id_suffix
)', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 検査情報の存在確認', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307077, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307079, "field_name": "user_name", "replace_var": "@userName"}, {"sql_cd": -307081, "field_name": "disp_user_ids", "replace_var": "@ids"}, {"sql_cd": -307082, "field_name": "user_names", "replace_var": "@names"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307136, 'with surgery_class_name as (
    -- 処方内容（手術・麻酔）
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' = ''SURGERY''
),
default_medicine_group as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''DEFAULT_MEDICINE_GROUP''
),
-- 
-- 投与情報
-- 
medicine_order_units_num as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
medicine_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from medicine_order_units_num,
        generate_series(1, medicine_order_units_num.value) as i
),
medicine_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_MEDICINE_INFO
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
),
medicine_classes as (
    -- 投与薬剤として出力される薬剤分類名
    select idx.suffix,
        msi.value
    from medicine_setting_info as msi
        join medicine_unit_indices as idx on msi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 注射情報
-- 
injection_order_units_num as (
    -- 出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
injection_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from injection_order_units_num,
        generate_series(1, injection_order_units_num.value) as i
),
injection_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_INJECTION_INFOを取得
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
),
injection_procedure_names as (
    -- 注射情報として出力する手技名を取得
    select idx.suffix,
        isi.value
    from injection_setting_info as isi
        join injection_unit_indices as idx on isi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 手術・麻酔
-- 
surgery_medicine_class_name as (
    -- 手術・麻酔として出力する薬剤分類名を取得
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' = ''SURGERY''
),
-- 
-- 処置
-- 
treatment_num as (
    -- 処置として出力する対象の薬剤分類の数 (TREATMENT_NUM)
    select unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' = ''TREATMENT_NUM''
    limit 1
), treatment_number_series as (
    -- TREATMENT_NUMの数を基にTREATMENT_NAME_{0:D2} を生成
    select LPAD(n::text, 2, ''0'') as padded_num
    from generate_series(
            1,
            (
                select value
                from treatment_num
            )::numeric
        ) as t(n)
),
treatment_name_keys as (
    -- TREATMENT_NAME_{0:D2} の key を生成
    select ''TREATMENT_NAME_'' || padded_num as name_key
    from treatment_number_series
),
treatment_key_value_pairs as (
    -- TREATMENT_NAME_{0:D2} の key/value の組み合わせを出力
    select info->>''key2'' as key,
        unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' like ''TREATMENT_NAME_%''
),
treatment_names as (
    -- TREATMENT_NAME_{0:D2} の名前を取得
    select treatment_name_keys.name_key,
        kv.value as treatment_name
    from treatment_name_keys
        join treatment_key_value_pairs kv on kv.key = treatment_name_keys.name_key
),
class_names as (
    select treatment_name as value
    from treatment_names
    union
    select value
    from surgery_medicine_class_name
    union
    select value
    from medicine_classes
),
unreferenced_medicines as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
),
ord_medi_infos as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and mst_medicine_class.class_name = (select value from surgery_class_name)
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and mst_medicine_class.class_name = (select value from surgery_class_name)
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and mst_medicine_class.class_name = (select value from surgery_class_name)
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and mst_medicine_class.class_name = (select value from surgery_class_name)
    union all
    -- 投薬済みで投薬情報、注射情報、手術麻酔、処置に出力されなかった薬剤をセット   
    select *
    from unreferenced_medicines
    where (
            select value
            from default_medicine_group
        ) = (select value from surgery_class_name)
),
medicine_in_hospital_cd_no as (
    --薬剤マスタの参照する連携コード
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''MST''
        and info->>''key2'' = ''MEDICINE_IN_HOSPITAL_CD_NO''
),
medicine_add_flag as (
    --薬剤合算フラグ
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''DISTINCT_MEDICINE_FLAG''
),
facility_medicine_order as (
    -- 施設設定マスタ(No.107)
    select row_number () over () as setting_order,
        -- 適用順 
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
),
medi_order as (
    -- 薬剤マスタの並び順
    select index_no::int as medi_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_code,
        order_cd->>''name'' as name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine''
),
medi_class_order as (
    -- 薬剤分類マスタの並び順
    select index_no::int as medi_class_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_class_code,
        order_cd->>''name'' as class_name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine_class''
),
timing_order as (
    -- 投与タイミングマスタの並び順
    select index_no::int as timing_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as timing_code
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicate_timing''
),
procedure_order as (
    -- 手技マスタの並び順
    select index_no::int as procedure_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as procedure_code
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_procedure''
),
mst_medi as (
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
),
final_medi_info as (
    select case
            (
                select value
                from medicine_in_hospital_cd_no
            )
            when ''1'' then left(med.in_hospital_cd_1, 20)
            when ''2'' then left(med.in_hospital_cd_2, 20)
            when ''3'' then left(med.in_hospital_cd_3, 20)
            when ''4'' then left(med.in_hospital_cd_4, 20)
        end as code,
        left(med.medicine_name, 80) as name,
        SUM(amount) as count,
        MIN(med.unit) as unit,
        MIN(med.class_cd) as class_cd,
        MIN(omi.registration_order) as registration_order,
        MIN(mst_medi.medi_code_order) as medi_code_order,
        MIN(mst_medi.medi_class_code_order) as class_code_order,
        MIN(omi.medicine_type::int) as medicine_type_order,
        MIN(t.timing_code_order) as timing_code_order,
        MIN(p.procedure_code_order) as procedure_code_order,
        MIN(omi.date_interval::int) as date_interval
    from ord_medi_infos omi
        left join mst_medicine med on omi.medicine_cd = med.medicine_cd::text
        left join mst_medi on med.class_cd = mst_medi.class_cd
        and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
    where (
            select value
            from medicine_add_flag
        ) = ''1''
    group by code,
        name
    union all
    select case
            (
                select value
                from medicine_in_hospital_cd_no
            )
            when ''1'' then left(med.in_hospital_cd_1, 20)
            when ''2'' then left(med.in_hospital_cd_2, 20)
            when ''3'' then left(med.in_hospital_cd_3, 20)
            when ''4'' then left(med.in_hospital_cd_4, 20)
        end as code,
        left(med.medicine_name, 80) as name,
        amount as count,
        med.unit,
        med.class_cd,
        omi.registration_order as registration_order,
        mst_medi.medi_code_order as medi_code_order,
        mst_medi.medi_class_code_order as class_code_order,
        omi.medicine_type::int as medicine_type_order,
        t.timing_code_order as timing_code_order,
        p.procedure_code_order as procedure_code_order,
        omi.date_interval::int as date_interval
    from ord_medi_infos omi
        left join mst_medicine med on omi.medicine_cd = med.medicine_cd::text
        left join mst_medi on med.class_cd = mst_medi.class_cd
        and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
    where (
            select value
            from medicine_add_flag
        ) = ''0''
)

select
	true as "exists",
    @ordNo as ord_no,
    @facilityCd as facility_cd, 
    @key0 as key0,
    @patId as pat_id,
    ''01'' as detail_id
where exists (
    select
            *
    from final_medi_info
)', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 手術・麻酔情報の存在確認', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307135, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code,
        ord_addition_info ->> ''name'' as name
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
        and is_del = ''0''
 )
 
select
	true as "exists",
    @ordNo as ord_no,
    @facilityCd as facility_cd, 
    @key0 as key0,
    @patId as pat_id,
    ''01'' as detail_id
where exists (
    select distinct
        @ordNo as ord_no,
        @key0 as key0,
        @facilityCd as facility_cd,
        ''16'' AS detail_id
    from
        ord_main_info,
        mst_addition
    where
        ord_main_info.code = mst_addition.addition_cd :: text
        and mst_addition.addition_class in (''9'')
)', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 処置・人工腎臓以外(導入期加算)情報の存在確認', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307134, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code,
        ord_addition_info ->> ''name'' as name
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
        and is_del = ''0''
 )

select
	true as "exists",
    @ordNo as ord_no,
    @facilityCd as facility_cd, 
    @key0 as key0,
    @patId as pat_id,
    ''01'' as detail_id
where exists (
    select distinct
        @ordNo as ord_no,
        @key0 as key0,
        @facilityCd as facility_cd,
        ''15'' AS detail_id
    from
        ord_main_info,
        mst_addition
    where
        ord_main_info.code = mst_addition.addition_cd :: text
        and mst_addition.addition_class in (''10'', ''11'')
)', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 処置・人工腎臓以外(夜間・休日加算)情報の存在確認', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307133, 'WITH medicine_in_hospital_cd_no as (
    --薬剤マスタの参照する連携コード
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join LATERAL json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''MST''
        and info->>''key2'' = ''MEDICINE_IN_HOSPITAL_CD_NO''
),
medicine_add_flag as (
    --薬剤合算フラグ
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join LATERAL json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''DISTINCT_MEDICINE_FLAG''
),
facility_medicine_order as (
    -- 施設設定マスタ(No.107)
    select row_number () over () as setting_order,
        -- 適用順 
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
),
medi_order as (
    -- 薬剤マスタの並び順
    select index_no::int as medi_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_code,
        order_cd->>''name'' as name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine''
),
medi_class_order as (
    -- 薬剤分類マスタの並び順
    select index_no::int as medi_class_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_class_code,
        order_cd->>''name'' as class_name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine_class''
),
timing_order as (
    -- 投与タイミングマスタの並び順
    select index_no::int as timing_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as timing_code
    from mst_selector
        cross join LATERAL jsonb_array_elements(order_settings->''items'') WITH ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicate_timing''
),
procedure_order as (
    -- 手技マスタの並び順
    select index_no::int as procedure_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as procedure_code
    from mst_selector
        cross join LATERAL jsonb_array_elements(order_settings->''items'') WITH ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_procedure''
),
mst_medi as (
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
),default_medicine_group as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''DEFAULT_MEDICINE_GROUP''
),
-- 
-- 投与情報
-- 
medicine_order_units_num as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
medicine_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from medicine_order_units_num,
        generate_series(1, medicine_order_units_num.value) as i
),
medicine_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_MEDICINE_INFO
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
),
medicine_classes as (
    -- 投与薬剤として出力される薬剤分類名
    select idx.suffix,
        msi.value
    from medicine_setting_info as msi
        join medicine_unit_indices as idx on msi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 注射情報
-- 
injection_order_units_num as (
    -- 出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
injection_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from injection_order_units_num,
        generate_series(1, injection_order_units_num.value) as i
),
injection_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_INJECTION_INFOを取得
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
),injection_procedure_names as (
    -- 注射情報として出力する手技名を取得
    select idx.suffix,
        isi.value
    from injection_setting_info as isi
        join injection_unit_indices as idx on isi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 手術・麻酔
-- 
surgery_medicine_class_name as (
    -- 手術・麻酔として出力する薬剤分類名を取得
    select
        coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''PRESCRIPTION_DETAILS''
        and info ->> ''key2'' = ''SURGERY''
),
-- 
-- 処置
-- 
treatment_num as (
	-- 処置として出力する対象の薬剤分類の数 (TREATMENT_NUM)
	select unnest(
			string_to_array(
				coalesce(
					nullif(info->>''value'', ''''),
					info->>''default_v''
				),
				'',''
			)
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''TREATMENT_NUM''
	limit 1
), treatment_number_series as (
	-- TREATMENT_NUMの数を基にTREATMENT_NAME_{0:D2} を生成
	select LPAD(n::text, 2, ''0'') as padded_num
	from generate_series(
			1,
			(
				select value
				from treatment_num
			)::numeric
		) as t(n)
),
treatment_name_keys as (
	-- TREATMENT_NAME_{0:D2} の key を生成
	select ''TREATMENT_NAME_'' || padded_num as name_key
	from treatment_number_series
),
treatment_key_value_pairs as (
	-- TREATMENT_NAME_{0:D2} の key/value の組み合わせを出力
	select info->>''key2'' as key,
		unnest(
			string_to_array(
				coalesce(
					nullif(info->>''value'', ''''),
					info->>''default_v''
				),
				'',''
			)
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' like ''TREATMENT_NAME_%''
),
treatment_names as (
	-- TREATMENT_NAME_{0:D2} の名前を取得
	select treatment_name_keys.name_key,
		kv.value as treatment_name
	from treatment_name_keys
		join treatment_key_value_pairs kv on kv.key = treatment_name_keys.name_key
),
class_names as (
	select treatment_name as value from treatment_names
	union
	select value from surgery_medicine_class_name
	union
	select value from medicine_classes
),application_name as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' = ''TREATMENT''
),
unreferenced_medicines as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
),
treatment_in_hospital_cd_alpha AS (
	-- 使用する治療方法の連携コードアルファベット
	SELECT coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) AS alpha_value
	FROM mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
	WHERE facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info->>''key0'', '''') = @key0
		AND info->>''key1'' = ''MST''
		AND info->>''key2'' = ''TREATMENT_IN_HOSPITAL_CD_ALPHA''
),
treatment_in_hospital_cd_no AS (
	-- 使用する治療方法の連携コード番号
	SELECT coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) AS no_value
	FROM mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
	WHERE facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info->>''key0'', '''') = @key0
		AND info->>''key1'' = ''MST''
		AND info->>''key2'' = ''TREATMENT_IN_HOSPITAL_CD_NO''
),
addition_in_hospital_cd_no AS (
	-- 使用する加算/管理科項目の連携コード番号
	SELECT coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) AS no_value
	FROM mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
	WHERE facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info->>''key0'', '''') = @key0
		AND info->>''key1'' = ''MST''
		AND info->>''key2'' = ''ADDITION_IN_HOSPITAL_CD_NO''
),
pat_dial_diff_data AS (
	-- 患者の透析困難情報
	SELECT obj->>''is_main'' AS is_main,
		obj->>''dial_diff_cd'' AS dial_diff_cd
	FROM (
			SELECT jsonb_array_elements(replace(@dialDiffCds, '''''''', ''"'')::jsonb) AS obj
		) t
),
mst_selector_dial_diff_data as (
	-- マスタ並び順から取得した透析困難
	select row_number() over () as sort_no,
		item->>''code'' as code,
		item->>''name'' as name,
		item->>''isDel'' as is_del,
		item->>''isDisp'' as is_disp
	from (
			select jsonb_array_elements(order_settings->''items'') as item
			from mst_selector
			where facility_cd = @facilityCd
				and master_physical_name = ''mst_dialysis_difficulty''
		) t
),
dial_diff_in_hospital_cd_no as (
	-- 使用する透析困難の連携コード番号
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as no_value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''MST''
		and info->>''key2'' = ''DIALYSIS_DIFFICULTY_HOSPITAL_CD_NO''
),
dialysis_output_setting as (
	-- 透析困難コメント・透析時間の出力設定
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as no_value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DIFFCOMMENT_DIALTIME_FLG''
),
addition_info as(
	-- オーダから取得した加算・管理科情報
	select ord_addition_info->>''cd'' as code
	from ord_main
		cross join lateral json_array_elements(ord_main.addition_info::json) ord_addition_info
	where ord_main.ord_no = @ordNo
),
addition_key_value as(
	-- 加算項目キー
	select unnest(
			string_to_array(
				coalesce(
					nullif(info->>''value'', ''''),
					info->>''default_v''
				),
				'',''
			)
		) as VALUE
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_RECE_MNG_INFO''
		and info->>''key2'' = ''RECE_MNG_GENERAL_KEY''
),
add_treat_item_num as (
	-- 追加する治療項目数を取得
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''ADD_TREAT_ITEM_NUM''
),
key_nums as (
	-- 追加する治療項目数の数値"{0:D2}"を生成
	select LPAD(n::text, 2, ''0'') as padded_num
	from generate_series(
			1,
			(
				select value::integer
				from ADD_TREAT_ITEM_NUM
			)
		) as t(n)
),
target_keys as (
	-- 追加する治療項目のコードと名称を連携設定から取得するためのkeyを生成
	select ''ADD_TREAT_ITEM_CODE_'' || padded_num as code_key,
		''ADD_TREAT_ITEM_NAME_'' || padded_num as name_key
	from key_nums
),
flat_kv as (
	--	ADD_TREAT_ITEM_CODEとADD_TREAT_ITEM_NAMEのkey/valueの組み合わせを出力
	select info->>''key2'' as key,
		unnest(
			string_to_array(
				coalesce(
					nullif(info->>''value'', ''''),
					info->>''default_v''
				),
				'',''
			)
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
),
code_values as (
	-- flat_kvからADD_TREAT_ITEM_CODEの値のみ抽出
	select key_nums.padded_num,
		kv.value as code
	from key_nums
		join target_keys on target_keys.code_key = ''ADD_TREAT_ITEM_CODE_'' || key_nums.padded_num
		join flat_kv kv on kv.key = target_keys.code_key
),
name_values as (
	-- flat_kvからADD_TREAT_ITEM_NAMEの値のみ抽出
	select key_nums.padded_num,
		kv.value as name
	from key_nums
		join target_keys on target_keys.name_key = ''ADD_TREAT_ITEM_NAME_'' || key_nums.padded_num
		join flat_kv kv on kv.key = target_keys.name_key
),
dialyzer_unit as (
	-- ダイアライザの単位
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as unit
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DIALYZER_UNIT''
),
dialyzer_in_hospital_cd_no as (
	--　使用するダイアライザの連携コード番号
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''MST''
		and info->>''key2'' = ''DIALYZER_IN_HOSPITAL_CD_NO''
),
primary_membrane_info as (
	--１次膜の取得
	select rst_cond_info->''7''->>''value'' as equipment_cd
	from ord_main
	where ord_no = @ordNo
		and is_del = ''0''
),
secondary_membrane_info as (
	--2次膜の取得
	select rst_cond_info->''8''->>''value'' as equipment_cd
	from ord_main
	where ord_no = @ordNo
		and is_del = ''0''
),
equipment_in_hospital_cd_no as (
	--医療材料マスタの参照する連携コード
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''MST''
		and info->>''key2'' = ''EQUIPMENT_IN_HOSPITAL_CD_NO''
),
column_count as (
	-- 吸着カラムの数量
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''COLUMN_COUNT''
	limit 1
), column_info as (
	--吸着カラムの取得
	select null as idx,
		rst_cond_info->''6''->>''value'' as equipment_cd,
		cc.value as count
	from ord_main
		cross join column_count cc
	where ord_no = @ordNo
	and rst_cond_info->''6''->>''value'' != ''null''
),
equipment_info as (
	--穿刺針(SN)、穿刺針(SN以外)を除外した医療材料の取得
	select t.idx,
		t.equip_info->>''cd'' as equipment_cd,
		t.equip_info->>''amount'' as count
	from ord_main
		cross join lateral json_array_elements(ord_main.rst_equip_info::json) with ordinality as t(equip_info, idx)
	where ord_no = @ordNo
		and is_del = ''0''
		and equip_info->>''class_type'' not in (''2'', ''3'')
),
medi_hospital_cd as (
	-- 使用する薬剤の連携コード番号
	select unnest(
			string_to_array(
				coalesce(
					nullif(info->>''value'', ''''),
					info->>''default_v''
				),
				'',''
			)
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''MST''
		and info->>''key2'' = ''MEDICINE_IN_HOSPITAL_CD_NO''
),
dialysate_info as (
	-- 透析液を取得
	select ord_main.rst_cond_info,
		mst_medicine.medicine_cd,
		mst_medicine.medicine_name,
		mst_medicine.unit_second,
		mst_medicine.in_hospital_cd_1,
		mst_medicine.in_hospital_cd_2,
		mst_medicine.in_hospital_cd_3,
		mst_medicine.in_hospital_cd_4,
		mst_treatment.device_mode
	from ord_main
		left join mst_medicine on mst_medicine.medicine_cd::text = ord_main.rst_cond_info->''15''->>''value''
		left join mst_treatment on ord_main.rst_treatment_cd = mst_treatment.treatment_cd
	where ord_main.ord_no = @ordNo
		and ord_main.is_del = ''0''
		and ord_main.rst_cond_info->''15''->>''medicine_type'' = ''1''
),
infusion_info as (
	-- 補液情報の抽出
	select mst_medicine.medicine_cd,
		mst_medicine.medicine_name,
		mst_medicine.unit_second,
		mst_medicine.in_hospital_cd_1,
		mst_medicine.in_hospital_cd_2,
		mst_medicine.in_hospital_cd_3,
		mst_medicine.in_hospital_cd_4,
		ord_main.rst_cond_info->''22''->>''value'' as raw_count_value
	from ord_main
		left join mst_medicine on mst_medicine.medicine_cd::text = ord_main.rst_cond_info->''19''->>''value''
		left join mst_treatment on ord_main.rst_treatment_cd = mst_treatment.treatment_cd
	where ord_main.ord_no = @ordNo
		and ord_main.is_del = ''0''
		and ord_main.rst_cond_info->''19''->>''medicine_type'' = ''1'' 
		and mst_treatment.device_mode not in (4, 7, 8, 10) -- 治療方法（装置モード）が（OHF、OHDF、HD+補液、プログラム補液）の場合、補液は透析液に合算するため出力しない
),
anticoagulant_info as (
	-- 抗凝固剤を抽出
	select ord_main.rst_cond_info->''25''->>''value'' as medicine_cd,
		ord_main.rst_cond_info->''25''->>''medicine_type'' as medicine_type,
		ord_main.rst_cond_info->''26''->>''value'' as one_shot,
		ord_main.rst_cond_info->''28''->>''value'' as total_dose
	from ord_main
	where ord_main.ord_no = @ordNo
),
direct_anticoagulant as (
	-- 通常薬剤の抗凝固剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		left(med.medicine_name, 80) as name,
		ai.one_shot::numeric + ai.total_dose::numeric as count,
		med.unit as unit,
		mmc.class_type as class_type
	from anticoagulant_info ai
		left join mst_medicine med on ai.medicine_cd = med.medicine_cd::TEXT
		left join mst_medicine_class mmc on med.class_cd = mmc.class_cd
	where ai.medicine_type = ''1''
),
mixed_anticoagulant as (
	-- 調製薬剤の抗凝固剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		med.medicine_name as name,
		case
			when mi.value->>''amount'' = ''0'' or mi.value->>''amount'' = ''null'' then null
			when mi.value->>''solvent'' = ''1'' then (mi.value->>''amount'')::numeric
			when mi.value->>''solvent'' = ''0'' then ((ai.one_shot)::numeric + (ai.total_dose)::numeric ) * (mi.value->>''amount'')::numeric
			else null
		end as count,
		med.unit as unit,
		mmc.class_type as class_type
	from mst_medicine_mix mmm
		inner join anticoagulant_info ai on ai.medicine_cd::integer = mmm.medicine_mix_cd
		cross join lateral jsonb_array_elements(mmm.mix_info) as mi(value)
		left join mst_medicine med on med.medicine_cd = (mi.value->>''cd'')::integer
		left join mst_medicine_class mmc on med.class_cd = mmc.class_cd
	where ai.medicine_type = ''2''
), ord_medi_info as (
	-- 投与薬剤情報
	select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
		ord_medi_info->>''cd'' as cd,
		ord_medi_info->>''name'' as name,
		ord_medi_info->>''amount'' as amount,
		ord_medi_info->>''unit'' as unit,
		mst_medicine.class_cd as class_cd,
		ord_medi_info->>''class_name'' as class_name,
		ord_medi_info->>''medicine_type'' as medicine_type,
		ord_medi_info->>''timing_cd'' as timing_cd,
		ord_medi_info->>''procedure_cd'' as procedure_cd,
		ord_medi_info->>''date_interval'' as date_interval
	from ord_main
		cross join lateral json_array_elements(ord_main.rst_medi_info::json) ord_medi_info
		inner join mst_medicine on (ord_medi_info->>''cd'')::numeric = mst_medicine.medicine_cd
	where ord_no = @ordNo
		and ord_medi_info->>''effect_flg'' = ''1''
	order by registration_order
),
ord_treat_info as (
	-- 愁訴処置情報
	select LPAD(ord_treat_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treat_info->>''row_no'', 10, ''0'') as registration_order,
		ord_treat_info->>''treat_medicine_cd'' as cd,
		ord_treat_info->>''treat_medicine_name'' as name,
		ord_treat_info->>''amount'' as amount,
		ord_treat_info->>''unit'' as unit,
		mst_medicine.class_cd as class_cd,
		mst_medicine_class.class_name as class_name,
		ord_treat_info->>''medicine_type'' as medicine_type,
		ord_treat_info->>''procedure_cd'' as procedure_cd
	from ord_main
		cross join lateral json_array_elements(ord_main.rst_treatment_info::json) ord_treat_info
		inner join mst_medicine on (ord_treat_info->>''treat_medicine_cd'')::numeric = mst_medicine.medicine_cd
        inner join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
	where ord_no = @ordNo
        and (ord_treat_info->>''medicine_type'')::numeric = 1
	union all
	select LPAD(ord_treat_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treat_info->>''row_no'', 10, ''0'') as registration_order,
		ord_treat_info->>''treat_medicine_cd'' as cd,
		ord_treat_info->>''treat_medicine_name'' as name,
		ord_treat_info->>''amount'' as amount,
		ord_treat_info->>''unit'' as unit,
		mst_medicine_mix.class_cd as class_cd,
		mst_medicine_class.class_name as class_name,
		ord_treat_info->>''medicine_type'' as medicine_type,
		ord_treat_info->>''procedure_cd'' as procedure_cd
	from ord_main
		cross join lateral json_array_elements(ord_main.rst_treatment_info::json) ord_treat_info
		left join mst_medicine_mix on (ord_treat_info->>''treat_medicine_cd'')::numeric = mst_medicine_mix.medicine_mix_cd
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
	where ord_no = @ordNo
        and (ord_treat_info->>''medicine_type'')::numeric = 2
),
ord_treat_medi_info as (
	-- 投与薬剤情報 通常薬剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		left(med.medicine_name, 80) as name,
		omi.amount::numeric as count,
		med.unit as unit,
		mst_medi.class_cd as class_cd,
		mst_medi.class_name as class_name,
		omi.registration_order as registration_order,
		mst_medi.medi_code_order as medi_code_order,
		mst_medi.medi_class_code_order as class_code_order,
		omi.medicine_type as medicine_type_order,
		t.timing_code_order::text as timing_code_order,
		p.procedure_code_order::text as procedure_code_order,
		omi.date_interval as date_interval
	from ord_medi_info omi
		left join mst_medicine med on omi.cd = med.medicine_cd::TEXT
		left join mst_medi on med.class_cd = mst_medi.class_cd
		and med.medicine_cd = mst_medi.medicine_cd
		left join timing_order t on t.timing_code = omi.timing_cd::numeric
		left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
	where omi.medicine_type = ''1''
	union all
	-- 投与薬剤情報 調製薬剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		med.medicine_name as name,
		case
			when mi.value->>''amount'' = ''0'' or mi.value->>''amount'' = ''null'' then null
			when mi.value->>''solvent'' = ''1'' then (mi.value->>''amount'')::numeric
			when mi.value->>''solvent'' = ''0'' then (omi.amount)::numeric * (mi.value->>''amount'')::numeric
			else null
		end as count,
		med.unit as unit,
		mst_medi.class_cd as class_cd,
		omi.class_name as class_name,
		omi.registration_order as registration_order,
		mst_medi.medi_code_order as medi_code_order,
		mst_medi.medi_class_code_order as class_code_order,
		omi.medicine_type as medicine_type_order,
		t.timing_code_order::text as timing_code_order,
		p.procedure_code_order::text as procedure_code_order,
		omi.date_interval as date_interval
	from mst_medicine_mix mmm
		inner join ord_medi_info omi on omi.cd::integer = mmm.medicine_mix_cd
		cross join lateral jsonb_array_elements(mmm.mix_info) as mi(value)
		left join mst_medicine med on med.medicine_cd = (mi.value->>''cd'')::integer
		left join mst_medi on med.class_cd = mst_medi.class_cd
		and med.medicine_cd = mst_medi.medicine_cd
		left join timing_order t on t.timing_code = omi.timing_cd::numeric
		left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
	where omi.medicine_type = ''2''
	union all
	-- 愁訴処置情報 通常薬剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		left(med.medicine_name, 80) as name,
		oti.amount::numeric as count,
		med.unit as unit,
		mst_medi.class_cd as class_cd,
		mst_medi.class_name as class_name,
		oti.registration_order as registration_order,
		mst_medi.medi_code_order as medi_code_order,
		mst_medi.medi_class_code_order as class_code_order,
		oti.medicine_type as medicine_type_order,
		null as timing_code_order,
		p.procedure_code_order::text as procedure_code_order,
		null as date_interval
	from ord_treat_info oti
		left join mst_medicine med on oti.cd = med.medicine_cd::TEXT
		left join mst_medi on med.class_cd = mst_medi.class_cd
		and med.medicine_cd = mst_medi.medicine_cd
		left join procedure_order p on p.procedure_code = oti.procedure_cd::numeric
	where oti.medicine_type = ''1''
	union all
	-- 愁訴処置情報 調製薬剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		med.medicine_name as name,
		case
			when mi.value->>''amount'' = ''0'' or mi.value->>''amount'' = ''null'' then null
			when mi.value->>''solvent'' = ''1'' then (mi.value->>''amount'')::numeric
			when mi.value->>''solvent'' = ''0'' then (oti.amount)::numeric * (mi.value->>''amount'')::numeric
			else null
		end as count,
		med.unit as unit,
		mst_medi.class_cd as class_cd,
		oti.class_name as class_name,
		oti.registration_order as registration_order,
		mst_medi.medi_code_order as medi_code_order,
		mst_medi.medi_class_code_order as class_code_order,
		oti.medicine_type as medicine_type_order,
		null as timing_code_order,
		p.procedure_code_order::text as procedure_code_order,
		null as date_interval
	from mst_medicine_mix mmm
		inner join ord_treat_info oti on oti.cd::integer = mmm.medicine_mix_cd
		cross join lateral jsonb_array_elements(mmm.mix_info) as mi(value)
		left join mst_medicine med on med.medicine_cd = (mi.value->>''cd'')::integer
		left join mst_medi on med.class_cd = mst_medi.class_cd
		and med.medicine_cd = mst_medi.medicine_cd
		left join procedure_order p on p.procedure_code = oti.procedure_cd::numeric
	where oti.medicine_type = ''2''
),
unreferenced_medicines_with_order as (
	-- 投薬済みで投薬情報、注射情報、手術麻酔、処置に出力されなかった薬剤
	select case
				(
					select value
					from medi_hospital_cd
				)
				when ''1'' then left(med.in_hospital_cd_1, 20)
				when ''2'' then left(med.in_hospital_cd_2, 20)
				when ''3'' then left(med.in_hospital_cd_3, 20)
			end as code,
			left(med.medicine_name, 80) as name,
			um.amount::numeric as count,
			med.unit as unit,
			mst_medi.class_cd as class_cd,
			mst_medi.class_name as class_name,
			um.registration_order::text as registration_order,
			mst_medi.medi_code_order as medi_code_order,
			mst_medi.medi_class_code_order as class_code_order,
			um.medicine_type as medicine_type_order,
			t.timing_code_order::text as timing_code_order,
			p.procedure_code_order::text as procedure_code_order,
			um.date_interval as date_interval
		from
			unreferenced_medicines um
			left join mst_medicine med on med.medicine_cd = um.medicine_cd::numeric
			left join mst_medi on med.class_cd = mst_medi.class_cd and med.medicine_cd = mst_medi.medicine_cd
			left join timing_order t on t.timing_code = um.timing_cd::numeric
			left join procedure_order p on p.procedure_code = um.procedure_cd::numeric
		where
			(
			select
				value
			from
				default_medicine_group
		        ) = (select value from application_name)
),
final_treatment_info as (
	-- 処置として出力する対象の薬剤
	select o.code,
		o.name,
		SUM(o.count::numeric) as count,
		-- group byに含めたくないので単一項目を取得するために集計関数MINを指定している
		MIN(o.unit) as unit,
		MIN(o.class_cd) as class_cd,
		MIN(o.registration_order) as registration_order,
		MIN(o.medi_code_order) as medi_code_order,
		MIN(o.class_code_order) as class_code_order,
		MIN(o.medicine_type_order) as medicine_type_order,
		MIN(o.timing_code_order) as timing_code_order,
		MIN(o.procedure_code_order) as procedure_code_order,
		MIN(date_interval) as date_interval
	from (
			select ord.code,
				ord.name,
				ord.count,
				ord.unit,
				ord.class_cd,
				ord.class_name,
				ord.registration_order,
				ord.medi_code_order,
				ord.class_code_order,
				ord.medicine_type_order,
				ord.timing_code_order,
				ord.procedure_code_order,
				ord.date_interval
			from ord_treat_medi_info ord
			where (
					select value
					from medicine_add_flag
				) = ''1'' -- medicine_add_flagが1の場合にのみ薬剤の合算を行う
			) as o
	where o.class_name in (
			select treatment_name
			from treatment_names
		)
	group by o.code,
		o.name
	union all
	select o.code,
		o.name,
		o.count,
		o.unit,
		o.class_cd,
		o.registration_order,
		o.medi_code_order,
		o.class_code_order,
		o.medicine_type_order,
		o.timing_code_order,
		o.procedure_code_order,
		o.date_interval
	from ord_treat_medi_info o
	where (
			select value
			from medicine_add_flag
		) = ''0''
		and o.class_name in (
			select treatment_name
			from treatment_names
		)
	union all
	-- 投薬済みで投薬情報、注射情報、手術麻酔、処置に出力されなかった薬剤
	-- DEFAULT_MEDICINE_GROUP=''処置''の時のみ出力		
	select o.code,
		o.name,
		SUM(o.count::numeric) as count,
		-- group byに含めたくないので単一項目を取得するために集計関数MINを指定している
		MIN(o.unit) as unit,
		MIN(o.class_cd) as class_cd,
		MIN(o.registration_order) as registration_order,
		MIN(o.medi_code_order) as medi_code_order,
		MIN(o.class_code_order) as class_code_order,
		MIN(o.medicine_type_order) as medicine_type_order,
		MIN(o.timing_code_order) as timing_code_order,
		MIN(o.procedure_code_order) as procedure_code_order,
		MIN(date_interval) as date_interval
	from (
			select um.code,
				um.name,
				um.count,
				um.unit,
				um.class_cd,
				um.class_name,
				um.registration_order,
				um.medi_code_order,
				um.class_code_order,
				um.medicine_type_order,
				um.timing_code_order,
				um.procedure_code_order,
				um.date_interval
			from unreferenced_medicines_with_order um
			where (
					select value
					from medicine_add_flag
				) = ''1'' 
			) as o
		group by o.code,o.name
	union all
	select um.code,
		um.name,
		um.count,
		um.unit,
		um.class_cd,
		um.registration_order,
		um.medi_code_order,
		um.class_code_order,
		um.medicine_type_order,
		um.timing_code_order,
		um.procedure_code_order,
		um.date_interval
	from unreferenced_medicines_with_order um
	where (
			select value
			from medicine_add_flag
		) = ''0''
	),
facility_equipment_order as (
	select row_number () over () as setting_order,
		TO_NUMBER(datt.a1::text, ''999999999999'') as setting_value
	from (
			select TO_NUMBER(
					(
						unnest(
							string_to_array(
								(
									select mst_f.value as rtt
									from mst_facility_setting as mst_f
									where mst_f.facility_setting_no = ''3006''
										and mst_f.facility_cd = @facilityCd
								),
								'',''
							)
						)
					),
					''999999999999''
				) as a1
		) as datt
),
equip_order as (
	select index_no::int as meq_code_order,
		TO_NUMBER(order_cd->>''code'', ''999999999999'') as meq_code
	from mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
	where facility_cd = @facilityCd
		and master_physical_name = ''mst_equipment''
),
equip_class_order as (
	select index_no::int as meq_class_code_order,
		TO_NUMBER(order_cd->>''code'', ''999999999999'') as meq_class_code
	from mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
	where facility_cd = @facilityCd
		and master_physical_name = ''mst_equipment_class''
),
mst_equip as (
	select equipment_cd,
		equipment_name,
		class_cd,
		unit,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4,
		equip_order.meq_code_order,
		equip_class_order.meq_class_code_order
	from mst_equipment meq
		left join equip_order on meq.equipment_cd = equip_order.meq_code
		left join equip_class_order on meq.class_cd = equip_class_order.meq_class_code
	where facility_cd = @facilityCd
),
ord_equip_info as (
	select case
			(
				select value
				from equipment_in_hospital_cd_no
			)
			when ''1'' then left(mst_equip.in_hospital_cd_1, 20)
			when ''2'' then left(mst_equip.in_hospital_cd_2, 20)
			when ''3'' then left(mst_equip.in_hospital_cd_3, 20)
			when ''4'' then left(mst_equip.in_hospital_cd_4, 20)
		end as code,
		left(mst_equip.equipment_name, 80) as name,
		column_info.count::numeric as count,
		mst_equip.unit,
		column_info.idx as registration_order,
		mst_equip.meq_code_order,
		mst_equip.meq_class_code_order
	from column_info
		left join mst_equip on column_info.equipment_cd = mst_equip.equipment_cd::text
	union all
	select case
			(
				select value
				from equipment_in_hospital_cd_no
			)
			when ''1'' then left(mst_equip.in_hospital_cd_1, 20)
			when ''2'' then left(mst_equip.in_hospital_cd_2, 20)
			when ''3'' then left(mst_equip.in_hospital_cd_3, 20)
			when ''4'' then left(mst_equip.in_hospital_cd_4, 20)
		end as code,
		left(mst_equip.equipment_name, 80) as name,
		equipment_info.count::numeric as count,
		mst_equip.unit,
		equipment_info.idx::text as registration_order,
		mst_equip.meq_code_order,
		mst_equip.meq_class_code_order
	from equipment_info
		left join mst_equip on equipment_info.equipment_cd = mst_equip.equipment_cd::text
),
treatment_unit as (
	-- 治療項目単位
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''TREATMENT_UNIT''
	limit 1
), disability_allowance as (
	-- 障害者加算
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DISABILITY_ALLOWANCE''
	limit 1
), diffcomment_count as (
	-- 透析困難コメントの数量
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DIFFCOMMENT_COUNT''
	limit 1
), dialyzer_count as (
	-- ダイアライザの数量
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DIALYZER_COUNT''
	limit 1
), val_filter_count as (
	-- １次膜、２次膜の数量
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''VAL_FILTER_COUNT''
	limit 1
)
, treat_all as (
	--治療項目情報
	select 1 as item_sort_no,
		case
			when iha.alpha_value = ''A''
			and ihn.no_value = ''1'' then mtt.in_hospital_cd_a1
			when iha.alpha_value = ''A''
			and ihn.no_value = ''2'' then mtt.in_hospital_cd_a2
			when iha.alpha_value = ''A''
			and ihn.no_value = ''3'' then mtt.in_hospital_cd_a3
			when iha.alpha_value = ''A''
			and ihn.no_value = ''4'' then mtt.in_hospital_cd_a4
			when iha.alpha_value = ''B''
			and ihn.no_value = ''1'' then mtt.in_hospital_cd_b1
			when iha.alpha_value = ''B''
			and ihn.no_value = ''2'' then mtt.in_hospital_cd_b2
			when iha.alpha_value = ''B''
			and ihn.no_value = ''3'' then mtt.in_hospital_cd_b3
			when iha.alpha_value = ''B''
			and ihn.no_value = ''4'' then mtt.in_hospital_cd_b4
			else mtt.in_hospital_cd_a1
		end as code,
		ord.rst_treatment_name as name,
		(ord.rst_cond_info->''1''->>''value'')::numeric as count,
		tu.value as unit,
		null as cutoff,
		null as sort_key
	from ord_main as ord
		cross join treatment_unit tu
		left outer join mst_treatment as mtt on mtt.treatment_cd = ord.rst_treatment_cd
		left join treatment_in_hospital_cd_alpha iha on true
		left join treatment_in_hospital_cd_no ihn on true
	where ord.ord_no = @ordNo
	union all
	-- 障害者加算
	select 2 as item_sort_no,
		case
			when ihn.no_value = ''1'' then madd.in_hospital_cd_1
			when ihn.no_value = ''2'' then madd.in_hospital_cd_2
			when ihn.no_value = ''3'' then madd.in_hospital_cd_3
			else null
		end as code,
		da.value as name,
		null as count,
		null as unit,
		null as cutoff,
		null as sort_key
	from ord_main as ord
		cross join lateral json_array_elements(ord.addition_info::json) oadd
		cross join disability_allowance da
		left outer join mst_addition as madd on madd.addition_cd = to_number(oadd->>''cd'', ''9999999999'')
		left join addition_in_hospital_cd_no ihn on true
	where ord.ord_no = @ordNo
		and madd.addition_class = ''2''
	union all
	-- 透析困難コメント
	select 3 as item_sort_no,
		left(
			case
				when (
					select no_value
					from dial_diff_in_hospital_cd_no
				)::INTEGER = 1 then mst_dialysis_difficulty.in_hospital_cd_1::VARCHAR
				when (
					select no_value
					from dial_diff_in_hospital_cd_no
				)::INTEGER = 2 then mst_dialysis_difficulty.in_hospital_cd_2::VARCHAR
				else null
			end,
			20
		) as code,
		left(
			mst_dialysis_difficulty.dialysis_difficulty_name,
			256
		) as name,
		dc.value::numeric as count,
		null as unit,
		null as cutoff,
		lpad(
			(
				case
					when eddt.is_main = ''1'' then ''0''
					else ''1''
				end
			) || lpad(fddt.sort_no::text, 3, ''0''),
			4,
			''0''
		) as sort_key -- 並び順キー：is_main優先 → sort_no
	from mst_dialysis_difficulty
		cross join diffcomment_count dc
		inner join pat_dial_diff_data eddt on mst_dialysis_difficulty.dialysis_difficulty_cd = (eddt.dial_diff_cd)::INTEGER
		inner join mst_selector_dial_diff_data fddt on mst_dialysis_difficulty.dialysis_difficulty_cd = (fddt.code)::INTEGER
	where (
			select no_value
			from dialysis_output_setting
		) = ''0'' -- dialysis_output_setting が 「0」の場合のみ出力を行う。
	union all
	-- 透析液水質確保加算
	select 4 as item_sort_no,
		left(
			case
				coalesce(
					(
						select no_value::INTEGER
						from addition_in_hospital_cd_no
					),
					1
				)
				when 1 then mst_addition.in_hospital_cd_1::VARCHAR
				when 2 then mst_addition.in_hospital_cd_2::VARCHAR
				when 3 then mst_addition.in_hospital_cd_3::VARCHAR
				else mst_addition.in_hospital_cd_1::VARCHAR
			end,
			20
		) as code,
		left(mst_addition.addition_name, 256) as name,
		null as count,
		null as unit,
		null as cutoff,
		null as sort_key
	from addition_info
		inner join mst_addition on addition_info.code = mst_addition.addition_cd::text
	where addition_info.code = mst_addition.addition_cd::text
		and mst_addition.addition_class = ''1''
	union all
	-- 下肢抹消動脈疾患指導管理加算
	select 5 as item_sort_no,
		left(
			case
				coalesce(
					(
						select no_value::INTEGER
						from addition_in_hospital_cd_no
					),
					1
				)
				when 1 then mst_addition.in_hospital_cd_1::VARCHAR
				when 2 then mst_addition.in_hospital_cd_2::VARCHAR
				when 3 then mst_addition.in_hospital_cd_3::VARCHAR
				else mst_addition.in_hospital_cd_1::VARCHAR
			end,
			20
		) as code,
		left(mst_addition.addition_name, 256) as name,
		null as count,
		null as unit,
		null as cutoff,
		null as sort_key
	from addition_info
		inner join mst_addition on addition_info.code = mst_addition.addition_cd::text
		inner join addition_key_value on mst_addition.in_hospital_cd_2 in (
			addition_key_value.value::text
		)
	union all
	-- その他加算
	select 6 as item_sort_no,
		left(
			case
				coalesce(
					(
						select no_value::INTEGER
						from addition_in_hospital_cd_no
					),
					1
				)
				when 1 then mst_addition.in_hospital_cd_1::VARCHAR
				when 2 then mst_addition.in_hospital_cd_2::VARCHAR
				when 3 then mst_addition.in_hospital_cd_3::VARCHAR
				else mst_addition.in_hospital_cd_1::VARCHAR
			end,
			20
		) as code,
		left(mst_addition.addition_name, 256) as name,
		null as count,
		null as unit,
		null as cutoff,
		null as sort_key
	from mst_addition
	where mst_addition.facility_cd = @facilityCd
		and mst_addition.addition_cd::TEXT in (
			select code
			from addition_info
		)
		and (
			not exists (
				select 1
				from addition_key_value akv
				where mst_addition.in_hospital_cd_2 = akv.value
			)
			or mst_addition.in_hospital_cd_2 is null
		)
		and addition_class::numeric not in (1,2,9,10,11,13)
	union all
	-- 加算する治療項目
	select 7 as item_sort_no,
		code_values.code as code,
		name_values.name as name,
		null as count,
		null as unit,
		null as cutoff,
		code_values.padded_num::text as sort_key
	from code_values
		join name_values on code_values.padded_num = name_values.padded_num
	union all
	-- 抗凝固剤 
	select 8 as item_sort_no,
		anticoagulant.code as code,
		anticoagulant.name as name,
		anticoagulant.count as count,
		anticoagulant.unit as unit,
		null as cutoff,
		lpad(anticoagulant.code, 20, ''0'') as sort_key
	from (
			select *
			from direct_anticoagulant
			union all
			select *
			from mixed_anticoagulant
		) anticoagulant
	where class_type = 1
	union all
	-- 透析液
	select 9 as item_sort_no,
		case
			(
				select value
				from medi_hospital_cd
				limit 1
			)
			when ''1'' then left(in_hospital_cd_1, 20)
			when ''2'' then left(in_hospital_cd_2, 20)
			when ''3'' then left(in_hospital_cd_3, 20)
			when ''4'' then left(in_hospital_cd_4, 20)
		end as code,
		left(medicine_name, 80) as name,
		case
			-- 治療方法（装置モード）が（OHF、OHDF、HD+補液、プログラム補液）の場合、補液は透析液に合算
			when device_mode in (4, 7, 8, 10) then 
				case
					when rst_cond_info->''17''->>''value'' is null
					or rst_cond_info->''22''->>''value'' is null then null
					else (rst_cond_info->''17''->>''value'')::numeric + (rst_cond_info->''22''->>''value'')::numeric
				end
			else (rst_cond_info->''17''->>''value'')::numeric
			end as count,
		unit_second as unit,
		null as cutoff,
		null as sort_key
	from dialysate_info
	union all
	-- 補液
	select 10 as item_sort_no,
		case
			(
				select value
				from medi_hospital_cd
				limit 1
			)
			when ''1'' then left(in_hospital_cd_1, 20)
			when ''2'' then left(in_hospital_cd_2, 20)
			when ''3'' then left(in_hospital_cd_3, 20)
			when ''4'' then left(in_hospital_cd_4, 20)
		end as code,
		left(medicine_name, 80) as name,
		raw_count_value::numeric as count,
		unit_second as unit,
		null as cutoff,
		null as sort_key
	from infusion_info
	union all
	-- 処置
	select 11 as item_sort_no,
		f.code as code,
		f.name as name,
		f.count::numeric as count,
		f.unit as unit,
		null as cotoff,
		row_number() over(
			order by case
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval::numeric
				end
		)::text as sort_key
	from final_treatment_info f
	union all
	-- 消耗品
	select 12 as item_sort_no,
		oei.code as code,
		oei.name as name,
		oei.count::numeric as count,
		oei.unit as unit,
		null as cutoff,
		row_number() over(
			order by case
					when ( select setting_value from facility_equipment_order where setting_order = 1 ) = 0 then oei.registration_order::numeric
					when ( select setting_value from facility_equipment_order where setting_order = 1 ) = 1 then oei.meq_class_code_order
					when ( select setting_value from facility_equipment_order where setting_order = 1 ) = 2 then oei.meq_code_order
				end,
				case
					when ( select setting_value from facility_equipment_order where setting_order = 2 ) = 0 then oei.registration_order::numeric
					when ( select setting_value from facility_equipment_order where setting_order = 2 ) = 1 then oei.meq_class_code_order
					when ( select setting_value from facility_equipment_order where setting_order = 2 ) = 2 then oei.meq_code_order
				end,
				case
					when ( select setting_value from facility_equipment_order where setting_order = 3 ) = 0 then oei.registration_order::numeric
					when ( select setting_value from facility_equipment_order where setting_order = 3 ) = 1 then oei.meq_class_code_order
					when ( select setting_value from facility_equipment_order where setting_order = 3 ) = 2 then oei.meq_code_order
				end
		)::text as sort_key
	from ord_equip_info oei
	union all
	-- ダイアライザ
	select 13 as item_sort_no,
		case
			when ihn.value = ''1'' then md.in_hospital_cd_1
			when ihn.value = ''2'' then md.in_hospital_cd_2
			when ihn.value = ''3'' then md.in_hospital_cd_3
			when ihn.value = ''4'' then md.in_hospital_cd_4
			else md.in_hospital_cd_1
		end as code,
		md.model_number as name,
		dc.value::numeric as count,
		du.unit as unit,
		null as cutoff,
		null as sort_key
	from (
			select rst_cond_info->''5'' as cond_info_5
			from ord_main
			where ord_no = @ordNo
		) t
		inner join mst_dialyzer md on md.dialyzer_cd = (t.cond_info_5->>''value'')::integer
		cross join dialyzer_unit du
		cross join dialyzer_count dc
		left join dialyzer_in_hospital_cd_no ihn on true
	union all
	-- １次膜、２次膜
	select 14 as item_sort_no,
		ord_info.code as code,
		ord_info.name as name,
		vfc.value::numeric as count,
		ord_info.unit as unit,
		null as cutoff,
		ord_info.sort_key as sort_key
	from (
			select case
					(
						select value
						from equipment_in_hospital_cd_no
					)
					when ''1'' then left(mst_equipment.in_hospital_cd_1, 20)
					when ''2'' then left(mst_equipment.in_hospital_cd_2, 20)
					when ''3'' then left(mst_equipment.in_hospital_cd_3, 20)
					when ''4'' then left(mst_equipment.in_hospital_cd_4, 20)
				end as code,
				left(mst_equipment.equipment_name, 80) as name,
				mst_equipment.unit,
				''1'' as sort_key
			from primary_membrane_info,
				mst_equipment
			where primary_membrane_info.equipment_cd = mst_equipment.equipment_cd::text
			union all
			select case
					(
						select value
						from equipment_in_hospital_cd_no
					)
					when ''1'' then left(mst_equipment.in_hospital_cd_1, 20)
					when ''2'' then left(mst_equipment.in_hospital_cd_2, 20)
					when ''3'' then left(mst_equipment.in_hospital_cd_3, 20)
					when ''4'' then left(mst_equipment.in_hospital_cd_4, 20)
				end as code,
				left(mst_equipment.equipment_name, 80) as name,
				mst_equipment.unit,
				''2'' as sort_key
			from secondary_membrane_info,
				mst_equipment
			where secondary_membrane_info.equipment_cd = mst_equipment.equipment_cd::text
		) ord_info
		cross join val_filter_count vfc
),
oxygen_procedure_value as(
    --酸素手技コードと酸素手技名称
    select unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info->>''value'',
                        ''''
                    ),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value,
        info->>''key2'' as key2
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''OXYGEN_PROCEDURE''
),
oxygen_amount as (
    --酸素数量
    select SUM(
            (ord_rst_treatment_info->>''oxygen_amount'')::numeric
        ) as count
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) ord_rst_treatment_info
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
),
oxygen_item_value as(
    --酸素薬剤コードと薬剤名
    select unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info->>''value'',
                        ''''
                    ),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value,
        info->>''key2'' as key2
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''OXYGEN''
),
ord_medi_infos as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) WITH ORDINALITY as t(ord_medi_info, idx)
        LEFT JOIN mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            OR ord_medi_info->>''procedure_name'' NOT IN (select value from injection_procedure_names)
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(select value from class_names)
        )
    UNION ALL
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) WITH ORDINALITY as t(ord_treatment_info, idx)
        LEFT JOIN mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            OR ord_treatment_info->>''procedure_name'' NOT IN (select value from injection_procedure_names)
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(select value from class_names)
        )
    UNION ALL
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        CASE
            medi_mix_info->>''solvent''
            WHEN ''0'' THEN (ord_medi_info->>''amount'')::NUMERIC * (medi_mix_info->>''amount'')::NUMERIC
            WHEN ''1'' THEN (medi_mix_info->>''amount'')::NUMERIC
        END as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) WITH ORDINALITY as t(ord_medi_info, idx)
        LEFT JOIN mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        LEFT JOIN json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        LEFT JOIN mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            OR ord_medi_info->>''procedure_name'' NOT IN (select value from injection_procedure_names)
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(select value from class_names)
        )
    UNION ALL
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        CASE
            medi_mix_info->>''solvent''
            WHEN ''0'' THEN (ord_treatment_info->>''amount'')::NUMERIC * (medi_mix_info->>''amount'')::NUMERIC
            WHEN ''1'' THEN (medi_mix_info->>''amount'')::NUMERIC
        END as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) WITH ORDINALITY as t(ord_treatment_info, idx)
        LEFT JOIN mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        LEFT JOIN json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        LEFT JOIN mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            OR ord_treatment_info->>''procedure_name'' NOT IN (select value from injection_procedure_names)
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(select value from class_names)
        )
),
final_medi_info as (
    select CASE
            (
                select value
                from medicine_in_hospital_cd_no
            )
            WHEN ''1'' THEN left(med.in_hospital_cd_1, 20)
            WHEN ''2'' THEN left(med.in_hospital_cd_2, 20)
            WHEN ''3'' THEN left(med.in_hospital_cd_3, 20)
            WHEN ''4'' THEN left(med.in_hospital_cd_4, 20)
        END as code,
        left(med.medicine_name, 80) as name,
        SUM(amount) as count,
        MIN(med.unit) as unit,
        MIN(med.class_cd) as class_cd,
        MIN(omi.registration_order) as registration_order,
        MIN(mst_medi.medi_code_order) as medi_code_order,
        MIN(mst_medi.medi_class_code_order) as class_code_order,
        MIN(omi.medicine_type::int) as medicine_type_order,
        MIN(t.timing_code_order) as timing_code_order,
        MIN(p.procedure_code_order) as procedure_code_order,
        MIN(omi.date_interval::int) as date_interval
    from ord_medi_infos omi
        LEFT JOIN mst_medicine med on omi.medicine_cd = med.medicine_cd::text
        left join mst_medi on med.class_cd = mst_medi.class_cd
        and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
    where (
            select value
            from medicine_add_flag
        ) = ''1''
    group by code,
        name
    union all
    select CASE
            (
                select value
                from medicine_in_hospital_cd_no
            )
            WHEN ''1'' THEN left(med.in_hospital_cd_1, 20)
            WHEN ''2'' THEN left(med.in_hospital_cd_2, 20)
            WHEN ''3'' THEN left(med.in_hospital_cd_3, 20)
            WHEN ''4'' THEN left(med.in_hospital_cd_4, 20)
        END as code,
        left(med.medicine_name, 80) as name,
        amount as count,
        med.unit,
        med.class_cd,
        omi.registration_order as registration_order,
        mst_medi.medi_code_order as medi_code_order,
        mst_medi.medi_class_code_order as class_code_order,
        omi.medicine_type::int as medicine_type_order,
        t.timing_code_order as timing_code_order,
        p.procedure_code_order as procedure_code_order,
        omi.date_interval::int as date_interval
    from ord_medi_infos omi
        LEFT JOIN mst_medicine med on omi.medicine_cd = med.medicine_cd::text
        left join mst_medi on med.class_cd = mst_medi.class_cd
        and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
    where (
            select value
            from medicine_add_flag
        ) = ''0''
),
oxygen_all as (
    --酸素手技
    select
        (
            select value
            from oxygen_procedure_value
            where key2 = ''MEDI_CD''
        ) as code
    where ( select value from oxygen_procedure_value where key2 = ''MEDI_CD'' ) != '''' and  ( select value from oxygen_procedure_value where key2 = ''MEDI_CD'' ) is not null 
    and ( select value from oxygen_procedure_value where key2 = ''MEDI_NAME'' ) != '''' and  ( select value from oxygen_procedure_value where key2 = ''MEDI_NAME'' ) is not null
    and (select count from oxygen_amount) > 0
    union all
    --酸素
    select
        (
            select value
            from oxygen_item_value
            where key2 = ''MEDI_CD''
        ) as code
    from oxygen_amount
    where oxygen_amount.count is not null and oxygen_amount.count::numeric != 0
    union all
    --薬剤分類が未確認の薬剤
    select
        f.code as code
    from final_medi_info f
    where (select value from default_medicine_group) = ''酸素''
)


-- 処置治療項目情報と酸素情報が存在する場合のみレコードを返す
select
	true as "exists",
    @ordNo as ord_no,
    @facilityCd as facility_cd, 
    @key0 as key0,
    @patId as pat_id,
    ''01'' as detail_id
where exists (
	select oxygen_all.code as code
	from oxygen_all
	union all
	select treat_all.code as code
	from treat_all 
)
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 処置・治療項目情報の存在確認', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307033, "field_name": "dial_diff_cds", "replace_var": "@dialDiffCds"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307132, 'with default_medicine_group as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''DEFAULT_MEDICINE_GROUP''
),
-- 
-- 投与情報
-- 
medicine_order_units_num as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
medicine_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from medicine_order_units_num,
        generate_series(1, medicine_order_units_num.value) as i
),
medicine_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_MEDICINE_INFO
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
),
medicine_classes as (
    -- 投与薬剤として出力される薬剤分類名
    select idx.suffix,
        msi.value
    from medicine_setting_info as msi
        join medicine_unit_indices as idx on msi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 注射情報
-- 
injection_order_units_num as (
    -- 出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
injection_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from injection_order_units_num,
        generate_series(1, injection_order_units_num.value) as i
),
injection_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_INJECTION_INFOを取得
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
),
injection_procedure_names as (
    -- 注射情報として出力する手技名を取得
    select idx.suffix,
        isi.value
    from injection_setting_info as isi
        join injection_unit_indices as idx on isi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 手術・麻酔
-- 
surgery_medicine_class_name as (
    -- 手術・麻酔として出力する薬剤分類名を取得
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' = ''SURGERY''
),
-- 
-- 処置
-- 
treatment_num as (
    -- 処置として出力する対象の薬剤分類の数 (TREATMENT_NUM)
    select unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' = ''TREATMENT_NUM''
    limit 1
), treatment_number_series as (
    -- TREATMENT_NUMの数を基にTREATMENT_NAME_{0:D2} を生成
    select LPAD(n::text, 2, ''0'') as padded_num
    from generate_series(
            1,
            (
                select value
                from treatment_num
            )::numeric
        ) as t(n)
),
treatment_name_keys as (
    -- TREATMENT_NAME_{0:D2} の key を生成
    select ''TREATMENT_NAME_'' || padded_num as name_key
    from treatment_number_series
),
treatment_key_value_pairs as (
    -- TREATMENT_NAME_{0:D2} の key/value の組み合わせを出力
    select info->>''key2'' as key,
        unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' like ''TREATMENT_NAME_%''
),
treatment_names as (
    -- TREATMENT_NAME_{0:D2} の名前を取得
    select treatment_name_keys.name_key,
        kv.value as treatment_name
    from treatment_name_keys
        join treatment_key_value_pairs kv on kv.key = treatment_name_keys.name_key
),
class_names as (
    select treatment_name as value
    from treatment_names
    union
    select value
    from surgery_medicine_class_name
    union
    select value
    from medicine_classes
),
unreferenced_medicines as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
),
order_units_num as (
    -- 出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from order_units_num,
        generate_series(1, order_units_num.value) as i
),
prescription_xml_injection_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_INJECTION_INFOを取得
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
),
ord_medi_infos as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select 
        ord_medi_info->>''cd'' as medicine_cd
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''procedure_name'' in (
            select value
            from injection_procedure_names
        )
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''procedure_name'' in (
            select value
            from injection_procedure_names
        )
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select
        medi_mix_info->>''cd'' as medicine_cd
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''procedure_name'' in (
            select value
            from injection_procedure_names
        )
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select 
        medi_mix_info->>''cd'' as medicine_cd
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''procedure_name'' in (
            select value
            from injection_procedure_names
        )
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
)

select
	true as "exists",
    @ordNo as ord_no,
    @facilityCd as facility_cd, 
    @key0 as key0,
    @patId as pat_id,
    ''01'' as detail_id
where exists (
    select *
    from ord_medi_infos as omi
) or exists (
    select 
    *
    from unreferenced_medicines as umi
    where (select value from default_medicine_group) in ( select value from injection_procedure_names )
)', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 注射情報の存在確認', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307131, 'with default_medicine_group as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''DEFAULT_MEDICINE_GROUP''
),
-- 
-- 投与情報
-- 
medicine_order_units_num as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
medicine_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from medicine_order_units_num,
        generate_series(1, medicine_order_units_num.value) as i
),
medicine_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_MEDICINE_INFO
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
),
medicine_classes as (
    -- 投与薬剤として出力される薬剤分類名
    select idx.suffix,
        msi.value
    from medicine_setting_info as msi
        join medicine_unit_indices as idx on msi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 注射情報
-- 
injection_order_units_num as (
    -- 出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
injection_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from injection_order_units_num,
        generate_series(1, injection_order_units_num.value) as i
),
injection_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_INJECTION_INFOを取得
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
),
injection_procedure_names as (
    -- 注射情報として出力する手技名を取得
    select idx.suffix,
        isi.value
    from injection_setting_info as isi
        join injection_unit_indices as idx on isi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 手術・麻酔
-- 
surgery_medicine_class_name as (
    -- 手術・麻酔として出力する薬剤分類名を取得
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' = ''SURGERY''
),
-- 
-- 処置
-- 
treatment_num as (
    -- 処置として出力する対象の薬剤分類の数 (TREATMENT_NUM)
    select unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' = ''TREATMENT_NUM''
    limit 1
), treatment_number_series as (
    -- TREATMENT_NUMの数を基にTREATMENT_NAME_{0:D2} を生成
    select LPAD(n::text, 2, ''0'') as padded_num
    from generate_series(
            1,
            (
                select value
                from treatment_num
            )::numeric
        ) as t(n)
),
treatment_name_keys as (
    -- TREATMENT_NAME_{0:D2} の key を生成
    select ''TREATMENT_NAME_'' || padded_num as name_key
    from treatment_number_series
),
treatment_key_value_pairs as (
    -- TREATMENT_NAME_{0:D2} の key/value の組み合わせを出力
    select info->>''key2'' as key,
        unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' like ''TREATMENT_NAME_%''
),
treatment_names as (
    -- TREATMENT_NAME_{0:D2} の名前を取得
    select treatment_name_keys.name_key,
        kv.value as treatment_name
    from treatment_name_keys
        join treatment_key_value_pairs kv on kv.key = treatment_name_keys.name_key
),
class_names as (
    select treatment_name as value
    from treatment_names
    union
    select value
    from surgery_medicine_class_name
    union
    select value
    from medicine_classes
),
unreferenced_medicines as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
),
order_units_num as (
    -- 
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
unit_indices as (
    select LPAD(i::text, 2, ''0'') as suffix
    from order_units_num,
        generate_series(1, order_units_num.value) as i
),
order_unit_values as (
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
),
output_medicine_classes as (
    select idx.suffix,
        ouv.value
    from order_unit_values as ouv
        join unit_indices as idx on ouv.key2 = ''ORDER_UNITS_'' || idx.suffix
),
ord_medi_infos as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select
        ord_medi_info->>''cd'' as medicine_cd
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name in (
            select value
            from output_medicine_classes
        )
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name in (
            select value
            from output_medicine_classes
        )
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select 
        medi_mix_info->>''cd'' as medicine_cd
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name in (
            select value
            from output_medicine_classes
        )
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select 
        medi_mix_info->>''cd'' as medicine_cd
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name in (
            select value
            from output_medicine_classes
        )
)

select
	true as "exists",
    @ordNo as ord_no,
    @facilityCd as facility_cd, 
    @key0 as key0,
    @patId as pat_id,
    ''01'' as detail_id
where exists (
    select 
    *
    from ord_medi_infos as omi
) or exists (
    select 
    *
    from unreferenced_medicines as umi
    where (select value from default_medicine_group) in ( select value from output_medicine_classes )
)', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 投薬情報の存在確認', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307130, 'WITH default_medicine_group as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''DEFAULT_MEDICINE_GROUP''
),
-- 
-- 投与情報
-- 
medicine_order_units_num as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
medicine_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from medicine_order_units_num,
        generate_series(1, medicine_order_units_num.value) as i
),
medicine_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_MEDICINE_INFO
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
),
medicine_classes as (
    -- 投与薬剤として出力される薬剤分類名
    select idx.suffix,
        msi.value
    from medicine_setting_info as msi
        join medicine_unit_indices as idx on msi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 注射情報
-- 
injection_order_units_num as (
    -- 出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
injection_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from injection_order_units_num,
        generate_series(1, injection_order_units_num.value) as i
),
injection_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_INJECTION_INFOを取得
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
),
injection_procedure_names as (
    -- 注射情報として出力する手技名を取得
    select idx.suffix,
        isi.value
    from injection_setting_info as isi
        join injection_unit_indices as idx on isi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 手術・麻酔
-- 
surgery_medicine_class_name as (
    -- 手術・麻酔として出力する薬剤分類名を取得
    select
        coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''PRESCRIPTION_DETAILS''
        and info ->> ''key2'' = ''SURGERY''
),
-- 
-- 処置
-- 
treatment_num as (
	-- 処置として出力する対象の薬剤分類の数 (TREATMENT_NUM)
	select unnest(
			string_to_array(
				coalesce(
					nullif(info->>''value'', ''''),
					info->>''default_v''
				),
				'',''
			)
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''TREATMENT_NUM''
	limit 1
), treatment_number_series as (
	-- TREATMENT_NUMの数を基にTREATMENT_NAME_{0:D2} を生成
	select LPAD(n::text, 2, ''0'') as padded_num
	from generate_series(
			1,
			(
				select value
				from treatment_num
			)::numeric
		) as t(n)
),
treatment_name_keys as (
	-- TREATMENT_NAME_{0:D2} の key を生成
	select ''TREATMENT_NAME_'' || padded_num as name_key
	from treatment_number_series
),
treatment_key_value_pairs as (
	-- TREATMENT_NAME_{0:D2} の key/value の組み合わせを出力
	select info->>''key2'' as key,
		unnest(
			string_to_array(
				coalesce(
					nullif(info->>''value'', ''''),
					info->>''default_v''
				),
				'',''
			)
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' like ''TREATMENT_NAME_%''
),
treatment_names as (
	-- TREATMENT_NAME_{0:D2} の名前を取得
	select treatment_name_keys.name_key,
		kv.value as treatment_name
	from treatment_name_keys
		join treatment_key_value_pairs kv on kv.key = treatment_name_keys.name_key
),
class_names as (
	select treatment_name as value from treatment_names
	union
	select value from surgery_medicine_class_name
	union
	select value from medicine_classes
),
oxygen_procedure_value as(
    --酸素手技コードと酸素手技名称
    select unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info->>''value'',
                        ''''
                    ),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value,
        info->>''key2'' as key2
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''OXYGEN_PROCEDURE''
),
oxygen_amount as (
    --酸素数量
    select SUM(
            (ord_rst_treatment_info->>''oxygen_amount'')::numeric
        ) as count
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) ord_rst_treatment_info
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
),
oxygen_item_value as(
    --酸素薬剤コードと薬剤名
    select unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info->>''value'',
                        ''''
                    ),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value,
        info->>''key2'' as key2
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''OXYGEN''
),
ord_medi_infos as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) WITH ORDINALITY as t(ord_medi_info, idx)
        LEFT JOIN mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            OR ord_medi_info->>''procedure_name'' NOT IN (select value from injection_procedure_names)
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(select value from class_names)
        )
    UNION ALL
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) WITH ORDINALITY as t(ord_treatment_info, idx)
        LEFT JOIN mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            OR ord_treatment_info->>''procedure_name'' NOT IN (select value from injection_procedure_names)
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(select value from class_names)
        )
    UNION ALL
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        CASE
            medi_mix_info->>''solvent''
            WHEN ''0'' THEN (ord_medi_info->>''amount'')::NUMERIC * (medi_mix_info->>''amount'')::NUMERIC
            WHEN ''1'' THEN (medi_mix_info->>''amount'')::NUMERIC
        END as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) WITH ORDINALITY as t(ord_medi_info, idx)
        LEFT JOIN mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        LEFT JOIN json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        LEFT JOIN mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            OR ord_medi_info->>''procedure_name'' NOT IN (select value from injection_procedure_names)
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(select value from class_names)
        )
    UNION ALL
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        CASE
            medi_mix_info->>''solvent''
            WHEN ''0'' THEN (ord_treatment_info->>''amount'')::NUMERIC * (medi_mix_info->>''amount'')::NUMERIC
            WHEN ''1'' THEN (medi_mix_info->>''amount'')::NUMERIC
        END as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) WITH ORDINALITY as t(ord_treatment_info, idx)
        LEFT JOIN mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        LEFT JOIN json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        LEFT JOIN mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            OR ord_treatment_info->>''procedure_name'' NOT IN (select value from injection_procedure_names)
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(select value from class_names)
        )
),
medicine_in_hospital_cd_no as (
    --薬剤マスタの参照する連携コード
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join LATERAL json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''MST''
        and info->>''key2'' = ''MEDICINE_IN_HOSPITAL_CD_NO''
),
medicine_add_flag as (
    --薬剤合算フラグ
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join LATERAL json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''DISTINCT_MEDICINE_FLAG''
),
facility_medicine_order as (
    -- 施設設定マスタ(No.107)
    select row_number () over () as setting_order,
        -- 適用順 
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
),
medi_order as (
    -- 薬剤マスタの並び順
    select index_no::int as medi_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_code,
        order_cd->>''name'' as name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine''
),
medi_class_order as (
    -- 薬剤分類マスタの並び順
    select index_no::int as medi_class_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_class_code,
        order_cd->>''name'' as class_name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine_class''
),
timing_order as (
    -- 投与タイミングマスタの並び順
    select index_no::int as timing_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as timing_code
    from mst_selector
        cross join LATERAL jsonb_array_elements(order_settings->''items'') WITH ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicate_timing''
),
procedure_order as (
    -- 手技マスタの並び順
    select index_no::int as procedure_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as procedure_code
    from mst_selector
        cross join LATERAL jsonb_array_elements(order_settings->''items'') WITH ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_procedure''
),
mst_medi as (
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
),
final_medi_info as (
    select CASE
            (
                select value
                from medicine_in_hospital_cd_no
            )
            WHEN ''1'' THEN left(med.in_hospital_cd_1, 20)
            WHEN ''2'' THEN left(med.in_hospital_cd_2, 20)
            WHEN ''3'' THEN left(med.in_hospital_cd_3, 20)
            WHEN ''4'' THEN left(med.in_hospital_cd_4, 20)
        END as code,
        left(med.medicine_name, 80) as name,
        SUM(amount) as count,
        MIN(med.unit) as unit,
        MIN(med.class_cd) as class_cd,
        MIN(omi.registration_order) as registration_order,
        MIN(mst_medi.medi_code_order) as medi_code_order,
        MIN(mst_medi.medi_class_code_order) as class_code_order,
        MIN(omi.medicine_type::int) as medicine_type_order,
        MIN(t.timing_code_order) as timing_code_order,
        MIN(p.procedure_code_order) as procedure_code_order,
        MIN(omi.date_interval::int) as date_interval
    from ord_medi_infos omi
        LEFT JOIN mst_medicine med on omi.medicine_cd = med.medicine_cd::text
        left join mst_medi on med.class_cd = mst_medi.class_cd
        and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
    where (
            select value
            from medicine_add_flag
        ) = ''1''
    group by code,
        name
    union all
    select CASE
            (
                select value
                from medicine_in_hospital_cd_no
            )
            WHEN ''1'' THEN left(med.in_hospital_cd_1, 20)
            WHEN ''2'' THEN left(med.in_hospital_cd_2, 20)
            WHEN ''3'' THEN left(med.in_hospital_cd_3, 20)
            WHEN ''4'' THEN left(med.in_hospital_cd_4, 20)
        END as code,
        left(med.medicine_name, 80) as name,
        amount as count,
        med.unit,
        med.class_cd,
        omi.registration_order as registration_order,
        mst_medi.medi_code_order as medi_code_order,
        mst_medi.medi_class_code_order as class_code_order,
        omi.medicine_type::int as medicine_type_order,
        t.timing_code_order as timing_code_order,
        p.procedure_code_order as procedure_code_order,
        omi.date_interval::int as date_interval
    from ord_medi_infos omi
        LEFT JOIN mst_medicine med on omi.medicine_cd = med.medicine_cd::text
        left join mst_medi on med.class_cd = mst_medi.class_cd
        and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
    where (
            select value
            from medicine_add_flag
        ) = ''0''
),
oxygen_all as (
    --酸素手技
    select 1 as item_sort_no,
        (
            select value
            from oxygen_procedure_value
            where key2 = ''MEDI_CD''
        ) as code,
        (
            select value
            from oxygen_procedure_value
            where key2 = ''MEDI_NAME''
        ) as name,
        null as count,
        null as unit,
        null as cutoff,
        null as sort_key
    where ( select value from oxygen_procedure_value where key2 = ''MEDI_CD'' ) != '''' and  ( select value from oxygen_procedure_value where key2 = ''MEDI_CD'' ) is not null 
    and ( select value from oxygen_procedure_value where key2 = ''MEDI_NAME'' ) != '''' and  ( select value from oxygen_procedure_value where key2 = ''MEDI_NAME'' ) is not null
    and (select count from oxygen_amount) > 0
    union all
    --酸素
    select 2 as item_sort_no,
        (
            select value
            from oxygen_item_value
            where key2 = ''MEDI_CD''
        ) as code,
        (
            select value
            from oxygen_item_value
            where key2 = ''MEDI_NAME''
        ) as name,
        oxygen_amount.count as count,
        (
            select value
            from oxygen_item_value
            where key2 = ''UNIT''
        ) as unit,
        null as cutoff,
        null as sort_key
    from oxygen_amount
    where oxygen_amount.count is not null and oxygen_amount.count::numeric != 0
    union all
    --薬剤分類が未確認の薬剤
    select 3 as item_sort_no,
        f.code as code,
        f.name as name,
        f.count as count,
        f.unit as unit,
        null as cutoff,
        ROW_NUMBER() OVER(
            order by case
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval::text
                end,
                case
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval::text
                end,
                case
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval::text
                end,
                case
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval::text
                end,
                case
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval::text
                end,
                case
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval::text
                end,
                case
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order::text
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval::text
                end
        )::text as sort_key
    from final_medi_info f
    where (select value from default_medicine_group) = ''酸素''
)


select
	true as "exists",
    @ordNo as ord_no,
    @facilityCd as facility_cd, 
    @key0 as key0,
    ''01'' as detail_id
where exists (
select oxygen_all.code as code,
    oxygen_all.name as name,
    REGEXP_REPLACE(
        TRIM( TRAILING ''.'' FROM TRIM( TRAILING ''0'' FROM ROUND(oxygen_all.count::numeric, 2)::TEXT ) ), ''^(\d+)\.0+$'', ''\1''
    ) as count,
    oxygen_all.unit as unit,
    oxygen_all.cutoff as cutoff,
    row_number() over (
        order by item_sort_no,
            sort_key
    ) as seq_no
from oxygen_all
order by seq_no
)
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 酸素情報の存在確認', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307129, 'WITH admission_supported AS(
    SELECT
        COALESCE(
            NULLIF(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) AS value
    FROM
        ntss.mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''KARTE_ORD_SEND''
        AND info ->> ''key2'' = ''ADMISSION_SUPPORTED''
),
in_patient_output_set AS(
    SELECT
        COALESCE(
            NULLIF(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) AS value
    FROM
        ntss.mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''PRESCRIPTION_INFO''
        AND info ->> ''key2'' = ''IN_PATIENT_OUTPUT_SET''
)

SELECT 
	(SELECT value FROM admission_supported) as admission_supported,
	(SELECT value FROM in_patient_output_set) as in_patient_output_set', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入院患者の制御', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307128, ' SELECT 1 FROM pat_personal_main
WHERE
  pat_id = @patId
  AND facility_cd = @facilityCd
  AND NOT(
    in_out_class = 1
    -- 入院対応使用有無 0:使用しない 1:使用する,入院患者処方データ出力有無 0：出力しない　1：出力する
    AND @admissionSupported = 1
    AND @inPatientOutputSet = 0
  );', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入院患者の制御', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307129, "field_name": "admission_supported", "replace_var": "@admissionSupported"}, {"sql_cd": -307129, "field_name": "in_patient_output_set", "replace_var": "@inPatientOutputSet"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307127, 'WITH default_medicine_group as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''DEFAULT_MEDICINE_GROUP''
),
-- 
-- 投与情報
-- 
medicine_order_units_num as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
medicine_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from medicine_order_units_num,
        generate_series(1, medicine_order_units_num.value) as i
),
medicine_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_MEDICINE_INFO
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
),
medicine_classes as (
    -- 投与薬剤として出力される薬剤分類名
    select idx.suffix,
        msi.value
    from medicine_setting_info as msi
        join medicine_unit_indices as idx on msi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 注射情報
-- 
injection_order_units_num as (
    -- 出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
injection_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from injection_order_units_num,
        generate_series(1, injection_order_units_num.value) as i
),
injection_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_INJECTION_INFOを取得
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
),
injection_procedure_names as (
    -- 注射情報として出力する手技名を取得
    select idx.suffix,
        isi.value
    from injection_setting_info as isi
        join injection_unit_indices as idx on isi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 手術・麻酔
-- 
surgery_medicine_class_name as (
    -- 手術・麻酔として出力する薬剤分類名を取得
    select
        coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''PRESCRIPTION_DETAILS''
        and info ->> ''key2'' = ''SURGERY''
),
-- 
-- 処置
-- 
treatment_num as (
	-- 処置として出力する対象の薬剤分類の数 (TREATMENT_NUM)
	select unnest(
			string_to_array(
				coalesce(
					nullif(info->>''value'', ''''),
					info->>''default_v''
				),
				'',''
			)
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''TREATMENT_NUM''
	limit 1
), treatment_number_series as (
	-- TREATMENT_NUMの数を基にTREATMENT_NAME_{0:D2} を生成
	select LPAD(n::text, 2, ''0'') as padded_num
	from generate_series(
			1,
			(
				select value
				from treatment_num
			)::numeric
		) as t(n)
),
treatment_name_keys as (
	-- TREATMENT_NAME_{0:D2} の key を生成
	select ''TREATMENT_NAME_'' || padded_num as name_key
	from treatment_number_series
),
treatment_key_value_pairs as (
	-- TREATMENT_NAME_{0:D2} の key/value の組み合わせを出力
	select info->>''key2'' as key,
		unnest(
			string_to_array(
				coalesce(
					nullif(info->>''value'', ''''),
					info->>''default_v''
				),
				'',''
			)
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' like ''TREATMENT_NAME_%''
),
treatment_names as (
	-- TREATMENT_NAME_{0:D2} の名前を取得
	select treatment_name_keys.name_key,
		kv.value as treatment_name
	from treatment_name_keys
		join treatment_key_value_pairs kv on kv.key = treatment_name_keys.name_key
),
class_names as (
	select treatment_name as value from treatment_names
	union
	select value from surgery_medicine_class_name
	union
	select value from medicine_classes
),
oxygen_procedure_value as(
    --酸素手技コードと酸素手技名称
    select unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info->>''value'',
                        ''''
                    ),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value,
        info->>''key2'' as key2
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''OXYGEN_PROCEDURE''
),
oxygen_amount as (
    --酸素数量
    select SUM(
            (ord_rst_treatment_info->>''oxygen_amount'')::numeric
        ) as count
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) ord_rst_treatment_info
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
),
oxygen_item_value as(
    --酸素薬剤コードと薬剤名
    select unnest(
            string_to_array(
                coalesce(
                    nullif(
                        info->>''value'',
                        ''''
                    ),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value,
        info->>''key2'' as key2
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''OXYGEN''
),
ord_medi_infos as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) WITH ORDINALITY as t(ord_medi_info, idx)
        LEFT JOIN mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            OR ord_medi_info->>''procedure_name'' NOT IN (select value from injection_procedure_names)
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(select value from class_names)
        )
    UNION ALL
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) WITH ORDINALITY as t(ord_treatment_info, idx)
        LEFT JOIN mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            OR ord_treatment_info->>''procedure_name'' NOT IN (select value from injection_procedure_names)
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(select value from class_names)
        )
    UNION ALL
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        CASE
            medi_mix_info->>''solvent''
            WHEN ''0'' THEN (ord_medi_info->>''amount'')::NUMERIC * (medi_mix_info->>''amount'')::NUMERIC
            WHEN ''1'' THEN (medi_mix_info->>''amount'')::NUMERIC
        END as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) WITH ORDINALITY as t(ord_medi_info, idx)
        LEFT JOIN mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        LEFT JOIN json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        LEFT JOIN mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            OR ord_medi_info->>''procedure_name'' NOT IN (select value from injection_procedure_names)
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(select value from class_names)
        )
    UNION ALL
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        CASE
            medi_mix_info->>''solvent''
            WHEN ''0'' THEN (ord_treatment_info->>''amount'')::NUMERIC * (medi_mix_info->>''amount'')::NUMERIC
            WHEN ''1'' THEN (medi_mix_info->>''amount'')::NUMERIC
        END as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) WITH ORDINALITY as t(ord_treatment_info, idx)
        LEFT JOIN mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        LEFT JOIN json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        LEFT JOIN mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        LEFT JOIN mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            OR ord_treatment_info->>''procedure_name'' NOT IN (select value from injection_procedure_names)
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(select value from class_names)
        )
),
medicine_in_hospital_cd_no as (
    --薬剤マスタの参照する連携コード
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join LATERAL json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''MST''
        and info->>''key2'' = ''MEDICINE_IN_HOSPITAL_CD_NO''
),
medicine_add_flag as (
    --薬剤合算フラグ
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join LATERAL json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''DISTINCT_MEDICINE_FLAG''
),
facility_medicine_order as (
    -- 施設設定マスタ(No.107)
    select row_number () over () as setting_order,
        -- 適用順 
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
),
medi_order as (
    -- 薬剤マスタの並び順
    select index_no::int as medi_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_code,
        order_cd->>''name'' as name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine''
),
medi_class_order as (
    -- 薬剤分類マスタの並び順
    select index_no::int as medi_class_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_class_code,
        order_cd->>''name'' as class_name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine_class''
),
timing_order as (
    -- 投与タイミングマスタの並び順
    select index_no::int as timing_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as timing_code
    from mst_selector
        cross join LATERAL jsonb_array_elements(order_settings->''items'') WITH ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicate_timing''
),
procedure_order as (
    -- 手技マスタの並び順
    select index_no::int as procedure_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as procedure_code
    from mst_selector
        cross join LATERAL jsonb_array_elements(order_settings->''items'') WITH ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_procedure''
),
mst_medi as (
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
),
final_medi_info as (
    select CASE
            (
                select value
                from medicine_in_hospital_cd_no
            )
            WHEN ''1'' THEN left(med.in_hospital_cd_1, 20)
            WHEN ''2'' THEN left(med.in_hospital_cd_2, 20)
            WHEN ''3'' THEN left(med.in_hospital_cd_3, 20)
            WHEN ''4'' THEN left(med.in_hospital_cd_4, 20)
        END as code,
        left(med.medicine_name, 80) as name,
        SUM(amount) as count,
        MIN(med.unit) as unit,
        MIN(med.class_cd) as class_cd,
        MIN(omi.registration_order) as registration_order,
        MIN(mst_medi.medi_code_order) as medi_code_order,
        MIN(mst_medi.medi_class_code_order) as class_code_order,
        MIN(omi.medicine_type::int) as medicine_type_order,
        MIN(t.timing_code_order) as timing_code_order,
        MIN(p.procedure_code_order) as procedure_code_order,
        MIN(omi.date_interval::int) as date_interval
    from ord_medi_infos omi
        LEFT JOIN mst_medicine med on omi.medicine_cd = med.medicine_cd::text
        left join mst_medi on med.class_cd = mst_medi.class_cd
        and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
    where (
            select value
            from medicine_add_flag
        ) = ''1''
    group by code,
        name
    union all
    select CASE
            (
                select value
                from medicine_in_hospital_cd_no
            )
            WHEN ''1'' THEN left(med.in_hospital_cd_1, 20)
            WHEN ''2'' THEN left(med.in_hospital_cd_2, 20)
            WHEN ''3'' THEN left(med.in_hospital_cd_3, 20)
            WHEN ''4'' THEN left(med.in_hospital_cd_4, 20)
        END as code,
        left(med.medicine_name, 80) as name,
        amount as count,
        med.unit,
        med.class_cd,
        omi.registration_order as registration_order,
        mst_medi.medi_code_order as medi_code_order,
        mst_medi.medi_class_code_order as class_code_order,
        omi.medicine_type::int as medicine_type_order,
        t.timing_code_order as timing_code_order,
        p.procedure_code_order as procedure_code_order,
        omi.date_interval::int as date_interval
    from ord_medi_infos omi
        LEFT JOIN mst_medicine med on omi.medicine_cd = med.medicine_cd::text
        left join mst_medi on med.class_cd = mst_medi.class_cd
        and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
    where (
            select value
            from medicine_add_flag
        ) = ''0''
),
oxygen_all as (
    --酸素手技
    select 1 as item_sort_no,
        (
            select value
            from oxygen_procedure_value
            where key2 = ''MEDI_CD''
        ) as code,
        (
            select value
            from oxygen_procedure_value
            where key2 = ''MEDI_NAME''
        ) as name,
        null as count,
        null as unit,
        null as cutoff,
        0 as sort_key
    where ( select value from oxygen_procedure_value where key2 = ''MEDI_CD'' ) != '''' and  ( select value from oxygen_procedure_value where key2 = ''MEDI_CD'' ) is not null 
    and ( select value from oxygen_procedure_value where key2 = ''MEDI_NAME'' ) != '''' and  ( select value from oxygen_procedure_value where key2 = ''MEDI_NAME'' ) is not null
    and (select count from oxygen_amount) > 0
    union all
    --酸素
    select 2 as item_sort_no,
        (
            select value
            from oxygen_item_value
            where key2 = ''MEDI_CD''
        ) as code,
        (
            select value
            from oxygen_item_value
            where key2 = ''MEDI_NAME''
        ) as name,
        oxygen_amount.count as count,
        (
            select value
            from oxygen_item_value
            where key2 = ''UNIT''
        ) as unit,
        null as cutoff,
        0 as sort_key
    from oxygen_amount
    where oxygen_amount.count is not null and oxygen_amount.count::numeric != 0
    union all
    --薬剤分類が未確認の薬剤
    select 3 as item_sort_no,
        f.code as code,
        f.name as name,
        f.count as count,
        f.unit as unit,
        null as cutoff,
        ROW_NUMBER() OVER(
            order by case
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order::numeric
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval
                end,
                case
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order::numeric
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval
                end,
                case
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order::numeric
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval
                end,
                case
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order::numeric
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval
                end,
                case
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order::numeric
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval
                end,
                case
                    when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 0 then f.registration_order::numeric
                    when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 1 then f.class_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 2 then f.medicine_type_order
                    when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 3 then f.medi_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 4 then f.timing_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 5 then f.procedure_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 6 then f.date_interval
                end,
                case
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::numeric
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
                    when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval
                end,
                f.medi_code_order
        ) as sort_key
    from final_medi_info f
    where (select value from default_medicine_group) = ''酸素''
)
select oxygen_all.code as code,
    oxygen_all.name as name,
    REGEXP_REPLACE(
        TRIM( TRAILING ''.'' FROM TRIM( TRAILING ''0'' FROM ROUND(oxygen_all.count::numeric, 2)::TEXT ) ), ''^(\d+)\.0+$'', ''\1''
    ) as count,
    oxygen_all.unit as unit,
    oxygen_all.cutoff as cutoff,
    row_number() over (
        order by item_sort_no,
            sort_key
    ) as seq_no
from oxygen_all
order by seq_no', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307126, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 user_name取得用(医学管理料情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307110, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307125, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 user_name取得用(導入期加算入力情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307109, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307124, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 user_name取得用(夜間・休日加算情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307108, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307123, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 user_name取得用(処置・治療項目情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307107, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307122, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 user_name取得用(酸素情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307106, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307121, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 user_name取得用(手術・麻酔情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307105, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307120, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 user_name取得用(注射情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307104, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307119, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 user_name取得用(投薬情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307103, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307118, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 disp_user_id取得用(医学管理料情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307110, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307117, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 disp_user_id取得用(導入期加算入力情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307109, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307116, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 disp_user_id取得用(夜間・休日加算情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307108, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307115, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 disp_user_id取得用(処置・治療項目情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307107, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307114, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 disp_user_id取得用(酸素情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307106, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307113, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 disp_user_id取得用(手術・麻酔情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307105, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307112, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 disp_user_id取得用(注射情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307104, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307111, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 disp_user_id取得用(投薬情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307103, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307110, 'with input_code_class as (
-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
-- 2：固定医師コード1より取得
-- 3：固定医師コード2より取得
-- 4：固定担当看護師コード1より取得
-- 5：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_RECE_MNG_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, ord_staff_cd as (
select
	rst_charge_user_info ->> ''user_id_1'' as value
from
	ord_main om
where
	ord_no = @ordNo
limit 1
)
, pat_staff_cd as (
select
	staff_info ->> ''staff_cd'' as value
from
	pat_main,
	lateral json_array_elements(charge_staff_info::json) staff_info
where
	pat_id = @patId
	and staff_info ->> ''is_main'' = ''1''
order by
	(staff_info ->> ''disp_order'')::int
limit 1
)
select coalesce(
  case when input_code_class.value = ''0'' then (select value from pat_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'') then (select value from ord_staff_cd) end,
  ''''
) as staff_cd
from
	input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(医学管理料情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307109, 'with input_code_class as (
-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
-- 2：固定医師コード1より取得
-- 3：固定医師コード2より取得
-- 4：固定担当看護師コード1より取得
-- 5：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_RECE_DIAL_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, ord_staff_cd as (
select
	rst_charge_user_info ->> ''user_id_1'' as value
from
	ord_main om
where
	ord_no = @ordNo
limit 1
)
, pat_staff_cd as (
select
	staff_info ->> ''staff_cd'' as value
from
	pat_main,
	lateral json_array_elements(charge_staff_info::json) staff_info
where
	pat_id = @patId
	and staff_info ->> ''is_main'' = ''1''
order by
	(staff_info ->> ''disp_order'')::int
limit 1
)
select coalesce(
  case when input_code_class.value = ''0'' then (select value from pat_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'') then (select value from ord_staff_cd) end,
  ''''
) as staff_cd
from
	input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(導入期加算入力情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307108, 'with input_code_class as (
-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
-- 2：固定医師コード1より取得
-- 3：固定医師コード2より取得
-- 4：固定担当看護師コード1より取得
-- 5：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_RECE_HOLI_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, ord_staff_cd as (
select
	rst_charge_user_info ->> ''user_id_1'' as value
from
	ord_main om
where
	ord_no = @ordNo
limit 1
)
, pat_staff_cd as (
select
	staff_info ->> ''staff_cd'' as value
from
	pat_main,
	lateral json_array_elements(charge_staff_info::json) staff_info
where
	pat_id = @patId
	and staff_info ->> ''is_main'' = ''1''
order by
	(staff_info ->> ''disp_order'')::int
limit 1
)
select coalesce(
  case when input_code_class.value = ''0'' then (select value from pat_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'') then (select value from ord_staff_cd) end,
  ''''
) as staff_cd
from
	input_code_class
limit 1
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(夜間・休日加算情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307107, 'with input_code_class as (
-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
-- 2：固定医師コード1より取得
-- 3：固定医師コード2より取得
-- 4：固定担当看護師コード1より取得
-- 5：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, ord_staff_cd as (
select
	rst_charge_user_info ->> ''user_id_1'' as value
from
	ord_main om
where
	ord_no = @ordNo
limit 1
)
, pat_staff_cd as (
select
	staff_info ->> ''staff_cd'' as value
from
	pat_main,
	lateral json_array_elements(charge_staff_info::json) staff_info
where
	pat_id = @patId
	and staff_info ->> ''is_main'' = ''1''
order by
	(staff_info ->> ''disp_order'')::int
limit 1
)
select coalesce(
  case when input_code_class.value = ''0'' then (select value from pat_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'') then (select value from ord_staff_cd) end,
  ''''
) as staff_cd
from
	input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(処置・治療項目情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307106, 'with input_code_class as (
	-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
	-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
	-- 2：固定医師コード1より取得
	-- 3：固定医師コード2より取得
	-- 4：固定担当看護師コード1より取得
	-- 5：固定担当看護師コード2より取得
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_OXYGEN_INFO''
		and info->>''key2'' = ''INPUT_CODE_CLASS''
	limit 1
)
, ord_staff_cd as (
	select rst_charge_user_info->>''user_id_1'' as value
	from ord_main om
	where ord_no = @ordNo
	limit 1
)
, pat_staff_cd as (
	select staff_info->>''staff_cd'' as value
	from pat_main,
		lateral json_array_elements(charge_staff_info::json) staff_info
	where pat_id = @patId
		and staff_info->>''is_main'' = ''1''
	order by (staff_info->>''disp_order'')::int
	limit 1
)
select coalesce(
  case when input_code_class.value = ''0'' then (select value from pat_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'') then (select value from ord_staff_cd) end,
  ''''
) as staff_cd
from
	input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(酸素情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307105, 'with input_code_class as (
--0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
--1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．利用者ＩＤを連携設定で変換）
--2：治療情報．実績：愁訴処置者情報→処置者コード（利用者マスタ．表示用利用者ID）
--3：固定医師コード1より取得
--4：固定医師コード2より取得
--5：固定担当看護師コード1より取得
--6：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_OPERATION_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, ord_staff_cd as (
select
	rst_charge_user_info ->> ''user_id_1'' as value
from
	ord_main om
where
	ord_no = @ordNo
limit 1
)
, pat_staff_cd as (
select
	staff_info ->> ''staff_cd'' as value
from
	pat_main,
	lateral json_array_elements(charge_staff_info::json) staff_info
where
	pat_id = @patId
	and staff_info ->> ''is_main'' = ''1''
order by
	(staff_info ->> ''disp_order'')::int
limit 1
)
, treatment_staff_cd as (
-- 最新の発生日時からスタッフを取得(FNWを踏襲)
select
	staff_info ->> ''ctl_no'' as ctl_no,
	staff_info ->> ''row_no'' as row_no,
	staff_info ->> ''occur_date'' as occur_date,
	staff_info ->> ''treat_staff_cd'' as value
from
	ord_main,
	lateral json_array_elements(rst_treat_staff_info::json) staff_info
where
	ord_no = @ordNo
order by occur_date desc, ctl_no desc, row_no desc
limit 1
)
select coalesce(
  case when input_code_class.value = ''0'' then (select value from pat_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'') then (select value from ord_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'', ''2'')then  (select value from treatment_staff_cd) end,
  ''''
) as staff_cd
from
	input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(手術・麻酔情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307104, 'with input_code_class as (
--0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
--1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．利用者ＩＤを連携設定で変換）
--2：治療情報．実績：愁訴処置者情報→処置者コード（利用者マスタ．表示用利用者ID）
--3：固定医師コード1より取得
--4：固定医師コード2より取得
--5：固定担当看護師コード1より取得
--6：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_SHOT_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, ord_staff_cd as (
select
	rst_charge_user_info ->> ''user_id_1'' as value
from
	ord_main om
where
	ord_no = @ordNo
limit 1
)
, pat_staff_cd as (
select
	staff_info ->> ''staff_cd'' as value
from
	pat_main,
	lateral json_array_elements(charge_staff_info::json) staff_info
where
	pat_id = @patId
	and staff_info ->> ''is_main'' = ''1''
order by
	(staff_info ->> ''disp_order'')::int
limit 1
)
, treatment_staff_cd as (
-- 最新の発生日時からスタッフを取得(FNWを踏襲)
select
	staff_info ->> ''ctl_no'' as ctl_no,
	staff_info ->> ''row_no'' as row_no,
	staff_info ->> ''occur_date'' as occur_date,
	staff_info ->> ''treat_staff_cd'' as value
from
	ord_main,
	lateral json_array_elements(rst_treat_staff_info::json) staff_info
where
	ord_no = @ordNo
order by occur_date desc, ctl_no desc, row_no desc
limit 1
)
select coalesce(
  case when input_code_class.value = ''0'' then (select value from pat_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'') then (select value from ord_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'', ''2'')then  (select value from treatment_staff_cd) end,
  ''''
) as staff_cd
from
	input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(注射情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307103, 'with input_code_class as (
	--0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
	--1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．利用者ＩＤを連携設定で変換）
	--2：治療情報．実績：愁訴処置者情報→処置者コード（利用者マスタ．表示用利用者ID）
	--3：固定医師コード1より取得
	--4：固定医師コード2より取得
	--5：固定担当看護師コード1より取得
	--6：固定担当看護師コード2より取得
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
		and info->>''key2'' = ''INPUT_CODE_CLASS''
	limit 1
), ord_staff_cd as (
	select rst_charge_user_info->>''user_id_1'' as value
	from ord_main om
	where ord_no = @ordNo
	limit 1
), pat_staff_cd as (
	select staff_info->>''staff_cd'' as value
	from pat_main,
		lateral json_array_elements(charge_staff_info::json) staff_info
	where pat_id = @patId
		and staff_info->>''is_main'' = ''1''
	order by (staff_info->>''disp_order'')::int
	limit 1
), treatment_staff_cd as (
	-- 最新の発生日時からスタッフを取得(FNWを踏襲)
	select staff_info->>''ctl_no'' as ctl_no,
		staff_info->>''row_no'' as row_no,
		staff_info->>''occur_date'' as occur_date,
		staff_info->>''treat_staff_cd'' as value
	from ord_main,
		lateral json_array_elements(rst_treat_staff_info::json) staff_info
	where ord_no = @ordNo
	order by occur_date desc,
		ctl_no desc,
		row_no desc
	limit 1
)
select coalesce(
  case when input_code_class.value = ''0'' then (select value from pat_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'') then (select value from ord_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'', ''2'')then  (select value from treatment_staff_cd) end, 
  ''''
) as staff_cd
from
	input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者 staff_cd取得用(投薬情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307102, 'with input_code_class as (
-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
-- 2：固定医師コード1より取得
-- 3：固定医師コード2より取得
-- 4：固定担当看護師コード1より取得
-- 5：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_RECE_MNG_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, fixed_doctors as (
select
	(info ->> ''key2'') as key,
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' in (
    ''FIXED_DOCTOR_CODE1'', ''FIXED_DOCTOR_NAME1'',
    ''FIXED_DOCTOR_CODE2'', ''FIXED_DOCTOR_NAME2'',
    ''FIXED_NURSE_CODE1'', ''FIXED_NURSE_NAME1'',
    ''FIXED_NURSE_CODE2'', ''FIXED_NURSE_NAME2''
  )
)
select
	case input_code_class.value::numeric
    	when 0 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 1 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1)
		else null
	end as staff_cd,
		case input_code_class.value::numeric
    	when 0 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 1 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME2'' limit 1)
		else null
	end as staff_name
from
input_code_class
	
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(医学管理料情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307118, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307126, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307101, 'with input_code_class as (
-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
-- 2：固定医師コード1より取得
-- 3：固定医師コード2より取得
-- 4：固定担当看護師コード1より取得
-- 5：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_RECE_DIAL_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, fixed_doctors as (
select
	(info ->> ''key2'') as key,
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' in (
    ''FIXED_DOCTOR_CODE1'', ''FIXED_DOCTOR_NAME1'',
    ''FIXED_DOCTOR_CODE2'', ''FIXED_DOCTOR_NAME2'',
    ''FIXED_NURSE_CODE1'', ''FIXED_NURSE_NAME1'',
    ''FIXED_NURSE_CODE2'', ''FIXED_NURSE_NAME2''
  )
)
select
	case input_code_class.value::numeric
    	when 0 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 1 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1)
		else null
	end as staff_cd,
		case input_code_class.value::numeric
    	when 0 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 1 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME2'' limit 1)
		else null
	end as staff_name
from
input_code_class
	
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(導入期加算入力情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307117, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307125, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307099, 'with input_code_class as (
-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
-- 2：固定医師コード1より取得
-- 3：固定医師コード2より取得
-- 4：固定担当看護師コード1より取得
-- 5：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_RECE_HOLI_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, fixed_doctors as (
select
	(info ->> ''key2'') as key,
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' in (
    ''FIXED_DOCTOR_CODE1'', ''FIXED_DOCTOR_NAME1'',
    ''FIXED_DOCTOR_CODE2'', ''FIXED_DOCTOR_NAME2'',
    ''FIXED_NURSE_CODE1'', ''FIXED_NURSE_NAME1'',
    ''FIXED_NURSE_CODE2'', ''FIXED_NURSE_NAME2''
  )
)
select
	case input_code_class.value::numeric
    	when 0 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 1 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1)
		else null
	end as staff_cd,
		case input_code_class.value::numeric
    	when 0 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 1 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME2'' limit 1)
		else null
	end as staff_name
from
input_code_class
	
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(夜間・休日加算情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307116, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307124, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307098, 'with input_code_class as (
-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
-- 2：固定医師コード1より取得
-- 3：固定医師コード2より取得
-- 4：固定担当看護師コード1より取得
-- 5：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, fixed_doctors as (
select
	(info ->> ''key2'') as key,
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' in (
    ''FIXED_DOCTOR_CODE1'', ''FIXED_DOCTOR_NAME1'',
    ''FIXED_DOCTOR_CODE2'', ''FIXED_DOCTOR_NAME2'',
    ''FIXED_NURSE_CODE1'', ''FIXED_NURSE_NAME1'',
    ''FIXED_NURSE_CODE2'', ''FIXED_NURSE_NAME2''
  )
)
select
	case input_code_class.value::numeric
    	when 0 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 1 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1)
		else null
	end as staff_cd,
		case input_code_class.value::numeric
    	when 0 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 1 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME2'' limit 1)
		else null
	end as staff_name
from
input_code_class
	
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(処置・治療項目情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307115, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307123, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307097, 'with input_code_class as (
-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
-- 2：固定医師コード1より取得
-- 3：固定医師コード2より取得
-- 4：固定担当看護師コード1より取得
-- 5：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_OXYGEN_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, fixed_doctors as (
select
	(info ->> ''key2'') as key,
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' in (
    ''FIXED_DOCTOR_CODE1'', ''FIXED_DOCTOR_NAME1'',
    ''FIXED_DOCTOR_CODE2'', ''FIXED_DOCTOR_NAME2'',
    ''FIXED_NURSE_CODE1'', ''FIXED_NURSE_NAME1'',
    ''FIXED_NURSE_CODE2'', ''FIXED_NURSE_NAME2''
  )
)
select
	case input_code_class.value::numeric
    	when 0 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 1 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1)
		else null
	end as staff_cd,
		case input_code_class.value::numeric
    	when 0 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 1 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME2'' limit 1)
		else null
	end as staff_name
from
input_code_class
	
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(酸素情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307114, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307122, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307096, 'with input_code_class as (
--0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
--1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．利用者ＩＤを連携設定で変換）
--2：治療情報．実績：愁訴処置者情報→処置者コード（利用者マスタ．表示用利用者ID）
--3：固定医師コード1より取得
--4：固定医師コード2より取得
--5：固定担当看護師コード1より取得
--6：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_OPERATION_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, fixed_doctors as (
select
	(info ->> ''key2'') as key,
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' in (
    ''FIXED_DOCTOR_CODE1'', ''FIXED_DOCTOR_NAME1'',
    ''FIXED_DOCTOR_CODE2'', ''FIXED_DOCTOR_NAME2'',
    ''FIXED_NURSE_CODE1'', ''FIXED_NURSE_NAME1'',
    ''FIXED_NURSE_CODE2'', ''FIXED_NURSE_NAME2''
  )
)
select
	case input_code_class.value::numeric
    	when 0 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 1 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 2 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1)
		when 6 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1)
		else null
	end as staff_cd,
		case input_code_class.value::numeric
    	when 0 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 1 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 2 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME2'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME1'' limit 1)
		when 6 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME2'' limit 1)
		else null
	end as staff_name
from
input_code_class', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(手術・麻酔情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307113, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307121, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307095, 'with input_code_class as (
--0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
--1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．利用者ＩＤを連携設定で変換）
--2：治療情報．実績：愁訴処置者情報→処置者コード（利用者マスタ．表示用利用者ID）
--3：固定医師コード1より取得
--4：固定医師コード2より取得
--5：固定担当看護師コード1より取得
--6：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_SHOT_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, fixed_doctors as (
select
	(info ->> ''key2'') as key,
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' in (
    ''FIXED_DOCTOR_CODE1'', ''FIXED_DOCTOR_NAME1'',
    ''FIXED_DOCTOR_CODE2'', ''FIXED_DOCTOR_NAME2'',
    ''FIXED_NURSE_CODE1'', ''FIXED_NURSE_NAME1'',
    ''FIXED_NURSE_CODE2'', ''FIXED_NURSE_NAME2''
  )
)
select
	case input_code_class.value::numeric
    	when 0 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 1 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 2 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1)
		when 6 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1)
		else null
	end as staff_cd,
		case input_code_class.value::numeric
    	when 0 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 1 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 2 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME2'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME1'' limit 1)
		when 6 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME2'' limit 1)
		else null
	end as staff_name
from
input_code_class', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(注射情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307112, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307120, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307094, 'with input_code_class as (
--0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
--1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．利用者ＩＤを連携設定で変換）
--2：治療情報．実績：愁訴処置者情報→処置者コード（利用者マスタ．表示用利用者ID）
--3：固定医師コード1より取得
--4：固定医師コード2より取得
--5：固定担当看護師コード1より取得
--6：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
, fixed_doctors as (
select
	(info ->> ''key2'') as key,
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' in (
    ''FIXED_DOCTOR_CODE1'', ''FIXED_DOCTOR_NAME1'',
    ''FIXED_DOCTOR_CODE2'', ''FIXED_DOCTOR_NAME2'',
    ''FIXED_NURSE_CODE1'', ''FIXED_NURSE_NAME1'',
    ''FIXED_NURSE_CODE2'', ''FIXED_NURSE_NAME2''
  )
)
select
	case input_code_class.value::numeric
    	when 0 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 1 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 2 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1)
		when 6 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1)
		else null
	end as staff_cd,
		case input_code_class.value::numeric
    	when 0 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 1 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 2 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME2'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME1'' limit 1)
		when 6 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME2'' limit 1)
		else null
	end as staff_name
from
input_code_class
	
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '処方薬剤連携 入力者取得用(投薬情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307111, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307119, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307093, 'select
	TO_CHAR(ord.rst_start_date, ''YYYYMMDDHH24MISS'') AS rst_start_date,
	TO_CHAR(ord.up_date, ''YYYYMMDDHH24MISS'') AS up_date
 from
	ord_main ord
 where
	ord.ord_no = @ordNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307092, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当医師 名称取得用(削除オーダ)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307090, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307091, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当医師 表示用利用者ID取得用(削除オーダ)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307090, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307090, 'with doctor_code_class as (
-- 0：外部連携用ジャーナル．操作者ID（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
-- 2：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 3：固定医師コード1より取得
-- 4：固定医師コード2より取得
-- 5：固定担当看護師コード1より取得
-- 6：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_BASIC_INFO''
	and info ->> ''key2'' = ''DOCTOR_CODE_CLASS''
limit 1
),
journal_staff_cd as (
select
	user_id as value
from
	sys_coop_journal
where
	ctl_no = @ctlNo
limit 1
),
ord_staff_cd as (
(
      SELECT
        ord.ord_no as ord_no,
        ord.rst_edition_date as up_date_switch,
        rst_charge_user_info ->> ''user_id_1'' as value
    FROM
        ord_main ord
    WHERE
        ord.ord_no = @ordNo
)
UNION
    (
        SELECT
        ord.ord_no as ord_no,
        ord.del_date as up_date_switch,
        rst_charge_user_info ->> ''user_id_1'' as value
        FROM
            ord_main_restore AS ord
            JOIN sys_coop_journal AS journal ON ord.ord_no = journal.ord_no
        WHERE
            ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
ORDER BY
      up_date_switch DESC NULLS LAST
LIMIT 1
)
,
pat_staff_cd as (
select
	staff_info ->> ''staff_cd'' as value
from
	pat_main,
	lateral json_array_elements(charge_staff_info::json) staff_info
where
	pat_id = @patId
	and staff_info ->> ''is_main'' = ''1''
order by
	(staff_info ->> ''disp_order'')::int
limit 1
)
select coalesce(
    case when doctor_code_class.value =''0'' then (select value::text from journal_staff_cd) end,
    case when doctor_code_class.value in (''0'', ''1'') then (select value::text from ord_staff_cd) end,
    case when doctor_code_class.value in (''0'', ''1'', ''2'')then  (select value::text from pat_staff_cd) end, 
    ''''
) as staff_cd
from
    doctor_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当医師 スタッフコード取得用(削除オーダ)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307089, 'with department_code_class as (
    --診療科コード区分 0：治療情報．実績：診療科コード（診療科マスタの連携コード1）（取得できない場合は固定診療科コード）1：固定診療科名
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) as info
    where ini.facility_cd = @facilityCd
        and ini.is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_BASIC_INFO''
        and info->>''key2'' = ''DEPARTMENT_CODE_CLASS''
    limit 1
), department_name_class as (
    --診療科名設定区分 0:治療情報．実績：診療科コードから診療科マスタの診療科名 1:固定診療科名
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) as info
    where ini.facility_cd = @facilityCd
        and ini.is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRES_XML_BASIC_INFO''
        and info->>''key2'' = ''DEPARTMENT_NAME_CLASS''
    limit 1
), fixed_medical_code as (
    --固定診療科コード:治療情報．実績：診療科コードより診療科が取得できなかった場合にセット
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) as info
    where ini.facility_cd = @facilityCd
        and ini.is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''MCOM_XML_INFO''
        and info->>''key2'' = ''FIXED_MEDICAL_CODE''
    limit 1
), fixed_medical_name as (
    --固定診療科名:治療情報．実績：診療科名より診療科が取得できなかった場合にセット
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) as info
    where ini.facility_cd = @facilityCd
        and ini.is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''MCOM_XML_INFO''
        and info->>''key2'' = ''FIXED_MEDICAL_NAME''
    limit 1
), ord_main_switch AS(
(
      SELECT
        ord.rst_course_cd as rst_course_cd,
        ord.rst_edition_date as up_date_switch
    FROM
        ord_main ord
    WHERE
        ord.ord_no = @ordNo
)
UNION
    (
        SELECT
            ord.rst_course_cd as rst_course_cd,
            ord.del_date as up_date_switch
        FROM
            ord_main_restore AS ord
            JOIN sys_coop_journal AS journal ON ord.ord_no = journal.ord_no
        WHERE
            ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
ORDER BY
      up_date_switch DESC NULLS LAST
LIMIT 1
)

select case
        when dcc.value = ''0'' then case
            when mc.in_hospital_cd_1 is not null
            or mc.in_hospital_cd_1 != '''' then mc.in_hospital_cd_1
            else fmc.value
        end
        when dcc.value = ''1'' then fmc.value
    end as course_cd,
    case
        when dnc.value = ''0'' then 
            case when mc.course_name is not null then mc.course_name
            else fmn.value end
        when dnc.value = ''1'' then fmn.value
    end as course_name
from ord_main_switch ord
    join department_code_class dcc on TRUE
    join department_name_class dnc on TRUE
    join fixed_medical_code fmc on TRUE
    join fixed_medical_name fmn on TRUE
    left join mst_course mc on mc.course_cd = ord.rst_course_cd
limit 1;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '診療科取得用(削除オーダ)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307088, 'with doctor_code_class as (
-- 0：外部連携用ジャーナル．操作者ID（利用者マスタ．表示用利用者ID）
-- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
-- 2：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 3：固定医師コード1より取得
-- 4：固定医師コード2より取得
-- 5：固定担当看護師コード1より取得
-- 6：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_BASIC_INFO''
	and info ->> ''key2'' = ''DOCTOR_CODE_CLASS''
limit 1
)
,
fixed_doctors as (
select
	(info ->> ''key2'') as key,
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' in (
    ''FIXED_DOCTOR_CODE1'', ''FIXED_DOCTOR_NAME1'',
    ''FIXED_DOCTOR_CODE2'', ''FIXED_DOCTOR_NAME2'',
    ''FIXED_NURSE_CODE1'', ''FIXED_NURSE_NAME1'',
    ''FIXED_NURSE_CODE2'', ''FIXED_NURSE_NAME2''
  )
)

select
	case doctor_code_class.value::numeric      
        when 0 then -- 0：外部連携用ジャーナル．操作者ID（利用者マスタ．表示用利用者ID）
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 1 then -- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 2 then -- 2：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1) -- 3：固定医師コード1より取得
		when 4 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1) -- 4：固定医師コード2より取得
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1) -- 5：固定担当看護師コード1より取得
		when 6 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1) -- 6：固定担当看護師コード2より取得
		else null
	end as doctor_code,
		case doctor_code_class.value::numeric
        when 0 then -- 0：外部連携用ジャーナル．操作者ID（利用者マスタ．表示用利用者ID）
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 1 then -- 1：治療情報．実績：担当者情報→担当者コード（利用者マスタ．表示用利用者ID）
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 2 then -- 2：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1) -- 3：固定医師コード1より取得
		when 4 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME2'' limit 1) -- 4：固定医師コード2より取得
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME1'' limit 1) -- 5：固定担当看護師コード1より取得
		when 6 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME2'' limit 1) -- 6：固定担当看護師コード2より取得
		else null
	end as doctor_name
from
doctor_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当医取得用(削除オーダ)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307091, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307092, "field_name": "user_name", "replace_var": "@userName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307087, 'WITH ord_main_switch AS(
(
      SELECT
        ord.rst_in_out_class as rst_in_out_class,
        ord.rst_edition_date as up_date_switch
    FROM
        ord_main ord
    WHERE
        ord.ord_no = @ordNo
)
UNION
    (
        SELECT
        ord.rst_in_out_class as rst_in_out_class,
        ord.del_date as up_date_switch
        FROM
            ord_main_restore AS ord
            JOIN sys_coop_journal AS journal ON ord.ord_no = journal.ord_no
        WHERE
            ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
ORDER BY
      up_date_switch DESC NULLS LAST
LIMIT 1
)
,
input_code_class AS (
    SELECT
        COALESCE(
            NULLIF(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) AS info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' = ''MCOM_COMMON_INFO''
        AND info ->> ''key2'' = ''INOUT_USE_SET''
    LIMIT 1
)

SELECT
    CASE
        WHEN (select value from input_code_class) = ''0'' THEN NULL
        WHEN ord.rst_in_out_class = 0 THEN ''外来''
        WHEN ord.rst_in_out_class = 1 THEN ''入院''
    END AS in_patient_flag
FROM
    ord_main_switch AS ord
limit 1;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '受信区分取得用(削除オーダ)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307086, 'WITH all_values AS (
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
        info ->> ''key1'' AS key1,
        info ->> ''key2'' AS key2
    FROM mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' IN (
            ''PRES_XML_BASIC_INFO'',
            ''PRESCRIPTION_INFO'',
            ''CATEGORY_NAME'',
            ''PRESCRIPTION_DETAILS'',
            ''PRESCRIPTION_XML_TREATMENT_INFO'',
            ''PRESCRIPTION_XML_OXYGEN_INFO'',
            ''PRESCRIPTION_XML_RECE_HOLI_INFO'',
            ''PRESCRIPTION_XML_RECE_DIAL_INFO''
        )
)
SELECT
    (SELECT value FROM all_values WHERE key1 = ''PRES_XML_BASIC_INFO'' AND key2 = ''S_VERSION'') AS s_version,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_INFO'' AND key2 = ''MODEL_TYPE'') AS device_identifier,
    (SELECT value FROM all_values WHERE key1 = ''PRES_XML_BASIC_INFO'' AND key2 = ''VISIT_CATEGORY'') AS visit_category,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''MEDICINE'') AS category_name_medicine,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''INJECTION'') AS category_name_injection,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''TREATMENT'') AS category_name_treatment,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''HOLIDAY'') AS category_name_holiday,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''DIALYSIS'') AS category_name_dialysis,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''CONSULTATION'') AS category_name_consultation,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''SURGERY'') AS category_name_surgery,
    (SELECT value FROM all_values WHERE key1 = ''CATEGORY_NAME'' AND key2 = ''EXAMINATION'') AS category_name_examination,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''TREATMENT'') AS prescription_details_treatment,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''OXYGEN'') AS prescription_details_oxygen,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''HOLIDAY'') AS prescription_details_holiday,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''DIALYSIS'') AS prescription_details_dialysis,
    (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_DETAILS'' AND key2 = ''CONSULTATION'') AS prescription_details_consultation,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_TREATMENT_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_treatment,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_OXYGEN_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_oxygen,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_RECE_HOLI_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_rece_holi,
    LPAD(@ordNo || (SELECT value FROM all_values WHERE key1 = ''PRESCRIPTION_XML_RECE_DIAL_INFO'' AND key2 = ''ORDER_UNITS_ID''), 10, ''0'') AS order_units_id_rece_dial
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307085, 'with ord_main_switch as(
    (
        select ord.rst_start_date,
            ord.rst_edition_date as up_date_switch
        from ord_main ord
        where ord.ord_no = @ordNo
    )
    union
    (
        select ord.rst_start_date,
            ord.del_date as up_date_switch
        from ord_main_restore as ord
            join sys_coop_journal as journal on ord.ord_no = journal.ord_no
        where ord.ord_no = @ordNo
            and journal.ctl_no = @ctlNo
            and ord.ord_no = journal.ord_no
            and journal.reg_date >= ord.del_date
        order by del_date desc
        limit 1
    )
    order by up_date_switch desc nulls last
    limit 1
)
, 
model_type as (
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) as info
    where ini.facility_cd = @facilityCd
        and ini.is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''MODEL_TYPE''
)


select 
    to_char(ord.rst_start_date, ''YYYYMMDDHH24MISS'') as rst_start_date,
    ( select value from model_type ) as model_type
from ord_main_switch as ord
limit 1;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'パナ処方ファイル名取得(削除オーダ)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307084, 'select
  @modelType ||
  ''_'' ||
  case when ltrim(ppm.hosp_pat_id,''0'')='''' then ''0''
  else ltrim(ppm.hosp_pat_id,''0'') end ||
  ''_'' ||
  @rstStartDate ||
	''_'' ||
  to_char(current_timestamp, ''YYYYMMDDHH24MISS_'') ||
  ''0001'' ||
  ''.xml'' as filename
from
  ntss.pat_personal_main as ppm
where
  pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'パナ処方ファイル名取得(削除オーダ)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307085, "field_name": "rst_start_date", "replace_var": "@rstStartDate"}, {"sql_cd": -307085, "field_name": "model_type", "replace_var": "@modelType"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307083, 'with use_in_hospital_cd_no as (
select
	coalesce(
      nullif(info->>''value'', ''''),
      info->>''default_v''
    ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info->>''key0'', '''') = @key0
	and info->>''key1'' = ''MST''
	and info->>''key2'' = ''EXAM_ITEM_COST''
limit 1
)
, 
exam_code_before as (
select
	coalesce(
      nullif(info->>''value'', ''''),
      info->>''default_v''
    ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_EXAM_INFO''
		and info->>''key2'' = ''EXAM_CODE_BEFORE''
	limit 1
)
,
exam_code_after as (
select
	coalesce(
      nullif(info->>''value'', ''''),
      info->>''default_v''
    ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_EXAM_INFO''
		and info->>''key2'' = ''EXAM_CODE_AFTER''
	limit 1
)
,
exam_code_other as (
select
	coalesce(
      nullif(info->>''value'', ''''),
      info->>''default_v''
    ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_EXAM_INFO''
		and info->>''key2'' = ''EXAM_CODE_OTHER''
	limit 1
),
exam_timing as (
select
	save_2 ->> ''exam_timing'' as value
from
	pat_coop_detail pcd
where
	coop_save_no = @coopSaveNo
limit 1
)
, 
exam_data_with_exam_timing as (
select
	case
		when exam_timing.value = ''1'' then exam_code_before.value
		when exam_timing.value = ''2'' then exam_code_after.value
		else exam_code_other.value
	end as code,
	case
		when exam_timing.value = ''1'' then ''透析前''
		when exam_timing.value = ''2'' then ''透析後''
		else ''その他''
	end as name,
	''1'' as count,
	null as unit,
	null as cotoff,
	1 as seq_no
from
	exam_timing,
	exam_code_before,
	exam_code_after,
	exam_code_other
union all
select
	case
		when use_in_hospital_cd_no.value = ''1'' then t->>''in_hospital_cd1''
		when use_in_hospital_cd_no.value = ''2'' then t->>''in_hospital_cd2''
		when use_in_hospital_cd_no.value = ''3'' then t->>''in_hospital_cd3''
	end as code,
	t->>''exam_name'' as name,
	''1'' as count,
	null as unit,
	null as cutoff,
	row_number() over(
		order by case
		when use_in_hospital_cd_no.value = ''1'' then t->>''in_hospital_cd1''
		when use_in_hospital_cd_no.value = ''2'' then t->>''in_hospital_cd2''
		when use_in_hospital_cd_no.value = ''3'' then t->>''in_hospital_cd3''
	end 
	) + 1 as seq_no
from
	pat_coop_detail pcd,
	use_in_hospital_cd_no
join lateral jsonb_array_elements(save_2->''exam_items'') as t on
	true
where
	coop_save_no = @coopSaveNo
	and case
		when use_in_hospital_cd_no.value = ''1'' then t->>''in_hospital_cd1''
		when use_in_hospital_cd_no.value = ''2'' then t->>''in_hospital_cd2''
		when use_in_hospital_cd_no.value = ''3'' then t->>''in_hospital_cd3''
	end is not null
)

select * from exam_data_with_exam_timing order by seq_no
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '検査項目情報(Orderタグ)取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307082, 'select
	json_agg(row_to_json(t))::text as user_names
from
	(
select
	elem->>''coop_save_no'' as coop_save_no,
	personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name) as user_name
from
	jsonb_array_elements(@staffCds::jsonb) as elem
left join mst_personal_user mpu on mpu.user_Id = (elem->>''staff_cd'')::numeric) t;', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '患者連携情報．連携情報カラム２→依頼医情報取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307080, "field_name": "staff_cds", "replace_var": "@staffCds"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307081, 'select
	json_agg(row_to_json(t))::text as disp_user_ids
from
	(
	select
		elem->>''coop_save_no'' as coop_save_no,
		mua.disp_user_id as disp_user_id
	from
		jsonb_array_elements(@staffCds::jsonb) as elem
	left join mst_user_authentication mua on
		mua.user_Id = (elem->>''staff_cd'')::numeric) t', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '患者連携情報．連携情報カラム２→依頼医情報取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307080, "field_name": "staff_cds", "replace_var": "@staffCds"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307080, 'SELECT 
  json_agg(row_to_json(t))::text AS staff_cds
FROM (
  SELECT
    coop_save_no,
    save_2 ->> ''staff_cd'' AS staff_cd
  FROM
    pat_coop_detail
  WHERE
    pat_id = @patId
) t', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '患者連携情報．連携情報カラム２→依頼医情報取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307079, 'SELECT
    COALESCE(
        (
            SELECT 
                personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
            FROM 
                mst_personal_user
            WHERE 
                user_id::text = @staffCd
            LIMIT 1
        ),
        ''''
    ) AS user_name;
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当スタッフ情報取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307078, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307078, 'with input_code_class as (
	--0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
	--1：患者連携情報．連携情報カラム２→依頼医名コード（利用者マスタ．表示用利用者ID）
	--2：固定医師コード1より取得
	--3：固定医師コード2より取得
	--4：固定担当看護師コード1より取得
	--5：固定担当看護師コード2より取得
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_EXAM_INFO''
		and info->>''key2'' = ''INPUT_CODE_CLASS''
	limit 1
),
ord_staff_cd as (
  SELECT
    save_2 ->> ''staff_cd'' AS value
  FROM
    pat_coop_detail
  WHERE
    pat_id = @patId
    and  save_2 ->> ''ord_no'' = @ordNo
limit 1
),
pat_staff_cd as (
	select staff_info->>''staff_cd'' as value
	from pat_main,
		lateral json_array_elements(charge_staff_info::json) staff_info
	where pat_id = @patId
		and staff_info->>''is_main'' = ''1''
	order by (staff_info->>''disp_order'')::int
	limit 1
)
select coalesce(
  case when input_code_class.value = ''0'' then (select value from pat_staff_cd) end,
  case when input_code_class.value in (''0'', ''1'') then (select value from ord_staff_cd) end,
  ''''
) as staff_cd
from
	input_code_class
limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当スタッフ情報取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307077, 'SELECT
    COALESCE(
        (SELECT disp_user_id
         FROM mst_user_authentication
         WHERE user_id::text = @staffCd
         LIMIT 1),
        ''''
    ) AS disp_user_id;', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '担当スタッフ情報取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307078, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307076, 'with dialysis_output_setting as (
-- 透析困難コメント・透析時間の出力設定
select
	coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info->>''key0'', '''') = @key0
	and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
	and info->>''key2'' = ''DIFFCOMMENT_DIALTIME_FLG''
limit 1
),
main_dial_diff_name as (
select
	dialysis_difficulty_name as name
from
	mst_dialysis_difficulty mdd
where
	dialysis_difficulty_cd::text = @dialDiffCd::text
limit 1
) 

select
	case
		when dos.value = ''0'' then null
		when dos.value = ''1'' then 
      coalesce(
        case 
          when (select name from main_dial_diff_name) is not null 
          then ''理由（'' || (select name from main_dial_diff_name) || ''） '' 
          else '''' 
        end, ''''
      )
	end
  || translate( FLOOR(extract(EPOCH from (rst_end_date - rst_start_date)) / 3600)::text, ''0123456789'', ''０１２３４５６７８９'' ) || ''Ｈ''
  || translate( FLOOR(mod(extract(EPOCH from (rst_end_date - rst_start_date)), 3600) / 60)::text, ''0123456789'', ''０１２３４５６７８９'' ) || ''Ｍ ''
  || translate( TO_CHAR(rst_start_date, ''HH24:MI''), ''0123456789:'', ''０１２３４５６７８９：'' )
  || ''～''
  || translate( TO_CHAR(rst_end_date, ''HH24:MI''), ''0123456789:'', ''０１２３４５６７８９：'' ) as order_units_memo
from
	ord_main
cross join dialysis_output_setting dos
where
	ord_no = @ordNo;
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307075, "field_name": "dial_diff_cd", "replace_var": "@dialDiffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307075, 'select
	-- 受け取り側でnullだとエラーを起こすため,結果がnullの場合は空値を返す
    COALESCE(pat_dial_diff_com_info ->> ''dial_diff_cd'', '''') AS dial_diff_cd
FROM
    pat_personal_main
    LEFT JOIN LATERAL json_array_elements(pat_personal_main.dial_diff_com_info::json) AS pat_dial_diff_com_info
        ON pat_dial_diff_com_info ->> ''is_dial_diff'' = ''1''
        AND pat_dial_diff_com_info ->> ''is_main'' = ''1''
WHERE
    pat_personal_main.pat_id = @patId
LIMIT 1
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307074, 'WITH application_name as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' = ''TREATMENT''
),
default_medicine_group as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''DEFAULT_MEDICINE_GROUP''
),
-- 
-- 投与情報
-- 
medicine_order_units_num as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
medicine_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from medicine_order_units_num,
        generate_series(1, medicine_order_units_num.value) as i
),
medicine_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_MEDICINE_INFO
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
),
medicine_classes as (
    -- 投与薬剤として出力される薬剤分類名
    select idx.suffix,
        msi.value
    from medicine_setting_info as msi
        join medicine_unit_indices as idx on msi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 注射情報
-- 
injection_order_units_num as (
    -- 出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
injection_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from injection_order_units_num,
        generate_series(1, injection_order_units_num.value) as i
),
injection_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_INJECTION_INFOを取得
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
),
injection_procedure_names as (
    -- 注射情報として出力する手技名を取得
    select idx.suffix,
        isi.value
    from injection_setting_info as isi
        join injection_unit_indices as idx on isi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 手術・麻酔
-- 
surgery_medicine_class_name as (
    -- 手術・麻酔として出力する薬剤分類名を取得
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' = ''SURGERY''
),
-- 
-- 処置
-- 
treatment_num as (
    -- 処置として出力する対象の薬剤分類の数 (TREATMENT_NUM)
    select unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' = ''TREATMENT_NUM''
    limit 1
), treatment_number_series as (
    -- TREATMENT_NUMの数を基にTREATMENT_NAME_{0:D2} を生成
    select LPAD(n::text, 2, ''0'') as padded_num
    from generate_series(
            1,
            (
                select value
                from treatment_num
            )::numeric
        ) as t(n)
),
treatment_name_keys as (
    -- TREATMENT_NAME_{0:D2} の key を生成
    select ''TREATMENT_NAME_'' || padded_num as name_key
    from treatment_number_series
),
treatment_key_value_pairs as (
    -- TREATMENT_NAME_{0:D2} の key/value の組み合わせを出力
    select info->>''key2'' as key,
        unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' like ''TREATMENT_NAME_%''
),
treatment_names as (
    -- TREATMENT_NAME_{0:D2} の名前を取得
    select treatment_name_keys.name_key,
        kv.value as treatment_name
    from treatment_name_keys
        join treatment_key_value_pairs kv on kv.key = treatment_name_keys.name_key
),
class_names as (
    select treatment_name as value
    from treatment_names
    union
    select value
    from surgery_medicine_class_name
    union
    select value
    from medicine_classes
),
unreferenced_medicines as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
),
treatment_in_hospital_cd_alpha AS (
	-- 使用する治療方法の連携コードアルファベット
	SELECT coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) AS alpha_value
	FROM mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
	WHERE facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info->>''key0'', '''') = @key0
		AND info->>''key1'' = ''MST''
		AND info->>''key2'' = ''TREATMENT_IN_HOSPITAL_CD_ALPHA''
),
treatment_in_hospital_cd_no AS (
	-- 使用する治療方法の連携コード番号
	SELECT coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) AS no_value
	FROM mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
	WHERE facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info->>''key0'', '''') = @key0
		AND info->>''key1'' = ''MST''
		AND info->>''key2'' = ''TREATMENT_IN_HOSPITAL_CD_NO''
),
addition_in_hospital_cd_no AS (
	-- 使用する加算/管理科項目の連携コード番号
	SELECT coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) AS no_value
	FROM mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
	WHERE facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info->>''key0'', '''') = @key0
		AND info->>''key1'' = ''MST''
		AND info->>''key2'' = ''ADDITION_IN_HOSPITAL_CD_NO''
),
pat_dial_diff_data AS (
	-- 患者の透析困難情報
	SELECT obj->>''is_main'' AS is_main,
		obj->>''dial_diff_cd'' AS dial_diff_cd
	FROM (
			SELECT jsonb_array_elements(replace(@dialDiffCds, '''''''', ''"'')::jsonb) AS obj
		) t
),
mst_selector_dial_diff_data as (
	-- マスタ並び順から取得した透析困難
	select row_number() over () as sort_no,
		item->>''code'' as code,
		item->>''name'' as name,
		item->>''isDel'' as is_del,
		item->>''isDisp'' as is_disp
	from (
			select jsonb_array_elements(order_settings->''items'') as item
			from mst_selector
			where facility_cd = @facilityCd
				and master_physical_name = ''mst_dialysis_difficulty''
		) t
),
dial_diff_in_hospital_cd_no as (
	-- 使用する透析困難の連携コード番号
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as no_value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''MST''
		and info->>''key2'' = ''DIALYSIS_DIFFICULTY_HOSPITAL_CD_NO''
),
dialysis_output_setting as (
	-- 透析困難コメント・透析時間の出力設定
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as no_value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DIFFCOMMENT_DIALTIME_FLG''
),
addition_info as(
	-- オーダから取得した加算・管理科情報
	select ord_addition_info->>''cd'' as code
	from ord_main
		cross join lateral json_array_elements(ord_main.addition_info::json) ord_addition_info
	where ord_main.ord_no = @ordNo
),
addition_key_value as(
	-- 加算項目キー
	select unnest(
			string_to_array(
				coalesce(
					nullif(info->>''value'', ''''),
					info->>''default_v''
				),
				'',''
			)
		) as VALUE
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_RECE_MNG_INFO''
		and info->>''key2'' = ''RECE_MNG_GENERAL_KEY''
),
add_treat_item_num as (
	-- 追加する治療項目数を取得
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''ADD_TREAT_ITEM_NUM''
),
key_nums as (
	-- 追加する治療項目数の数値"{0:D2}"を生成
	select LPAD(n::text, 2, ''0'') as padded_num
	from generate_series(
			1,
			(
				select value::integer
				from ADD_TREAT_ITEM_NUM
			)
		) as t(n)
),
target_keys as (
	-- 追加する治療項目のコードと名称を連携設定から取得するためのkeyを生成
	select ''ADD_TREAT_ITEM_CODE_'' || padded_num as code_key,
		''ADD_TREAT_ITEM_NAME_'' || padded_num as name_key
	from key_nums
),
flat_kv as (
	--	ADD_TREAT_ITEM_CODEとADD_TREAT_ITEM_NAMEのkey/valueの組み合わせを出力
	select info->>''key2'' as key,
		unnest(
			string_to_array(
				coalesce(
					nullif(info->>''value'', ''''),
					info->>''default_v''
				),
				'',''
			)
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
),
code_values as (
	-- flat_kvからADD_TREAT_ITEM_CODEの値のみ抽出
	select key_nums.padded_num,
		kv.value as code
	from key_nums
		join target_keys on target_keys.code_key = ''ADD_TREAT_ITEM_CODE_'' || key_nums.padded_num
		join flat_kv kv on kv.key = target_keys.code_key
),
name_values as (
	-- flat_kvからADD_TREAT_ITEM_NAMEの値のみ抽出
	select key_nums.padded_num,
		kv.value as name
	from key_nums
		join target_keys on target_keys.name_key = ''ADD_TREAT_ITEM_NAME_'' || key_nums.padded_num
		join flat_kv kv on kv.key = target_keys.name_key
),
dialyzer_unit as (
	-- ダイアライザの単位
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as unit
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DIALYZER_UNIT''
),
dialyzer_in_hospital_cd_no as (
	--　使用するダイアライザの連携コード番号
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''MST''
		and info->>''key2'' = ''DIALYZER_IN_HOSPITAL_CD_NO''
),
primary_membrane_info as (
	--１次膜の取得
	select rst_cond_info->''7''->>''value'' as equipment_cd
	from ord_main
	where ord_no = @ordNo
		and is_del = ''0''
),
secondary_membrane_info as (
	--2次膜の取得
	select rst_cond_info->''8''->>''value'' as equipment_cd
	from ord_main
	where ord_no = @ordNo
		and is_del = ''0''
),
equipment_in_hospital_cd_no as (
	--医療材料マスタの参照する連携コード
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''MST''
		and info->>''key2'' = ''EQUIPMENT_IN_HOSPITAL_CD_NO''
),
column_count as (
	-- 吸着カラムの数量
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''COLUMN_COUNT''
	limit 1
), column_info as (
	--吸着カラムの取得
	select null as idx,
		rst_cond_info->''6''->>''value'' as equipment_cd,
		cc.value as count
	from ord_main
		cross join column_count cc
	where ord_no = @ordNo
	and rst_cond_info->''6''->>''value'' != ''null''
),
equipment_info as (
	--穿刺針(SN)、穿刺針(SN以外)を除外した医療材料の取得
	select t.idx,
		t.equip_info->>''cd'' as equipment_cd,
		t.equip_info->>''amount'' as count
	from ord_main
		cross join lateral json_array_elements(ord_main.rst_equip_info::json) with ordinality as t(equip_info, idx)
	where ord_no = @ordNo
		and is_del = ''0''
		and equip_info->>''class_type'' not in (''2'', ''3'')
),
medi_hospital_cd as (
	-- 使用する薬剤の連携コード番号
	select unnest(
			string_to_array(
				coalesce(
					nullif(info->>''value'', ''''),
					info->>''default_v''
				),
				'',''
			)
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''MST''
		and info->>''key2'' = ''MEDICINE_IN_HOSPITAL_CD_NO''
),
dialysate_info as (
	-- 透析液を取得
	select ord_main.rst_cond_info,
		mst_medicine.medicine_cd,
		mst_medicine.medicine_name,
		mst_medicine.unit_second,
		mst_medicine.in_hospital_cd_1,
		mst_medicine.in_hospital_cd_2,
		mst_medicine.in_hospital_cd_3,
		mst_medicine.in_hospital_cd_4,
		mst_treatment.device_mode
	from ord_main
		left join mst_medicine on mst_medicine.medicine_cd::text = ord_main.rst_cond_info->''15''->>''value''
		left join mst_treatment on ord_main.rst_treatment_cd = mst_treatment.treatment_cd
	where ord_main.ord_no = @ordNo
		and ord_main.is_del = ''0''
		and ord_main.rst_cond_info->''15''->>''medicine_type'' = ''1''
),
infusion_info as (
	-- 補液情報の抽出
	select mst_medicine.medicine_cd,
		mst_medicine.medicine_name,
		mst_medicine.unit_second,
		mst_medicine.in_hospital_cd_1,
		mst_medicine.in_hospital_cd_2,
		mst_medicine.in_hospital_cd_3,
		mst_medicine.in_hospital_cd_4,
		ord_main.rst_cond_info->''22''->>''value'' as raw_count_value
	from ord_main
		left join mst_medicine on mst_medicine.medicine_cd::text = ord_main.rst_cond_info->''19''->>''value''
		left join mst_treatment on ord_main.rst_treatment_cd = mst_treatment.treatment_cd
	where ord_main.ord_no = @ordNo
		and ord_main.is_del = ''0''
		and ord_main.rst_cond_info->''19''->>''medicine_type'' = ''1'' 
		and mst_treatment.device_mode not in (4, 7, 8, 10) -- 治療方法（装置モード）が（OHF、OHDF、HD+補液、プログラム補液）の場合、補液は透析液に合算するため出力しない
),
anticoagulant_info as (
	-- 抗凝固剤を抽出
	select ord_main.rst_cond_info->''25''->>''value'' as medicine_cd,
		ord_main.rst_cond_info->''25''->>''medicine_type'' as medicine_type,
		ord_main.rst_cond_info->''26''->>''value'' as one_shot,
		ord_main.rst_cond_info->''28''->>''value'' as total_dose
	from ord_main
	where ord_main.ord_no = @ordNo
),
direct_anticoagulant as (
	-- 通常薬剤の抗凝固剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		left(med.medicine_name, 80) as name,
		ai.one_shot::numeric + ai.total_dose::numeric as count,
		med.unit as unit,
		mmc.class_type as class_type
	from anticoagulant_info ai
		left join mst_medicine med on ai.medicine_cd = med.medicine_cd::TEXT
		left join mst_medicine_class mmc on med.class_cd = mmc.class_cd
	where ai.medicine_type = ''1''
),
mixed_anticoagulant as (
	-- 調製薬剤の抗凝固剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		med.medicine_name as name,
		case
			when mi.value->>''amount'' = ''0'' or mi.value->>''amount'' = ''null'' then null
			when mi.value->>''solvent'' = ''1'' then (mi.value->>''amount'')::numeric
			when mi.value->>''solvent'' = ''0'' then ((ai.one_shot)::numeric + (ai.total_dose)::numeric ) * (mi.value->>''amount'')::numeric
			else null
		end as count,
		med.unit as unit,
		mmc.class_type as class_type
	from mst_medicine_mix mmm
		inner join anticoagulant_info ai on ai.medicine_cd::integer = mmm.medicine_mix_cd
		cross join lateral jsonb_array_elements(mmm.mix_info) as mi(value)
		left join mst_medicine med on med.medicine_cd = (mi.value->>''cd'')::integer
		left join mst_medicine_class mmc on med.class_cd = mmc.class_cd
	where ai.medicine_type = ''2''
),
medicine_add_flag as (
	-- 薬剤合算フラグ
	select unnest(
			string_to_array(
				coalesce(
					nullif(info->>''value'', ''''),
					info->>''default_v''
				),
				'',''
			)
		) as value
	from mst_coop_ini as ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and info->>''key0'' = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
		and info->>''key2'' = ''DISTINCT_MEDICINE_FLAG''
	limit 1
), ord_medi_info as (
	-- 投与薬剤情報
	select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
		ord_medi_info->>''cd'' as cd,
		ord_medi_info->>''name'' as name,
		ord_medi_info->>''amount'' as amount,
		ord_medi_info->>''unit'' as unit,
		mst_medicine.class_cd as class_cd,
		ord_medi_info->>''class_name'' as class_name,
		ord_medi_info->>''medicine_type'' as medicine_type,
		ord_medi_info->>''timing_cd'' as timing_cd,
		ord_medi_info->>''procedure_cd'' as procedure_cd,
		ord_medi_info->>''date_interval'' as date_interval
	from ord_main
		cross join lateral json_array_elements(ord_main.rst_medi_info::json) ord_medi_info
		inner join mst_medicine on (ord_medi_info->>''cd'')::numeric = mst_medicine.medicine_cd
	where ord_no = @ordNo
		and ord_medi_info->>''effect_flg'' = ''1''
	order by registration_order
),
ord_treat_info as (
	-- 愁訴処置情報
	select LPAD(ord_treat_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treat_info->>''row_no'', 10, ''0'') as registration_order,
		ord_treat_info->>''treat_medicine_cd'' as cd,
		ord_treat_info->>''treat_medicine_name'' as name,
		ord_treat_info->>''amount'' as amount,
		ord_treat_info->>''unit'' as unit,
		mst_medicine.class_cd as class_cd,
		mst_medicine_class.class_name as class_name,
		ord_treat_info->>''medicine_type'' as medicine_type,
		ord_treat_info->>''procedure_cd'' as procedure_cd
	from ord_main
		cross join lateral json_array_elements(ord_main.rst_treatment_info::json) ord_treat_info
		inner join mst_medicine on (ord_treat_info->>''treat_medicine_cd'')::numeric = mst_medicine.medicine_cd
        inner join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
	where ord_no = @ordNo
        and (ord_treat_info->>''medicine_type'')::numeric = 1
	union all
	select LPAD(ord_treat_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treat_info->>''row_no'', 10, ''0'') as registration_order,
		ord_treat_info->>''treat_medicine_cd'' as cd,
		ord_treat_info->>''treat_medicine_name'' as name,
		ord_treat_info->>''amount'' as amount,
		ord_treat_info->>''unit'' as unit,
		mst_medicine_mix.class_cd as class_cd,
		mst_medicine_class.class_name as class_name,
		ord_treat_info->>''medicine_type'' as medicine_type,
		ord_treat_info->>''procedure_cd'' as procedure_cd
	from ord_main
		cross join lateral json_array_elements(ord_main.rst_treatment_info::json) ord_treat_info
		left join mst_medicine_mix on (ord_treat_info->>''treat_medicine_cd'')::numeric = mst_medicine_mix.medicine_mix_cd
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
	where ord_no = @ordNo
        and (ord_treat_info->>''medicine_type'')::numeric = 2
),
facility_medicine_order as (
	-- 施設設定マスタ(No.107)
	select row_number () over () as setting_order -- 適用順 
,
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
),
medi_order as (
	-- 薬剤マスタの並び順
	select index_no::int as medi_code_order,
		TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_code,
		order_cd->>''name'' as name
	from mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
	where facility_cd = @facilityCd
		and master_physical_name = ''mst_medicine''
),
medi_class_order as (
	-- 薬剤分類マスタの並び順
	select index_no::int as medi_class_code_order,
		TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_class_code,
		order_cd->>''name'' as class_name
	from mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
	where facility_cd = @facilityCd
		and master_physical_name = ''mst_medicine_class''
),
timing_order as (
	select index_no::int as timing_code_order,
		TO_NUMBER(order_cd->>''code'', ''999999999999'') as timing_code
	from mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
	where facility_cd = @facilityCd
		and master_physical_name = ''mst_medicate_timing''
),
procedure_order as (
	select index_no::int as procedure_code_order,
		TO_NUMBER(order_cd->>''code'', ''999999999999'') as procedure_code
	from mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
	where facility_cd = @facilityCd
		and master_physical_name = ''mst_procedure''
),
mst_medi as (
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
),
ord_treat_medi_info as (
	-- 投与薬剤情報 通常薬剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		left(med.medicine_name, 80) as name,
		omi.amount::numeric as count,
		med.unit as unit,
		mst_medi.class_cd as class_cd,
		mst_medi.class_name as class_name,
		omi.registration_order as registration_order,
		mst_medi.medi_code_order as medi_code_order,
		mst_medi.medi_class_code_order as class_code_order,
		omi.medicine_type as medicine_type_order,
		t.timing_code_order::text as timing_code_order,
		p.procedure_code_order::text as procedure_code_order,
		omi.date_interval as date_interval
	from ord_medi_info omi
		left join mst_medicine med on omi.cd = med.medicine_cd::TEXT
		left join mst_medi on med.class_cd = mst_medi.class_cd
		and med.medicine_cd = mst_medi.medicine_cd
		left join timing_order t on t.timing_code = omi.timing_cd::numeric
		left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
	where omi.medicine_type = ''1''
	union all
	-- 投与薬剤情報 調製薬剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		med.medicine_name as name,
		case
			when mi.value->>''amount'' = ''0'' or mi.value->>''amount'' = ''null'' then null
			when mi.value->>''solvent'' = ''1'' then (mi.value->>''amount'')::numeric
			when mi.value->>''solvent'' = ''0'' then (omi.amount)::numeric * (mi.value->>''amount'')::numeric
			else null
		end as count,
		med.unit as unit,
		mst_medi.class_cd as class_cd,
		omi.class_name as class_name,
		omi.registration_order as registration_order,
		mst_medi.medi_code_order as medi_code_order,
		mst_medi.medi_class_code_order as class_code_order,
		omi.medicine_type as medicine_type_order,
		t.timing_code_order::text as timing_code_order,
		p.procedure_code_order::text as procedure_code_order,
		omi.date_interval as date_interval
	from mst_medicine_mix mmm
		inner join ord_medi_info omi on omi.cd::integer = mmm.medicine_mix_cd
		cross join lateral jsonb_array_elements(mmm.mix_info) as mi(value)
		left join mst_medicine med on med.medicine_cd = (mi.value->>''cd'')::integer
		left join mst_medi on med.class_cd = mst_medi.class_cd
		and med.medicine_cd = mst_medi.medicine_cd
		left join timing_order t on t.timing_code = omi.timing_cd::numeric
		left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
	where omi.medicine_type = ''2''
	union all
	-- 愁訴処置情報 通常薬剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		left(med.medicine_name, 80) as name,
		oti.amount::numeric as count,
		med.unit as unit,
		mst_medi.class_cd as class_cd,
		mst_medi.class_name as class_name,
		oti.registration_order as registration_order,
		mst_medi.medi_code_order as medi_code_order,
		mst_medi.medi_class_code_order as class_code_order,
		oti.medicine_type as medicine_type_order,
		null as timing_code_order,
		p.procedure_code_order::text as procedure_code_order,
		null as date_interval
	from ord_treat_info oti
		left join mst_medicine med on oti.cd = med.medicine_cd::TEXT
		left join mst_medi on med.class_cd = mst_medi.class_cd
		and med.medicine_cd = mst_medi.medicine_cd
		left join procedure_order p on p.procedure_code = oti.procedure_cd::numeric
	where oti.medicine_type = ''1''
	union all
	-- 愁訴処置情報 調製薬剤
	select case
			(
				select value
				from medi_hospital_cd
			)
			when ''1'' then left(med.in_hospital_cd_1, 20)
			when ''2'' then left(med.in_hospital_cd_2, 20)
			when ''3'' then left(med.in_hospital_cd_3, 20)
		end as code,
		med.medicine_name as name,
		case
			when mi.value->>''amount'' = ''0'' or mi.value->>''amount'' = ''null'' then null
			when mi.value->>''solvent'' = ''1'' then (mi.value->>''amount'')::numeric
			when mi.value->>''solvent'' = ''0'' then (oti.amount)::numeric * (mi.value->>''amount'')::numeric
			else null
		end as count,
		med.unit as unit,
		mst_medi.class_cd as class_cd,
		oti.class_name as class_name,
		oti.registration_order as registration_order,
		mst_medi.medi_code_order as medi_code_order,
		mst_medi.medi_class_code_order as class_code_order,
		oti.medicine_type as medicine_type_order,
		null as timing_code_order,
		p.procedure_code_order::text as procedure_code_order,
		null as date_interval
	from mst_medicine_mix mmm
		inner join ord_treat_info oti on oti.cd::integer = mmm.medicine_mix_cd
		cross join lateral jsonb_array_elements(mmm.mix_info) as mi(value)
		left join mst_medicine med on med.medicine_cd = (mi.value->>''cd'')::integer
		left join mst_medi on med.class_cd = mst_medi.class_cd
		and med.medicine_cd = mst_medi.medicine_cd
		left join procedure_order p on p.procedure_code = oti.procedure_cd::numeric
	where oti.medicine_type = ''2''
),
unreferenced_medicines_with_order as (
	-- 投薬済みで投薬情報、注射情報、手術麻酔、処置に出力されなかった薬剤
	select case
				(
					select value
					from medi_hospital_cd
				)
				when ''1'' then left(med.in_hospital_cd_1, 20)
				when ''2'' then left(med.in_hospital_cd_2, 20)
				when ''3'' then left(med.in_hospital_cd_3, 20)
			end as code,
			left(med.medicine_name, 80) as name,
			um.amount::numeric as count,
			med.unit as unit,
			mst_medi.class_cd as class_cd,
			mst_medi.class_name as class_name,
			um.registration_order::text as registration_order,
			mst_medi.medi_code_order as medi_code_order,
			mst_medi.medi_class_code_order as class_code_order,
			um.medicine_type as medicine_type_order,
			t.timing_code_order::text as timing_code_order,
			p.procedure_code_order::text as procedure_code_order,
			um.date_interval as date_interval
		from
			unreferenced_medicines um
			left join mst_medicine med on med.medicine_cd = um.medicine_cd::numeric
			left join mst_medi on med.class_cd = mst_medi.class_cd and med.medicine_cd = mst_medi.medicine_cd
			left join timing_order t on t.timing_code = um.timing_cd::numeric
			left join procedure_order p on p.procedure_code = um.procedure_cd::numeric
		where
			(
			select
				value
			from
				default_medicine_group
		        ) = (select value from application_name)
),
final_treatment_info as (
	-- 処置として出力する対象の薬剤
	select o.code,
		o.name,
		SUM(o.count::numeric) as count,
		-- group byに含めたくないので単一項目を取得するために集計関数MINを指定している
		MIN(o.unit) as unit,
		MIN(o.class_cd) as class_cd,
		MIN(o.registration_order) as registration_order,
		MIN(o.medi_code_order) as medi_code_order,
		MIN(o.class_code_order) as class_code_order,
		MIN(o.medicine_type_order) as medicine_type_order,
		MIN(o.timing_code_order) as timing_code_order,
		MIN(o.procedure_code_order) as procedure_code_order,
		MIN(date_interval) as date_interval
	from (
			select ord.code,
				ord.name,
				ord.count,
				ord.unit,
				ord.class_cd,
				ord.class_name,
				ord.registration_order,
				ord.medi_code_order,
				ord.class_code_order,
				ord.medicine_type_order,
				ord.timing_code_order,
				ord.procedure_code_order,
				ord.date_interval
			from ord_treat_medi_info ord
			where (
					select value
					from medicine_add_flag
				) = ''1'' -- medicine_add_flagが1の場合にのみ薬剤の合算を行う
			) as o
	where o.class_name in (
			select treatment_name
			from treatment_names
		)
	group by o.code,
		o.name
	union all
	select o.code,
		o.name,
		o.count,
		o.unit,
		o.class_cd,
		o.registration_order,
		o.medi_code_order,
		o.class_code_order,
		o.medicine_type_order,
		o.timing_code_order,
		o.procedure_code_order,
		o.date_interval
	from ord_treat_medi_info o
	where (
			select value
			from medicine_add_flag
		) = ''0''
		and o.class_name in (
			select treatment_name
			from treatment_names
		)
	union all
	-- 投薬済みで投薬情報、注射情報、手術麻酔、処置に出力されなかった薬剤
	-- DEFAULT_MEDICINE_GROUP=''処置''の時のみ出力		
	select o.code,
		o.name,
		SUM(o.count::numeric) as count,
		-- group byに含めたくないので単一項目を取得するために集計関数MINを指定している
		MIN(o.unit) as unit,
		MIN(o.class_cd) as class_cd,
		MIN(o.registration_order) as registration_order,
		MIN(o.medi_code_order) as medi_code_order,
		MIN(o.class_code_order) as class_code_order,
		MIN(o.medicine_type_order) as medicine_type_order,
		MIN(o.timing_code_order) as timing_code_order,
		MIN(o.procedure_code_order) as procedure_code_order,
		MIN(date_interval) as date_interval
	from (
			select um.code,
				um.name,
				um.count,
				um.unit,
				um.class_cd,
				um.class_name,
				um.registration_order,
				um.medi_code_order,
				um.class_code_order,
				um.medicine_type_order,
				um.timing_code_order,
				um.procedure_code_order,
				um.date_interval
			from unreferenced_medicines_with_order um
			where (
					select value
					from medicine_add_flag
				) = ''1'' 
			) as o
		group by o.code,o.name
	union all
	select um.code,
		um.name,
		um.count,
		um.unit,
		um.class_cd,
		um.registration_order,
		um.medi_code_order,
		um.class_code_order,
		um.medicine_type_order,
		um.timing_code_order,
		um.procedure_code_order,
		um.date_interval
	from unreferenced_medicines_with_order um
	where (
			select value
			from medicine_add_flag
		) = ''0''
	),
facility_equipment_order as (
	select row_number () over () as setting_order,
		TO_NUMBER(datt.a1::text, ''999999999999'') as setting_value
	from (
			select TO_NUMBER(
					(
						unnest(
							string_to_array(
								(
									select mst_f.value as rtt
									from mst_facility_setting as mst_f
									where mst_f.facility_setting_no = ''3006''
										and mst_f.facility_cd = @facilityCd
								),
								'',''
							)
						)
					),
					''999999999999''
				) as a1
		) as datt
),
equip_order as (
	select index_no::int as meq_code_order,
		TO_NUMBER(order_cd->>''code'', ''999999999999'') as meq_code
	from mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
	where facility_cd = @facilityCd
		and master_physical_name = ''mst_equipment''
),
equip_class_order as (
	select index_no::int as meq_class_code_order,
		TO_NUMBER(order_cd->>''code'', ''999999999999'') as meq_class_code
	from mst_selector
		cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
	where facility_cd = @facilityCd
		and master_physical_name = ''mst_equipment_class''
),
mst_equip as (
	select equipment_cd,
		equipment_name,
		class_cd,
		unit,
		in_hospital_cd_1,
		in_hospital_cd_2,
		in_hospital_cd_3,
		in_hospital_cd_4,
		equip_order.meq_code_order,
		equip_class_order.meq_class_code_order
	from mst_equipment meq
		left join equip_order on meq.equipment_cd = equip_order.meq_code
		left join equip_class_order on meq.class_cd = equip_class_order.meq_class_code
	where facility_cd = @facilityCd
),
ord_equip_info as (
	select case
			(
				select value
				from equipment_in_hospital_cd_no
			)
			when ''1'' then left(mst_equip.in_hospital_cd_1, 20)
			when ''2'' then left(mst_equip.in_hospital_cd_2, 20)
			when ''3'' then left(mst_equip.in_hospital_cd_3, 20)
			when ''4'' then left(mst_equip.in_hospital_cd_4, 20)
		end as code,
		left(mst_equip.equipment_name, 80) as name,
		column_info.count::numeric as count,
		mst_equip.unit,
		column_info.idx as registration_order,
		mst_equip.meq_code_order,
		mst_equip.meq_class_code_order
	from column_info
		left join mst_equip on column_info.equipment_cd = mst_equip.equipment_cd::text
	union all
	select case
			(
				select value
				from equipment_in_hospital_cd_no
			)
			when ''1'' then left(mst_equip.in_hospital_cd_1, 20)
			when ''2'' then left(mst_equip.in_hospital_cd_2, 20)
			when ''3'' then left(mst_equip.in_hospital_cd_3, 20)
			when ''4'' then left(mst_equip.in_hospital_cd_4, 20)
		end as code,
		left(mst_equip.equipment_name, 80) as name,
		equipment_info.count::numeric as count,
		mst_equip.unit,
		equipment_info.idx::text as registration_order,
		mst_equip.meq_code_order,
		mst_equip.meq_class_code_order
	from equipment_info
		left join mst_equip on equipment_info.equipment_cd = mst_equip.equipment_cd::text
),
treatment_unit as (
	-- 治療項目単位
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''TREATMENT_UNIT''
	limit 1
), disability_allowance as (
	-- 障害者加算
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DISABILITY_ALLOWANCE''
	limit 1
), diffcomment_count as (
	-- 透析困難コメントの数量
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DIFFCOMMENT_COUNT''
	limit 1
), dialyzer_count as (
	-- ダイアライザの数量
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''DIALYZER_COUNT''
	limit 1
), val_filter_count as (
	-- １次膜、２次膜の数量
	select coalesce(
			nullif(info->>''value'', ''''),
			info->>''default_v''
		) as value
	from mst_coop_ini ini
		cross join lateral json_array_elements(ini.coop_ini_info::json) info
	where facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info->>''key0'', '''') = @key0
		and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
		and info->>''key2'' = ''VAL_FILTER_COUNT''
	limit 1
)
, treat_all as (
	--治療項目情報
	select 1 as item_sort_no,
		case
			when iha.alpha_value = ''A''
			and ihn.no_value = ''1'' then mtt.in_hospital_cd_a1
			when iha.alpha_value = ''A''
			and ihn.no_value = ''2'' then mtt.in_hospital_cd_a2
			when iha.alpha_value = ''A''
			and ihn.no_value = ''3'' then mtt.in_hospital_cd_a3
			when iha.alpha_value = ''A''
			and ihn.no_value = ''4'' then mtt.in_hospital_cd_a4
			when iha.alpha_value = ''B''
			and ihn.no_value = ''1'' then mtt.in_hospital_cd_b1
			when iha.alpha_value = ''B''
			and ihn.no_value = ''2'' then mtt.in_hospital_cd_b2
			when iha.alpha_value = ''B''
			and ihn.no_value = ''3'' then mtt.in_hospital_cd_b3
			when iha.alpha_value = ''B''
			and ihn.no_value = ''4'' then mtt.in_hospital_cd_b4
			else mtt.in_hospital_cd_a1
		end as code,
		ord.rst_treatment_name as name,
		(ord.rst_cond_info->''1''->>''value'')::numeric as count,
		tu.value as unit,
		null as cutoff,
		0 as sort_key
	from ord_main as ord
		cross join treatment_unit tu
		left outer join mst_treatment as mtt on mtt.treatment_cd = ord.rst_treatment_cd
		left join treatment_in_hospital_cd_alpha iha on true
		left join treatment_in_hospital_cd_no ihn on true
	where ord.ord_no = @ordNo
	union all
	-- 障害者加算
	select 2 as item_sort_no,
		case
			when ihn.no_value = ''1'' then madd.in_hospital_cd_1
			when ihn.no_value = ''2'' then madd.in_hospital_cd_2
			when ihn.no_value = ''3'' then madd.in_hospital_cd_3
			else null
		end as code,
		da.value as name,
		null as count,
		null as unit,
		null as cutoff,
		0 as sort_key
	from ord_main as ord
		cross join lateral json_array_elements(ord.addition_info::json) oadd
		cross join disability_allowance da
		left outer join mst_addition as madd on madd.addition_cd = to_number(oadd->>''cd'', ''9999999999'')
		left join addition_in_hospital_cd_no ihn on true
	where ord.ord_no = @ordNo
		and madd.addition_class = ''2''
	union all
	-- 透析困難コメント
	select 3 as item_sort_no,
		left(
			case
				when (
					select no_value
					from dial_diff_in_hospital_cd_no
				)::INTEGER = 1 then mst_dialysis_difficulty.in_hospital_cd_1::VARCHAR
				when (
					select no_value
					from dial_diff_in_hospital_cd_no
				)::INTEGER = 2 then mst_dialysis_difficulty.in_hospital_cd_2::VARCHAR
				else null
			end,
			20
		) as code,
		left(
			mst_dialysis_difficulty.dialysis_difficulty_name,
			256
		) as name,
		dc.value::numeric as count,
		null as unit,
		null as cutoff,
		lpad(
			(
				case
					when eddt.is_main = ''1'' then ''0''
					else ''1''
				end
			) || lpad(fddt.sort_no::text, 3, ''0''),
			4,
			''0''
		)::numeric as sort_key -- 並び順キー：is_main優先 → sort_no
	from mst_dialysis_difficulty
		cross join diffcomment_count dc
		inner join pat_dial_diff_data eddt on mst_dialysis_difficulty.dialysis_difficulty_cd = (eddt.dial_diff_cd)::INTEGER
		inner join mst_selector_dial_diff_data fddt on mst_dialysis_difficulty.dialysis_difficulty_cd = (fddt.code)::INTEGER
	where (
			select no_value
			from dialysis_output_setting
		) = ''0'' -- dialysis_output_setting が 「0」の場合のみ出力を行う。
	union all
	-- 透析液水質確保加算
	select 4 as item_sort_no,
		left(
			case
				coalesce(
					(
						select no_value::INTEGER
						from addition_in_hospital_cd_no
					),
					1
				)
				when 1 then mst_addition.in_hospital_cd_1::VARCHAR
				when 2 then mst_addition.in_hospital_cd_2::VARCHAR
				when 3 then mst_addition.in_hospital_cd_3::VARCHAR
				else mst_addition.in_hospital_cd_1::VARCHAR
			end,
			20
		) as code,
		left(mst_addition.addition_name, 256) as name,
		null as count,
		null as unit,
		null as cutoff,
		0 as sort_key
	from addition_info
		inner join mst_addition on addition_info.code = mst_addition.addition_cd::text
	where addition_info.code = mst_addition.addition_cd::text
		and mst_addition.addition_class = ''1''
	union all
	-- 下肢抹消動脈疾患指導管理加算
	select 5 as item_sort_no,
		left(
			case
				coalesce(
					(
						select no_value::INTEGER
						from addition_in_hospital_cd_no
					),
					1
				)
				when 1 then mst_addition.in_hospital_cd_1::VARCHAR
				when 2 then mst_addition.in_hospital_cd_2::VARCHAR
				when 3 then mst_addition.in_hospital_cd_3::VARCHAR
				else mst_addition.in_hospital_cd_1::VARCHAR
			end,
			20
		) as code,
		left(mst_addition.addition_name, 256) as name,
		null as count,
		null as unit,
		null as cutoff,
		0 as sort_key
	from addition_info
		inner join mst_addition on addition_info.code = mst_addition.addition_cd::text
		inner join addition_key_value on mst_addition.in_hospital_cd_2 in (
			addition_key_value.value::text
		)
	union all
	-- その他加算
	select 6 as item_sort_no,
		left(
			case
				coalesce(
					(
						select no_value::INTEGER
						from addition_in_hospital_cd_no
					),
					1
				)
				when 1 then mst_addition.in_hospital_cd_1::VARCHAR
				when 2 then mst_addition.in_hospital_cd_2::VARCHAR
				when 3 then mst_addition.in_hospital_cd_3::VARCHAR
				else mst_addition.in_hospital_cd_1::VARCHAR
			end,
			20
		) as code,
		left(mst_addition.addition_name, 256) as name,
		null as count,
		null as unit,
		null as cutoff,
		0 as sort_key
	from mst_addition
	where mst_addition.facility_cd = @facilityCd
		and mst_addition.addition_cd::TEXT in (
			select code
			from addition_info
		)
		and (
			not exists (
				select 1
				from addition_key_value akv
				where mst_addition.in_hospital_cd_2 = akv.value
			)
			or mst_addition.in_hospital_cd_2 is null
		)
		and addition_class::numeric not in (1,2,9,10,11,13)
	union all
	-- 加算する治療項目
	select 7 as item_sort_no,
		code_values.code as code,
		name_values.name as name,
		null as count,
		null as unit,
		null as cutoff,
		code_values.padded_num::numeric as sort_key
	from code_values
		join name_values on code_values.padded_num = name_values.padded_num
	union all
	-- 抗凝固剤 
	select 8 as item_sort_no,
		anticoagulant.code as code,
		anticoagulant.name as name,
		anticoagulant.count as count,
		anticoagulant.unit as unit,
		null as cutoff,
		0 as sort_key
	from (
			select *
			from direct_anticoagulant
			union all
			select *
			from mixed_anticoagulant
		) anticoagulant
	where class_type = 1
	union all
	-- 透析液
	select 9 as item_sort_no,
		case
			(
				select value
				from medi_hospital_cd
				limit 1
			)
			when ''1'' then left(in_hospital_cd_1, 20)
			when ''2'' then left(in_hospital_cd_2, 20)
			when ''3'' then left(in_hospital_cd_3, 20)
			when ''4'' then left(in_hospital_cd_4, 20)
		end as code,
		left(medicine_name, 80) as name,
		case
			-- 治療方法（装置モード）が（OHF、OHDF、HD+補液、プログラム補液）の場合、補液は透析液に合算
			when device_mode in (4, 7, 8, 10) then 
				case
					when rst_cond_info->''17''->>''value'' is null
					or rst_cond_info->''22''->>''value'' is null then null
					else (rst_cond_info->''17''->>''value'')::numeric + (rst_cond_info->''22''->>''value'')::numeric
				end
			else (rst_cond_info->''17''->>''value'')::numeric
			end as count,
		unit_second as unit,
		null as cutoff,
		0 as sort_key
	from dialysate_info
	union all
	-- 補液
	select 10 as item_sort_no,
		case
			(
				select value
				from medi_hospital_cd
				limit 1
			)
			when ''1'' then left(in_hospital_cd_1, 20)
			when ''2'' then left(in_hospital_cd_2, 20)
			when ''3'' then left(in_hospital_cd_3, 20)
			when ''4'' then left(in_hospital_cd_4, 20)
		end as code,
		left(medicine_name, 80) as name,
		raw_count_value::numeric as count,
		unit_second as unit,
		null as cutoff,
		0 as sort_key
	from infusion_info
	union all
	-- 処置
	select 11 as item_sort_no,
		f.code as code,
		f.name as name,
		f.count::numeric as count,
		f.unit as unit,
		null as cutoff,
		row_number() over(
			order by case
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 6 then f.date_interval::numeric
				end,
				case
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order::numeric
					when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval::numeric
				end,
                f.medi_code_order::numeric
		) as sort_key
	from final_treatment_info f
	union all
	-- 消耗品
	select 12 as item_sort_no,
		oei.code as code,
		oei.name as name,
		oei.count::numeric as count,
		oei.unit as unit,
		null as cutoff,
		row_number() over(
			order by case
					when ( select setting_value from facility_equipment_order where setting_order = 1 ) = 0 then oei.registration_order::numeric
					when ( select setting_value from facility_equipment_order where setting_order = 1 ) = 1 then oei.meq_class_code_order
					when ( select setting_value from facility_equipment_order where setting_order = 1 ) = 2 then oei.meq_code_order
				end,
				case
					when ( select setting_value from facility_equipment_order where setting_order = 2 ) = 0 then oei.registration_order::numeric
					when ( select setting_value from facility_equipment_order where setting_order = 2 ) = 1 then oei.meq_class_code_order
					when ( select setting_value from facility_equipment_order where setting_order = 2 ) = 2 then oei.meq_code_order
				end,
				case
					when ( select setting_value from facility_equipment_order where setting_order = 3 ) = 0 then oei.registration_order::numeric
					when ( select setting_value from facility_equipment_order where setting_order = 3 ) = 1 then oei.meq_class_code_order
					when ( select setting_value from facility_equipment_order where setting_order = 3 ) = 2 then oei.meq_code_order
				end
                , oei.meq_code_order
		)::numeric as sort_key
	from ord_equip_info oei
	union all
	-- ダイアライザ
	select 13 as item_sort_no,
		case
			when ihn.value = ''1'' then md.in_hospital_cd_1
			when ihn.value = ''2'' then md.in_hospital_cd_2
			when ihn.value = ''3'' then md.in_hospital_cd_3
			when ihn.value = ''4'' then md.in_hospital_cd_4
			else md.in_hospital_cd_1
		end as code,
		md.model_number as name,
		dc.value::numeric as count,
		du.unit as unit,
		null as cutoff,
		0 as sort_key
	from (
			select rst_cond_info->''5'' as cond_info_5
			from ord_main
			where ord_no = @ordNo
		) t
		inner join mst_dialyzer md on md.dialyzer_cd = (t.cond_info_5->>''value'')::integer
		cross join dialyzer_unit du
		cross join dialyzer_count dc
		left join dialyzer_in_hospital_cd_no ihn on true
	union all
	-- １次膜、２次膜
	select 14 as item_sort_no,
		ord_info.code as code,
		ord_info.name as name,
		vfc.value::numeric as count,
		ord_info.unit as unit,
		null as cutoff,
		ord_info.sort_key as sort_key
	from (
			select case
					(
						select value
						from equipment_in_hospital_cd_no
					)
					when ''1'' then left(mst_equipment.in_hospital_cd_1, 20)
					when ''2'' then left(mst_equipment.in_hospital_cd_2, 20)
					when ''3'' then left(mst_equipment.in_hospital_cd_3, 20)
					when ''4'' then left(mst_equipment.in_hospital_cd_4, 20)
				end as code,
				left(mst_equipment.equipment_name, 80) as name,
				mst_equipment.unit,
				1 as sort_key
			from primary_membrane_info,
				mst_equipment
			where primary_membrane_info.equipment_cd = mst_equipment.equipment_cd::text
			union all
			select case
					(
						select value
						from equipment_in_hospital_cd_no
					)
					when ''1'' then left(mst_equipment.in_hospital_cd_1, 20)
					when ''2'' then left(mst_equipment.in_hospital_cd_2, 20)
					when ''3'' then left(mst_equipment.in_hospital_cd_3, 20)
					when ''4'' then left(mst_equipment.in_hospital_cd_4, 20)
				end as code,
				left(mst_equipment.equipment_name, 80) as name,
				mst_equipment.unit,
				2 as sort_key
			from secondary_membrane_info,
				mst_equipment
			where secondary_membrane_info.equipment_cd = mst_equipment.equipment_cd::text
		) ord_info
		cross join val_filter_count vfc
)

select treat_all.item_sort_no,
	treat_all.code as code,
	treat_all.name as name,
    REGEXP_REPLACE(
        TRIM( TRAILING ''.'' FROM TRIM( TRAILING ''0'' FROM ROUND(treat_all.count::numeric, 2)::TEXT ) ), ''^(\d+)\.0+$'', ''\1''
    ) as count,
	treat_all.unit as unit,
	treat_all.cutoff as cutoff,
	row_number() over (
		order by item_sort_no,
			sort_key
	) as seq_no
from treat_all 
order by seq_no;', 2, '[]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'Medicom処方薬剤連携(処置・治療項目情報)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307033, "field_name": "dial_diff_cds", "replace_var": "@dialDiffCds"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307073, 'with input_code_class as (
-- 検査入力者コード区分
-- 0：患者基本情報．担当スタッフ情報→スタッフコード（利用者マスタ．表示用利用者ID）
-- 1：患者連携情報．連携情報カラム２→依頼医名コード（利用者マスタ．表示用利用者ID）
-- 2：固定医師コード1より取得
-- 3：固定医師コード2より取得
-- 4：固定担当看護師コード1より取得
-- 5：固定担当看護師コード2より取得
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_EXAM_INFO''
	and info ->> ''key2'' = ''INPUT_CODE_CLASS''
limit 1
)
,
fixed_doctors as (
select
	(info ->> ''key2'') as key,
	coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') as value
from
	mst_coop_ini ini,
	lateral json_array_elements(ini.coop_ini_info::json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''MCOM_XML_INFO''
		and info ->> ''key2'' in (
    ''FIXED_DOCTOR_CODE1'', ''FIXED_DOCTOR_NAME1'',
    ''FIXED_DOCTOR_CODE2'', ''FIXED_DOCTOR_NAME2'',
    ''FIXED_NURSE_CODE1'', ''FIXED_NURSE_NAME1'',
    ''FIXED_NURSE_CODE2'', ''FIXED_NURSE_NAME2''
  )
)
,disp_user_ids AS (
  SELECT 
    jsonb_array_elements(
      @ids
      ::jsonb
    ) AS elem
),
user_names AS (
  SELECT 
    jsonb_array_elements(
      @names
      ::jsonb
    ) AS elem
)
, 
pat_coop_detail_users as (
select
	du.elem ->> ''coop_save_no'' as coop_save_no,
	du.elem ->> ''disp_user_id'' as disp_user_id,
	un.elem ->> ''user_name'' as user_name
from
	disp_user_ids du
join 
  user_names un 
  on
	(du.elem ->> ''coop_save_no'') = (un.elem ->> ''coop_save_no'')
left join 
  pat_coop_detail pcd 
  on
	pcd.coop_save_no = (du.elem ->> ''coop_save_no'')::numeric
), 
order_units_id_min as (
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_EXAM_INFO''
	and info ->> ''key2'' = ''ORDER_UNITS_ID_MIN''
limit 1
), 
order_units_id_max as (
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_XML_EXAM_INFO''
	and info ->> ''key2'' = ''ORDER_UNITS_ID_MAX''
limit 1
)
,
examination as (
select
	coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
from
	mst_coop_ini as ini
cross join lateral json_array_elements(ini.coop_ini_info :: json) info
where
	facility_cd = @facilityCd
	and is_del = ''0''
	and coalesce(info ->> ''key0'', '''') = @key0
	and info ->> ''key1'' = ''PRESCRIPTION_DETAILS''
	and info ->> ''key2'' = ''EXAMINATION''
limit 1
),
order_units_wrapper as (
select
	pcd.coop_save_no,
	LPAD(pcd.save_2 ->> ''ord_no'', 8, ''0'') || LPAD((row_number() over (order by pcd.coop_save_no) - 1 + oui_min.value::numeric )::text, 2, ''0'') as order_units_id,
	examination.value as application,
	case input_code_class.value::numeric
    	when 0 then 
            case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
            else @dispUserId
            end
		when 1 then 
			case when @dispUserId = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
			else @dispUserId
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_CODE2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_CODE2'' limit 1)
		else null
	end as input_user_code,
		case input_code_class.value::numeric
    	when 0 then 
            case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
            else @userName
            end
		when 1 then 
			case when @userName = '''' then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
			else @userName
			end
		when 2 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME1'' limit 1)
		when 3 then (select value from fixed_doctors where key = ''FIXED_DOCTOR_NAME2'' limit 1)
		when 4 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME1'' limit 1)
		when 5 then (select value from fixed_doctors where key = ''FIXED_NURSE_NAME2'' limit 1)
		else null
	end as input_user_name,
	(pcd.save_2 ->> ''exam_date'') || (pcd.save_2 ->> ''exam_time'') || ''00'' as input_time,
	TO_CHAR(NOW(), ''YYYYMMDDHH24MISS'') as last_update_time,
	row_number() over (order by pcd.coop_save_no) - 1 + oui_min.value::numeric as order_units_id_suffix
from
	pat_coop_detail pcd
cross join examination
cross join input_code_class
cross join order_units_id_min oui_min
cross join order_units_id_max oui_max
left join pat_coop_detail_users pcdu on pcdu.coop_save_no::numeric = pcd.coop_save_no
where
	facility_cd = @facilityCd
	and pat_id = @patId
	and (save_2 ->> ''ord_no'')::numeric = @ordNo)
	
	
select
	coop_save_no,
	order_units_id,
	application,
	input_user_code,
	input_user_name,
	input_time,
	last_update_time,
	''01'' as detail_id,
	@ordNo as ord_no,
	@facilityCd as facility_cd,
	@key0 as key0
from order_units_wrapper
cross join order_units_id_max oui_max
cross join order_units_id_min oui_min
where
	(order_units_id_suffix::numeric) between oui_min.value::numeric and oui_max.value::numeric
order by
	coop_save_no,
	order_units_id_suffix', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '検査情報(Order_Unitsタグ)取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -307077, "field_name": "disp_user_id", "replace_var": "@dispUserId"}, {"sql_cd": -307079, "field_name": "user_name", "replace_var": "@userName"}, {"sql_cd": -307081, "field_name": "disp_user_ids", "replace_var": "@ids"}, {"sql_cd": -307082, "field_name": "user_names", "replace_var": "@names"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307071, 'WITH surgery_name as (
    select
        coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''PRESCRIPTION_DETAILS''
        and info ->> ''key2'' = ''SURGERY''
),order_units_id_suffix as (
    select
        coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''PRESCRIPTION_XML_SURGERY_INFO''
        and info ->> ''key2'' = ''ORDER_UNITS_ID''
)
,ord_medi_infos as (
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
		and mst_medicine_class.class_name = (select value from surgery_name)
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
		and mst_medicine_class.class_name = (select value from surgery_name)
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
		and mst_medicine_class.class_name = (select value from surgery_name)
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
		and mst_medicine_class.class_name = (select value from surgery_name)
 )

 select distinct
        lpad(@ordNo::text, 8, ''0'') || lpad(ouis.value, 2, ''0'') as order_units_id,
 		sn.value as application,
		@ordNo as ord_no,
		@key0 as key0,
		@facilityCd as facility_cd,
		''01'' as detail_id
 from ord_medi_infos omi
 cross join surgery_name sn
 cross join order_units_id_suffix ouis', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307069, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code,
        ord_addition_info ->> ''name'' as name
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
        and is_del = ''0''
)
,
addition_in_hospital_cd_no as(
    select
        coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''MST''
        and info ->> ''key2'' = ''ADDITION_IN_HOSPITAL_CD_NO''
)
,
rece_mng_min_id as(
    select
        coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''PRESCRIPTION_XML_RECE_MNG_INFO''
        and info ->> ''key2'' = ''RECE_MNG_MIN_ID''
)
,
rece_mng_max_id as(
    select
        coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''PRESCRIPTION_XML_RECE_MNG_INFO''
        and info ->> ''key2'' = ''RECE_MNG_MAX_ID''
)
,
med_admin_unit_wrapper as (
select
	LPAD(@ordNo::text, 8, ''0'') || LPAD((row_number() over (order by cast(code as character varying)) - 1 + rm_min_id.value::numeric )::text, 2, ''0'') as order_units_id,
	(
        case
		(
		select
			value
		from
			addition_in_hospital_cd_no
            )
		when ''1'' then left(mst_addition.in_hospital_cd_1, 20)
		when ''2'' then left(mst_addition.in_hospital_cd_2, 20)
		when ''3'' then left(mst_addition.in_hospital_cd_3, 20)
	end
    ) as code,
	left(ord_main_info.name, 256) as name,
	null as count,
	null as unit,
	null as cutoff,
	1 as seq_no,
	LPAD((row_number() over (order by cast(code as character varying)) - 1 + rm_min_id.value::numeric )::text, 2, ''0'') as order_units_id_suffix
from
	ord_main_info
left join mst_addition on
	ord_main_info.code = cast(mst_addition.addition_cd as character varying)
cross join rece_mng_min_id rm_min_id
cross join rece_mng_max_id rm_max_id
where
	mst_addition.addition_class in (''13'')
	)
	
select
	order_units_id,
	code,
    name,
    count,
	unit,
	cutoff,
	seq_no,
	order_units_id_suffix
from
	med_admin_unit_wrapper
	cross join rece_mng_min_id rm_min_id
	cross join rece_mng_max_id rm_max_id
where
	order_units_id_suffix::numeric between rm_min_id.value::numeric and rm_max_id.value::numeric;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '医学管理科情報取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307068, 'with default_medicine_group as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''DEFAULT_MEDICINE_GROUP''
),
-- 
-- 投与情報
-- 
medicine_order_units_num as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
medicine_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from medicine_order_units_num,
        generate_series(1, medicine_order_units_num.value) as i
),
medicine_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_MEDICINE_INFO
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
),
medicine_classes as (
    -- 投与薬剤として出力される薬剤分類名
    select idx.suffix,
        msi.value
    from medicine_setting_info as msi
        join medicine_unit_indices as idx on msi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 注射情報
-- 
injection_order_units_num as (
    -- 出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
injection_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from injection_order_units_num,
        generate_series(1, injection_order_units_num.value) as i
),
injection_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_INJECTION_INFOを取得
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
),
injection_procedure_names as (
    -- 注射情報として出力する手技名を取得
    select idx.suffix,
        isi.value
    from injection_setting_info as isi
        join injection_unit_indices as idx on isi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 手術・麻酔
-- 
surgery_medicine_class_name as (
    -- 手術・麻酔として出力する薬剤分類名を取得
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' = ''SURGERY''
),
-- 
-- 処置
-- 
treatment_num as (
    -- 処置として出力する対象の薬剤分類の数 (TREATMENT_NUM)
    select unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' = ''TREATMENT_NUM''
    limit 1
), treatment_number_series as (
    -- TREATMENT_NUMの数を基にTREATMENT_NAME_{0:D2} を生成
    select LPAD(n::text, 2, ''0'') as padded_num
    from generate_series(
            1,
            (
                select value
                from treatment_num
            )::numeric
        ) as t(n)
),
treatment_name_keys as (
    -- TREATMENT_NAME_{0:D2} の key を生成
    select ''TREATMENT_NAME_'' || padded_num as name_key
    from treatment_number_series
),
treatment_key_value_pairs as (
    -- TREATMENT_NAME_{0:D2} の key/value の組み合わせを出力
    select info->>''key2'' as key,
        unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' like ''TREATMENT_NAME_%''
),
treatment_names as (
    -- TREATMENT_NAME_{0:D2} の名前を取得
    select treatment_name_keys.name_key,
        kv.value as treatment_name
    from treatment_name_keys
        join treatment_key_value_pairs kv on kv.key = treatment_name_keys.name_key
),
class_names as (
    select treatment_name as value
    from treatment_names
    union
    select value
    from surgery_medicine_class_name
    union
    select value
    from medicine_classes
),
unreferenced_medicines as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
),
ord_medi_infos as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and mst_medicine_class.class_name = @application
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and mst_medicine_class.class_name = @application
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and mst_medicine_class.class_name = @application
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and mst_medicine_class.class_name = @application
    union all
    -- 投薬済みで投薬情報、注射情報、手術麻酔、処置に出力されなかった薬剤をセット   
    select *
    from unreferenced_medicines
    where (
            select value
            from default_medicine_group
        ) = @application
),
medicine_in_hospital_cd_no as (
    --薬剤マスタの参照する連携コード
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''MST''
        and info->>''key2'' = ''MEDICINE_IN_HOSPITAL_CD_NO''
),
medicine_add_flag as (
    --薬剤合算フラグ
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''DISTINCT_MEDICINE_FLAG''
),
facility_medicine_order as (
    -- 施設設定マスタ(No.107)
    select row_number () over () as setting_order,
        -- 適用順 
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
),
medi_order as (
    -- 薬剤マスタの並び順
    select index_no::int as medi_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_code,
        order_cd->>''name'' as name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine''
),
medi_class_order as (
    -- 薬剤分類マスタの並び順
    select index_no::int as medi_class_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_class_code,
        order_cd->>''name'' as class_name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine_class''
),
timing_order as (
    -- 投与タイミングマスタの並び順
    select index_no::int as timing_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as timing_code
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicate_timing''
),
procedure_order as (
    -- 手技マスタの並び順
    select index_no::int as procedure_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as procedure_code
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_procedure''
),
mst_medi as (
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
),
final_medi_info as (
    select case
            (
                select value
                from medicine_in_hospital_cd_no
            )
            when ''1'' then left(med.in_hospital_cd_1, 20)
            when ''2'' then left(med.in_hospital_cd_2, 20)
            when ''3'' then left(med.in_hospital_cd_3, 20)
            when ''4'' then left(med.in_hospital_cd_4, 20)
        end as code,
        left(med.medicine_name, 80) as name,
        SUM(amount) as count,
        MIN(med.unit) as unit,
        MIN(med.class_cd) as class_cd,
        MIN(omi.registration_order) as registration_order,
        MIN(mst_medi.medi_code_order) as medi_code_order,
        MIN(mst_medi.medi_class_code_order) as class_code_order,
        MIN(omi.medicine_type::int) as medicine_type_order,
        MIN(t.timing_code_order) as timing_code_order,
        MIN(p.procedure_code_order) as procedure_code_order,
        MIN(omi.date_interval::int) as date_interval
    from ord_medi_infos omi
        left join mst_medicine med on omi.medicine_cd = med.medicine_cd::text
        left join mst_medi on med.class_cd = mst_medi.class_cd
        and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
    where (
            select value
            from medicine_add_flag
        ) = ''1''
    group by code,
        name
    union all
    select case
            (
                select value
                from medicine_in_hospital_cd_no
            )
            when ''1'' then left(med.in_hospital_cd_1, 20)
            when ''2'' then left(med.in_hospital_cd_2, 20)
            when ''3'' then left(med.in_hospital_cd_3, 20)
            when ''4'' then left(med.in_hospital_cd_4, 20)
        end as code,
        left(med.medicine_name, 80) as name,
        amount as count,
        med.unit,
        med.class_cd,
        omi.registration_order as registration_order,
        mst_medi.medi_code_order as medi_code_order,
        mst_medi.medi_class_code_order as class_code_order,
        omi.medicine_type::int as medicine_type_order,
        t.timing_code_order as timing_code_order,
        p.procedure_code_order as procedure_code_order,
        omi.date_interval::int as date_interval
    from ord_medi_infos omi
        left join mst_medicine med on omi.medicine_cd = med.medicine_cd::text
        left join mst_medi on med.class_cd = mst_medi.class_cd
        and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
    where (
            select value
            from medicine_add_flag
        ) = ''0''
)
select row_number() over(
        order by case
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval
            end,
            f.medi_code_order
    ) as seq_no,
    null as cutoff,
    f.code as code,
    f.name as name,
    REGEXP_REPLACE(
        TRIM( TRAILING ''.'' FROM TRIM( TRAILING ''0'' FROM ROUND(f.count::numeric, 2)::TEXT ) ), ''^(\d+)\.0+$'', ''\1''
    ) as count,
    f.unit as unit
from final_medi_info f', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307066, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code,
        ord_addition_info ->> ''name'' as name
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
        and is_del = ''0''
 )
 , treatment_item_value as(
    select
        coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''MST''
        and info ->> ''key2'' = ''ADDITION_IN_HOSPITAL_CD_NO''
 )
select
    ROW_NUMBER() over(
        order by
            code :: text
    ) AS seq_no,
    (
        case
            (
                select
                    value
                from
                    treatment_item_value
            )
            when ''1'' then left(mst_addition.in_hospital_cd_1, 20)
            when ''2'' then left(mst_addition.in_hospital_cd_2, 20)
            when ''3'' then left(mst_addition.in_hospital_cd_3, 20)
        end
    ) as code,
    left(ord_main_info.name, 256) as name,
    null as count,
    null as unit,
    null as cutoff
 from
    ord_main_info,
    mst_addition
 where
    ord_main_info.code = mst_addition.addition_cd :: text
    and mst_addition.addition_class in (''9'')
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307065, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code,
        ord_addition_info ->> ''name'' as name
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
        and is_del = ''0''
 )
 
 select distinct
    @ordNo as ord_no,
	@key0 as key0,
	@facilityCd as facility_cd,
    ''16'' AS detail_id
 from
    ord_main_info,
    mst_addition
 where
    ord_main_info.code = mst_addition.addition_cd :: text
    and mst_addition.addition_class in (''9'')', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307064, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code,
        ord_addition_info ->> ''name'' as name
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
        and is_del = ''0''
 )
 , treatment_item_value as(
    select
        coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''MST''
        and info ->> ''key2'' = ''ADDITION_IN_HOSPITAL_CD_NO''
 )
select
    ROW_NUMBER() over(
        order by
            code :: text
    ) AS seq_no,
    (
        case
            (
                select
                    value
                from
                    treatment_item_value
            )
            when ''1'' then left(mst_addition.in_hospital_cd_1, 20)
            when ''2'' then left(mst_addition.in_hospital_cd_2, 20)
            when ''3'' then left(mst_addition.in_hospital_cd_3, 20)
        end
    ) as code,
    left(ord_main_info.name, 256) as name,
    null as count,
    null as unit,
    null as cutoff
 from
    ord_main_info,
    mst_addition
 where
    ord_main_info.code = mst_addition.addition_cd :: text
    and mst_addition.addition_class in (''10'', ''11'')
 ', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307063, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code,
        ord_addition_info ->> ''name'' as name
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
        and is_del = ''0''
 )

 select distinct
    @ordNo as ord_no,
	@key0 as key0,
	@facilityCd as facility_cd,
    ''15'' AS detail_id
 from
    ord_main_info,
    mst_addition
 where
    ord_main_info.code = mst_addition.addition_cd :: text
    and mst_addition.addition_class in (''10'', ''11'')', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307033, 'SELECT
    COALESCE(
        ''['' || string_agg(
            replace(
                json_build_object(
                    ''is_main'', pat_dial_diff_com_info ->> ''is_main'',
                    ''dial_diff_cd'', pat_dial_diff_com_info ->> ''dial_diff_cd''
                )::TEXT,
                '''''''', ''"''
            ),
            '', ''
        ) || '']'',
        ''[]''
    ) AS dial_diff_cds
FROM
    pat_personal_main
    CROSS JOIN LATERAL json_array_elements(pat_personal_main.dial_diff_com_info::json) pat_dial_diff_com_info
WHERE
    pat_personal_main.pat_id = @patId
    AND pat_dial_diff_com_info ->> ''is_dial_diff'' = ''1''
', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307017, 'WITH  default_medicine_group as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''DEFAULT_MEDICINE_GROUP''
),
-- 
-- 投与情報
-- 
medicine_order_units_num as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
medicine_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from medicine_order_units_num,
        generate_series(1, medicine_order_units_num.value) as i
),
medicine_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_MEDICINE_INFO
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
),
medicine_classes as (
    -- 投与薬剤として出力される薬剤分類名
    select idx.suffix,
        msi.value
    from medicine_setting_info as msi
        join medicine_unit_indices as idx on msi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 注射情報
-- 
injection_order_units_num as (
    -- 出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
injection_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from injection_order_units_num,
        generate_series(1, injection_order_units_num.value) as i
),
injection_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_INJECTION_INFOを取得
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
),
injection_procedure_names as (
    -- 注射情報として出力する手技名を取得
    select idx.suffix,
        isi.value
    from injection_setting_info as isi
        join injection_unit_indices as idx on isi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 手術・麻酔
-- 
surgery_medicine_class_name as (
    -- 手術・麻酔として出力する薬剤分類名を取得
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' = ''SURGERY''
),
-- 
-- 処置
-- 
treatment_num as (
    -- 処置として出力する対象の薬剤分類の数 (TREATMENT_NUM)
    select unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' = ''TREATMENT_NUM''
    limit 1
), treatment_number_series as (
    -- TREATMENT_NUMの数を基にTREATMENT_NAME_{0:D2} を生成
    select LPAD(n::text, 2, ''0'') as padded_num
    from generate_series(
            1,
            (
                select value
                from treatment_num
            )::numeric
        ) as t(n)
),
treatment_name_keys as (
    -- TREATMENT_NAME_{0:D2} の key を生成
    select ''TREATMENT_NAME_'' || padded_num as name_key
    from treatment_number_series
),
treatment_key_value_pairs as (
    -- TREATMENT_NAME_{0:D2} の key/value の組み合わせを出力
    select info->>''key2'' as key,
        unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' like ''TREATMENT_NAME_%''
),
treatment_names as (
    -- TREATMENT_NAME_{0:D2} の名前を取得
    select treatment_name_keys.name_key,
        kv.value as treatment_name
    from treatment_name_keys
        join treatment_key_value_pairs kv on kv.key = treatment_name_keys.name_key
),
class_names as (
    select treatment_name as value
    from treatment_names
    union
    select value
    from surgery_medicine_class_name
    union
    select value
    from medicine_classes
),
unreferenced_medicines as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
),
ord_medi_infos as (
	--通常薬剤の実施済みの治療情報.実績：投与薬剤情報
	select
		LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
		ord_medi_info ->> ''cd'' as medicine_cd,
	    (ord_medi_info ->> ''amount'') :: numeric as amount,
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
        and ord_medi_info ->> ''procedure_name'' = @application
		and ord_medi_info ->> ''medicine_type'' = ''1''
		and (ord_medi_info ->> ''amount'') :: numeric > 0
	UNION
	ALL
    --通常薬剤の治療情報.実績：愁訴処置情報
	select
		LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
		ord_treatment_info ->> ''treat_medicine_cd'' as medicine_cd,
		(ord_treatment_info ->> ''amount'') :: numeric as amount,
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
        and ord_treatment_info ->> ''procedure_name'' = @application
		and ord_treatment_info ->> ''medicine_type'' = ''1''
		and (ord_treatment_info ->> ''amount'') :: numeric > 0
	UNION
	ALL
    --調整薬剤の治療情報.実績：投与薬剤情報
	select
		LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
		medi_mix_info ->> ''cd'' as medicine_cd,
		CASE
			medi_mix_info ->> ''solvent''
			WHEN ''0'' THEN (ord_medi_info ->> ''amount'') :: NUMERIC * (medi_mix_info ->> ''amount'') :: NUMERIC
			WHEN ''1'' THEN (medi_mix_info ->> ''amount'') :: NUMERIC
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
        and ord_medi_info ->> ''procedure_name'' = @application
		and ord_medi_info ->> ''medicine_type'' = ''2''
		and (ord_medi_info ->> ''amount'') :: numeric > 0
	UNION
	ALL
    --調整薬剤の治療情報.実績：愁訴処置情報
	select
		LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
		medi_mix_info ->> ''cd'' as medicine_cd,
		CASE
			medi_mix_info ->> ''solvent''
			WHEN ''0'' THEN (ord_treatment_info ->> ''amount'') :: NUMERIC * (medi_mix_info ->> ''amount'') :: NUMERIC
			WHEN ''1'' THEN (medi_mix_info ->> ''amount'') :: NUMERIC
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
        and ord_treatment_info ->> ''procedure_name'' = @application
		and ord_treatment_info ->> ''medicine_type'' = ''2''
		and (ord_treatment_info ->> ''amount'') :: numeric > 0
	union all
    -- 投薬済みで投薬情報、注射情報、手術麻酔、処置に出力されなかった薬剤をセット   
    select *
    from unreferenced_medicines
    where (
            select value
            from default_medicine_group
        ) = @application
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
		SUM(amount) as count,
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
		amount as count,
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

select 
    ROW_NUMBER() OVER(
        order by 
        case  
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order::numeric
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval end,
        case  
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order::numeric
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval end,
        case  
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order::numeric
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval end,
        case  
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order::numeric
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval end,
        case  
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order::numeric
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval end,
        case  
            when (select setting_value from facility_medicine_order where setting_order = 6 ) = 0 then f.registration_order::numeric
            when (select setting_value from facility_medicine_order where setting_order = 6 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 6 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 6 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 6 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 6 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 6 ) = 6 then f.date_interval end,
        case  
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::numeric
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
            when (select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval end,
            f.medi_code_order
    ) as seq_no,
    null as cutoff,
    f.code as code,
    f.name as name,
    REGEXP_REPLACE(
        TRIM( TRAILING ''.'' FROM TRIM( TRAILING ''0'' FROM ROUND(f.count::numeric, 2)::TEXT ) ), ''^(\d+)\.0+$'', ''\1''
    ) as count,
    f.unit as unit
from final_medi_info f
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307016, 'with default_medicine_group as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''DEFAULT_MEDICINE_GROUP''
),
-- 
-- 投与情報
-- 
medicine_order_units_num as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
medicine_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from medicine_order_units_num,
        generate_series(1, medicine_order_units_num.value) as i
),
medicine_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_MEDICINE_INFO
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
),
medicine_classes as (
    -- 投与薬剤として出力される薬剤分類名
    select idx.suffix,
        msi.value
    from medicine_setting_info as msi
        join medicine_unit_indices as idx on msi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 注射情報
-- 
injection_order_units_num as (
    -- 出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
injection_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from injection_order_units_num,
        generate_series(1, injection_order_units_num.value) as i
),
injection_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_INJECTION_INFOを取得
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
),
injection_procedure_names as (
    -- 注射情報として出力する手技名を取得
    select idx.suffix,
        isi.value
    from injection_setting_info as isi
        join injection_unit_indices as idx on isi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 手術・麻酔
-- 
surgery_medicine_class_name as (
    -- 手術・麻酔として出力する薬剤分類名を取得
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' = ''SURGERY''
),
-- 
-- 処置
-- 
treatment_num as (
    -- 処置として出力する対象の薬剤分類の数 (TREATMENT_NUM)
    select unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' = ''TREATMENT_NUM''
    limit 1
), treatment_number_series as (
    -- TREATMENT_NUMの数を基にTREATMENT_NAME_{0:D2} を生成
    select LPAD(n::text, 2, ''0'') as padded_num
    from generate_series(
            1,
            (
                select value
                from treatment_num
            )::numeric
        ) as t(n)
),
treatment_name_keys as (
    -- TREATMENT_NAME_{0:D2} の key を生成
    select ''TREATMENT_NAME_'' || padded_num as name_key
    from treatment_number_series
),
treatment_key_value_pairs as (
    -- TREATMENT_NAME_{0:D2} の key/value の組み合わせを出力
    select info->>''key2'' as key,
        unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' like ''TREATMENT_NAME_%''
),
treatment_names as (
    -- TREATMENT_NAME_{0:D2} の名前を取得
    select treatment_name_keys.name_key,
        kv.value as treatment_name
    from treatment_name_keys
        join treatment_key_value_pairs kv on kv.key = treatment_name_keys.name_key
),
class_names as (
    select treatment_name as value
    from treatment_names
    union
    select value
    from surgery_medicine_class_name
    union
    select value
    from medicine_classes
),
unreferenced_medicines as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
), order_units_num as (
    -- 出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from order_units_num,
        generate_series(1, order_units_num.value) as i
),
prescription_xml_injection_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_INJECTION_INFOを取得
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
),
order_units_id_suffix as (
    -- 注射情報のOrder_Units_Idのサフィックス
    select idx.suffix,
        ouv.value
    from prescription_xml_injection_info as ouv
        join unit_indices as idx on ouv.key2 = ''ORDER_UNITS_ID_'' || idx.suffix
),
ord_medi_infos as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select 100 + t.idx as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        round((ord_medi_info->>''amount'')::numeric, 2) as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''procedure_name'' as procedure_name,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''procedure_name'' in (
            select value
            from injection_procedure_names
        )
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select 200 + t.idx as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        round((ord_treatment_info->>''amount'')::numeric, 2) as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        ord_treatment_info->>''procedure_name'' as procedure_name,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''procedure_name'' in (
            select value
            from injection_procedure_names
        )
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select 100 + t.idx as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then round(
                (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric,
                2
            )
            when ''1'' then round((medi_mix_info->>''amount'')::numeric, 2)
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''procedure_name'' as procedure_name,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''procedure_name'' in (
            select value
            from injection_procedure_names
        )
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select 200 + t.idx as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then round(
                (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric,
                2
            )
            when ''1'' then round((medi_mix_info->>''amount'')::numeric, 2)
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        ord_treatment_info->>''procedure_name'' as procedure_name,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''procedure_name'' in (
            select value
            from injection_procedure_names
        )
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
)


select *
from 
(
	-- 投与薬剤に出力対象の未分類薬剤が存在した場合に取得
	select 
		omc.value as application,
		LPAD(@ordNo::text, 8, ''0'') || LPAD(ouis.value, 2, ''0'') as order_units_id,
		@ordNo as ord_no,
		@key0 as key0,
		@facilityCd as facility_cd,
		omc.suffix as detail_id
	from injection_procedure_names as omc
	left join order_units_id_suffix as ouis on ouis.suffix = omc.suffix
	where exists (
		select * from unreferenced_medicines
	)
	and omc.value = (select value from default_medicine_group)
	union 
	-- 投与薬剤に出力対象の薬剤が存在した場合に取得	
	select distinct omi.procedure_name as application,
	    LPAD(@ordNo::text, 8, ''0'') || LPAD(ouis.value, 2, ''0'') as order_units_id,
	    @ordNo as ord_no,
	    @key0 as key0,
	    @facilityCd as facility_cd,
	    ipn.suffix as detail_id
	from ord_medi_infos as omi
	    left join injection_procedure_names as ipn on ipn.value = omi.procedure_name
	    left join order_units_id_suffix as ouis on ouis.suffix = ipn.suffix
    ) t
order by detail_id;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307009, 'with default_medicine_group as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''DEFAULT_MEDICINE_GROUP''
),
-- 
-- 投与情報
-- 
medicine_order_units_num as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
medicine_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from medicine_order_units_num,
        generate_series(1, medicine_order_units_num.value) as i
),
medicine_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_MEDICINE_INFO
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
),
medicine_classes as (
    -- 投与薬剤として出力される薬剤分類名
    select idx.suffix,
        msi.value
    from medicine_setting_info as msi
        join medicine_unit_indices as idx on msi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 注射情報
-- 
injection_order_units_num as (
    -- 出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
injection_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from injection_order_units_num,
        generate_series(1, injection_order_units_num.value) as i
),
injection_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_INJECTION_INFOを取得
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
),
injection_procedure_names as (
    -- 注射情報として出力する手技名を取得
    select idx.suffix,
        isi.value
    from injection_setting_info as isi
        join injection_unit_indices as idx on isi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 手術・麻酔
-- 
surgery_medicine_class_name as (
    -- 手術・麻酔として出力する薬剤分類名を取得
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' = ''SURGERY''
),
-- 
-- 処置
-- 
treatment_num as (
    -- 処置として出力する対象の薬剤分類の数 (TREATMENT_NUM)
    select unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' = ''TREATMENT_NUM''
    limit 1
), treatment_number_series as (
    -- TREATMENT_NUMの数を基にTREATMENT_NAME_{0:D2} を生成
    select LPAD(n::text, 2, ''0'') as padded_num
    from generate_series(
            1,
            (
                select value
                from treatment_num
            )::numeric
        ) as t(n)
),
treatment_name_keys as (
    -- TREATMENT_NAME_{0:D2} の key を生成
    select ''TREATMENT_NAME_'' || padded_num as name_key
    from treatment_number_series
),
treatment_key_value_pairs as (
    -- TREATMENT_NAME_{0:D2} の key/value の組み合わせを出力
    select info->>''key2'' as key,
        unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' like ''TREATMENT_NAME_%''
),
treatment_names as (
    -- TREATMENT_NAME_{0:D2} の名前を取得
    select treatment_name_keys.name_key,
        kv.value as treatment_name
    from treatment_name_keys
        join treatment_key_value_pairs kv on kv.key = treatment_name_keys.name_key
),
class_names as (
    select treatment_name as value
    from treatment_names
    union
    select value
    from surgery_medicine_class_name
    union
    select value
    from medicine_classes
),
unreferenced_medicines as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
),
ord_medi_infos as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and mst_medicine_class.class_name = @application
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and mst_medicine_class.class_name = @application
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and mst_medicine_class.class_name = @application
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and mst_medicine_class.class_name = @application
    union all
    -- 投薬済みで投薬情報、注射情報、手術麻酔、処置に出力されなかった薬剤をセット   
    select *
    from unreferenced_medicines
    where (
            select value
            from default_medicine_group
        ) = @application
),
medicine_in_hospital_cd_no as (
    --薬剤マスタの参照する連携コード
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''MST''
        and info->>''key2'' = ''MEDICINE_IN_HOSPITAL_CD_NO''
),
medicine_add_flag as (
    --薬剤合算フラグ
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''DISTINCT_MEDICINE_FLAG''
),
facility_medicine_order as (
    -- 施設設定マスタ(No.107)
    select row_number () over () as setting_order,
        -- 適用順 
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
),
medi_order as (
    -- 薬剤マスタの並び順
    select index_no::int as medi_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_code,
        order_cd->>''name'' as name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine''
),
medi_class_order as (
    -- 薬剤分類マスタの並び順
    select index_no::int as medi_class_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_class_code,
        order_cd->>''name'' as class_name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine_class''
),
timing_order as (
    -- 投与タイミングマスタの並び順
    select index_no::int as timing_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as timing_code
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicate_timing''
),
procedure_order as (
    -- 手技マスタの並び順
    select index_no::int as procedure_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as procedure_code
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_procedure''
),
mst_medi as (
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
),
final_medi_info as (
    select case
            (
                select value
                from medicine_in_hospital_cd_no
            )
            when ''1'' then left(med.in_hospital_cd_1, 20)
            when ''2'' then left(med.in_hospital_cd_2, 20)
            when ''3'' then left(med.in_hospital_cd_3, 20)
            when ''4'' then left(med.in_hospital_cd_4, 20)
        end as code,
        left(med.medicine_name, 80) as name,
        SUM(amount) as count,
        MIN(med.unit) as unit,
        MIN(med.class_cd) as class_cd,
        MIN(omi.registration_order) as registration_order,
        MIN(mst_medi.medi_code_order) as medi_code_order,
        MIN(mst_medi.medi_class_code_order) as class_code_order,
        MIN(omi.medicine_type::int) as medicine_type_order,
        MIN(t.timing_code_order) as timing_code_order,
        MIN(p.procedure_code_order) as procedure_code_order,
        MIN(omi.date_interval::int) as date_interval
    from ord_medi_infos omi
        left join mst_medicine med on omi.medicine_cd = med.medicine_cd::text
        left join mst_medi on med.class_cd = mst_medi.class_cd
        and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
    where (
            select value
            from medicine_add_flag
        ) = ''1''
    group by code,
        name
    union all
    select case
            (
                select value
                from medicine_in_hospital_cd_no
            )
            when ''1'' then left(med.in_hospital_cd_1, 20)
            when ''2'' then left(med.in_hospital_cd_2, 20)
            when ''3'' then left(med.in_hospital_cd_3, 20)
            when ''4'' then left(med.in_hospital_cd_4, 20)
        end as code,
        left(med.medicine_name, 80) as name,
        amount as count,
        med.unit,
        med.class_cd,
        omi.registration_order as registration_order,
        mst_medi.medi_code_order as medi_code_order,
        mst_medi.medi_class_code_order as class_code_order,
        omi.medicine_type::int as medicine_type_order,
        t.timing_code_order as timing_code_order,
        p.procedure_code_order as procedure_code_order,
        omi.date_interval::int as date_interval
    from ord_medi_infos omi
        left join mst_medicine med on omi.medicine_cd = med.medicine_cd::text
        left join mst_medi on med.class_cd = mst_medi.class_cd
        and med.medicine_cd = mst_medi.medicine_cd
        left join timing_order t on t.timing_code = omi.timing_cd::numeric
        left join procedure_order p on p.procedure_code = omi.procedure_cd::numeric
    where (
            select value
            from medicine_add_flag
        ) = ''0''
)
select row_number() over(
        order by case
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 6 ) = 6 then f.date_interval
            end,
            case
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order::numeric
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
                when ( select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval
            end,
            f.medi_code_order
    ) as seq_no,
    null as cutoff,
    f.code as code,
    f.name as name,
    REGEXP_REPLACE(
        TRIM( TRAILING ''.'' FROM TRIM( TRAILING ''0'' FROM ROUND(f.count::numeric, 2)::TEXT ) ), ''^(\d+)\.0+$'', ''\1''
    ) as count,
    f.unit as unit
from final_medi_info f', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307008, 'with default_medicine_group as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_INFO''
        and info->>''key2'' = ''DEFAULT_MEDICINE_GROUP''
),
-- 
-- 投与情報
-- 
medicine_order_units_num as (
    -- 投与薬剤の出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
medicine_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from medicine_order_units_num,
        generate_series(1, medicine_order_units_num.value) as i
),
medicine_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_MEDICINE_INFO
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
),
medicine_classes as (
    -- 投与薬剤として出力される薬剤分類名
    select idx.suffix,
        msi.value
    from medicine_setting_info as msi
        join medicine_unit_indices as idx on msi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 注射情報
-- 
injection_order_units_num as (
    -- 出力処方情報数
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
injection_unit_indices as (
    -- 出力処方情報数から参照するkey2(ORDER_UNITS_{0:D2})のsuffixを取得
    select LPAD(i::text, 2, ''0'') as suffix
    from injection_order_units_num,
        generate_series(1, injection_order_units_num.value) as i
),
injection_setting_info as (
    -- 連携設定 key1=PRESCRIPTION_XML_INJECTION_INFOを取得
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_INJECTION_INFO''
),
injection_procedure_names as (
    -- 注射情報として出力する手技名を取得
    select idx.suffix,
        isi.value
    from injection_setting_info as isi
        join injection_unit_indices as idx on isi.key2 = ''ORDER_UNITS_'' || idx.suffix
),
-- 
-- 手術・麻酔
-- 
surgery_medicine_class_name as (
    -- 手術・麻酔として出力する薬剤分類名を取得
    select coalesce(
            nullif(info->>''value'', ''''),
            info->>''default_v''
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_DETAILS''
        and info->>''key2'' = ''SURGERY''
),
-- 
-- 処置
-- 
treatment_num as (
    -- 処置として出力する対象の薬剤分類の数 (TREATMENT_NUM)
    select unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' = ''TREATMENT_NUM''
    limit 1
), treatment_number_series as (
    -- TREATMENT_NUMの数を基にTREATMENT_NAME_{0:D2} を生成
    select LPAD(n::text, 2, ''0'') as padded_num
    from generate_series(
            1,
            (
                select value
                from treatment_num
            )::numeric
        ) as t(n)
),
treatment_name_keys as (
    -- TREATMENT_NAME_{0:D2} の key を生成
    select ''TREATMENT_NAME_'' || padded_num as name_key
    from treatment_number_series
),
treatment_key_value_pairs as (
    -- TREATMENT_NAME_{0:D2} の key/value の組み合わせを出力
    select info->>''key2'' as key,
        unnest(
            string_to_array(
                coalesce(
                    nullif(info->>''value'', ''''),
                    info->>''default_v''
                ),
                '',''
            )
        ) as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and info->>''key0'' = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_TREAT_INFO''
        and info->>''key2'' like ''TREATMENT_NAME_%''
),
treatment_names as (
    -- TREATMENT_NAME_{0:D2} の名前を取得
    select treatment_name_keys.name_key,
        kv.value as treatment_name
    from treatment_name_keys
        join treatment_key_value_pairs kv on kv.key = treatment_name_keys.name_key
),
class_names as (
    select treatment_name as value
    from treatment_names
    union
    select value
    from surgery_medicine_class_name
    union
    select value
    from medicine_classes
),
unreferenced_medicines as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        (ord_medi_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        (ord_treatment_info->>''amount'')::numeric as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select LPAD(ord_medi_info->>''no'', 20, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select LPAD(ord_treatment_info->>''ctl_no'', 10, ''0'') || LPAD(ord_treatment_info->>''row_no'', 10, ''0'') as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric
            when ''1'' then (medi_mix_info->>''amount'')::numeric
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (
                select value
                from injection_procedure_names
            )
        )
        and (
            mst_medicine_class.class_name is null
            or mst_medicine_class.class_name not in(
                select value
                from class_names
            )
        )
),
 order_units_num as (
    -- 
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'')::int as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
        and info->>''key2'' = ''ORDER_UNITS_NUM''
),
unit_indices as (
    select LPAD(i::text, 2, ''0'') as suffix
    from order_units_num,
        generate_series(1, order_units_num.value) as i
),
order_unit_values as (
    select info->>''key2'' as key2,
        coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''PRESCRIPTION_XML_MEDICINE_INFO''
),
output_medicine_classes as (
    select idx.suffix,
        ouv.value
    from order_unit_values as ouv
        join unit_indices as idx on ouv.key2 = ''ORDER_UNITS_'' || idx.suffix
),
order_units_id_suffix as (
    select idx.suffix,
        ouv.value
    from order_unit_values as ouv
        join unit_indices as idx on ouv.key2 = ''ORDER_UNITS_ID_'' || idx.suffix
),
ord_medi_infos as (
    --通常薬剤の実施済みの治療情報.実績：投与薬剤情報
    select 100 + t.idx as registration_order,
        ord_medi_info->>''cd'' as medicine_cd,
        round((ord_medi_info->>''amount'')::numeric, 2) as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval,
        mst_medicine_class.class_name as class_name
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine on ord_medi_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''1''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name in (
            select value
            from output_medicine_classes
        )
    union all
    --通常薬剤の治療情報.実績：愁訴処置情報
    select 200 + t.idx as registration_order,
        ord_treatment_info->>''treat_medicine_cd'' as medicine_cd,
        round((ord_treatment_info->>''amount'')::numeric, 2) as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval,
        mst_medicine_class.class_name as class_name
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''1''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name in (
            select value
            from output_medicine_classes
        )
    union all
    --調整薬剤の治療情報.実績：投与薬剤情報
    select 100 + t.idx as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then round(
                (ord_medi_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric,
                2
            )
            when ''1'' then round((medi_mix_info->>''amount'')::numeric, 2)
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        ord_medi_info->>''procedure_cd'' as procedure_cd,
        ord_medi_info->>''date_interval'' as date_interval,
        mst_medicine_class.class_name as class_name
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_medi_info::json) with ordinality as t(ord_medi_info, idx)
        left join mst_medicine_mix on ord_medi_info->>''cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_medi_info->>''effect_flg'' = ''1''
        and ord_medi_info->>''medicine_type'' = ''2''
        and (ord_medi_info->>''amount'')::numeric > 0
        and (
            ord_medi_info->>''procedure_name'' is null
            or ord_medi_info->>''procedure_name'' not in (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name in (
            select value
            from output_medicine_classes
        )
    union all
    --調整薬剤の治療情報.実績：愁訴処置情報
    select 200 + t.idx as registration_order,
        medi_mix_info->>''cd'' as medicine_cd,
        case
            medi_mix_info->>''solvent''
            when ''0'' then round(
                (ord_treatment_info->>''amount'')::numeric * (medi_mix_info->>''amount'')::numeric,
                2
            )
            when ''1'' then round((medi_mix_info->>''amount'')::numeric, 2)
        end as amount,
        mst_medicine.class_cd as class_cd,
        ord_treatment_info->>''medicine_type'' as medicine_type,
        null as timing_cd,
        ord_treatment_info->>''procedure_cd'' as procedure_cd,
        null as date_interval,
        mst_medicine_class.class_name as class_name
    from ord_main
        cross join lateral json_array_elements(ord_main.rst_treatment_info::json) with ordinality as t(ord_treatment_info, idx)
        left join mst_medicine_mix on ord_treatment_info->>''treat_medicine_cd'' = mst_medicine_mix.medicine_mix_cd::text
        left join json_array_elements(mst_medicine_mix.mix_info::json) medi_mix_info on true
        left join mst_medicine on medi_mix_info->>''cd'' = mst_medicine.medicine_cd::text
        left join mst_medicine_class on mst_medicine_mix.class_cd = mst_medicine_class.class_cd
    where ord_no = @ordNo
        and ord_main.is_del = ''0''
        and ord_treatment_info->>''medicine_type'' = ''2''
        and (ord_treatment_info->>''amount'')::numeric > 0
        and (
            ord_treatment_info->>''procedure_name'' is null
            or ord_treatment_info->>''procedure_name'' not in (''静注'', ''筋注'', ''皮内注'', ''皮下注'', ''点滴'', ''特注'')
        )
        and mst_medicine_class.class_name in (
            select value
            from output_medicine_classes
        )
)


select *
from 
(
	-- 投与薬剤に出力対象の未分類薬剤が存在した場合に取得
	select 
		omc.value as application,
		LPAD(@ordNo::text, 8, ''0'') || LPAD(ouis.value, 2, ''0'') as order_units_id,
		@ordNo as ord_no,
		@key0 as key0,
		@facilityCd as facility_cd,
		omc.suffix as detail_id
	from output_medicine_classes as omc
	left join order_units_id_suffix as ouis on ouis.suffix = omc.suffix
	where exists (
		select * from unreferenced_medicines
	)
		and omc.value = (select value from default_medicine_group)
	union 
	-- 投与薬剤に出力対象の薬剤が存在した場合に取得	
	select distinct 
		omi.class_name as application,
	    LPAD(@ordNo::text, 8, ''0'') || LPAD(ouis.value, 2, ''0'') as order_units_id,
	    @ordNo as ord_no,
	    @key0 as key0,
	    @facilityCd as facility_cd,
	    omc.suffix as detail_id
	from ord_medi_infos as omi
	    left join output_medicine_classes as omc on omc.value = omi.class_name
	    left join order_units_id_suffix as ouis on ouis.suffix = omc.suffix
    ) t
order by detail_id;

', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '投薬情報(Order_Unitsタグ)取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307004, 'with ord as (
    select 
    treat_date,
    pat_id
    from ord_main
    where ord_no = @ordNo
)
, present as (
    select coop_save_no
    from pat_coop_detail, ord
    where TO_CHAR(up_date, ''YYYYMMDD'') = ord.treat_date
    and ord.pat_id = pat_coop_detail.pat_id
    order by up_date desc
    limit 1
)
, past as (
    select coop_save_no
    from pat_coop_detail, ord
    where TO_CHAR(up_date, ''YYYYMMDD'') < ord.treat_date
    and ord.pat_id = pat_coop_detail.pat_id
    order by up_date desc
    limit 1
)
, future as (
    select coop_save_no
    from pat_coop_detail, ord
    where TO_CHAR(up_date, ''YYYYMMDD'') > ord.treat_date
    and ord.pat_id = pat_coop_detail.pat_id
    order by up_date asc
    limit 1
)
, final_choice as (
    select coop_save_no from present
    union all
    select coop_save_no from past
    where not exists (select 1 from present)
    union all
    select coop_save_no from future
    where not exists (select 1 from present) and not exists (select 1 from past)
)
select
    pcd.save_2 ->> ''insu_name'' as insurance,
    pcd.save_2 ->> ''insu_no'' as insurance_id
from
    pat_coop_detail pcd
    join final_choice fc on pcd.coop_save_no = fc.coop_save_no
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307003, 'select
	(
		case
			when @transKbn IN (''0'',''1'',''2'') then (
				select
					personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
				from
					mst_personal_user
				where
					user_id = @staffCd
			)
			ELSE @staffName
		end
	) as doctor_name', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -307001, "field_name": "trans_kbn", "replace_var": "@transKbn"}, {"sql_cd": -307001, "field_name": "staff_cd", "replace_var": "@staffCd"}, {"sql_cd": -307001, "field_name": "staff_name", "replace_var": "@staffName"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307002, 'select
	(
		case
			when @transKbn IN (''0'',''1'',''2'') then (
				select
					disp_user_id
				from
					mst_user_authentication
				where
					user_id = @staffCd
			)
			ELSE @staffCd
		end
	) as doctor_id', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -307001, "field_name": "trans_kbn", "replace_var": "@transKbn"}, {"sql_cd": -307001, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307001, 'WITH pat_info AS (
	SELECT
			staff_info ->> ''ctl_no'' AS ctl_no,
			staff_info ->> ''disp_order'' AS disp_order,
			staff_info ->> ''staff_cd'' AS staff_cd,
			staff_info ->> ''is_main'' AS is_main
	FROM
			pat_main AS pat
	CROSS JOIN LATERAL json_array_elements(pat.charge_staff_info::json) staff_info
	WHERE
		1 = 1
		AND pat.pat_id = @patId
		AND staff_info ->> ''is_main'' = ''1''
	ORDER BY
			staff_info ->> ''disp_order'' ASC
	LIMIT
			1
)
, coop_journal_info AS (
	SELECT
			user_id
	FROM
			sys_coop_journal AS sys
	WHERE
		1 = 1
		AND sys.ctl_no = @ctlNo
)
, coop_ini_info AS (
	-- 設定値全取得
	SELECT
		info ->> ''key1'' AS key1,
		info ->> ''key2'' AS key2,
		UNNEST(
			string_to_array(
				COALESCE(
					NULLIF(info ->> ''value'',''''),
					info ->> ''default_v''
				),
			'',''
			)
		) AS VALUE
	FROM
			mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
	WHERE
		1 = 1
		AND facility_cd = @facilityCd
		AND is_del = ''0''
		AND info ->> ''key0'' = @key0
)
, medical_name_setting AS (
-- 診療科名設定区分
	SELECT
			value
	FROM
			coop_ini_info info
	WHERE
		1 = 1
		AND info.key1 = ''PRES_XML_BASIC_INFO''
		AND info.key2 = ''DEPARTMENT_NAME_CLASS''
)
, medical_code_setting AS (
	-- 診療科コード設定区分
	SELECT
			value
	FROM
			coop_ini_info info
	WHERE
		1 = 1
		AND info.key1 = ''PRESCRIPTION_XML_BASIC_INFO''
		AND info.key2 = ''DEPARTMENT_CODE_CLASS''
)
, presciption_in_patient_setting AS (
  SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_COMMON_INFO'' AND key2 = ''INOUT_USE_SET''
)
, presciption_inout_setting AS (
  SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''PRES_XML_BASIC_INFO'' AND key2 = ''PRESCRIPTION_INOUT''
)
, mcom_xml_info AS(
	-- 固定値取得
	SELECT
			key2,
			value
	FROM
			coop_ini_info
	WHERE
		1 = 1
		AND key1 = ''MCOM_XML_INFO''
)
 , doctor_name_class_setting AS(
	-- 担当医師コード区分
	SELECT
			value
	FROM
			coop_ini_info info
	WHERE
		1 = 1
		AND key1 = ''PRESCRIPTION_XML_BASIC_INFO''
		AND key2 = ''DOCTOR_CODE_CLASS''
)
, ord_info AS (
	-- 治療実績情報
	SELECT
			rst_charge_user_info ->> ''user_last_name_1'' AS last_name1,
			rst_charge_user_info ->> ''user_first_name_1'' AS first_name1,
			rst_charge_user_info ->> ''user_id_1'' AS user_id_1,
			rst_course_cd,
			rst_course_name,
			rst_in_out_class
	FROM
			ord_main
	WHERE
		1 = 1
		AND ord_no = @ordNo
)
, select_staff_cd AS (
	SELECT 
	(
	  CASE (SELECT value FROM doctor_name_class_setting)::text
	    WHEN ''0'' THEN COALESCE(
	      (SELECT CAST(user_id AS CHARACTER VARYING) FROM coop_journal_info),
	      (SELECT user_id_1 FROM ord_info),
	      (SELECT staff_cd FROM pat_info),
	      (SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_XML_INFO'' AND key2 = ''FIXED_DOCTOR_CODE1'')
	    )
	    WHEN ''1'' THEN COALESCE(
	      (SELECT user_id_1 FROM ord_info),
	      (SELECT staff_cd FROM pat_info),
	      (SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_XML_INFO'' AND key2 = ''FIXED_DOCTOR_CODE1'')
	    )
	    WHEN ''2'' THEN COALESCE(
	      (SELECT staff_cd FROM pat_info),
	      (SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_XML_INFO'' AND key2 = ''FIXED_DOCTOR_CODE1'')
	    )
	    WHEN ''3'' THEN (
	      SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_XML_INFO'' AND key2 = ''FIXED_DOCTOR_CODE1''
	    )
	    WHEN ''4'' THEN (
	      SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_XML_INFO'' AND key2 = ''FIXED_DOCTOR_CODE2''
	    )
	    WHEN ''5'' THEN (
	      SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_XML_INFO'' AND key2 = ''FIXED_NURSE_CODE1''
	    )
	    WHEN ''6'' THEN (
	      SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_XML_INFO'' AND key2 = ''FIXED_NURSE_CODE2''
	    )
	  END
	) AS staff_cd,
	-- ▼ staff_cdが取得された元テーブルの識別（0: journal, 1: ord, 2: pat, 3: coop）
	(
	  CASE (SELECT value FROM doctor_name_class_setting)::text
	    WHEN ''0'' THEN
	      CASE
	        WHEN EXISTS (SELECT 1 FROM coop_journal_info WHERE user_id IS NOT NULL) THEN ''0''
	        WHEN EXISTS (SELECT 1 FROM ord_info WHERE user_id_1 IS NOT NULL) THEN ''1''
	        WHEN EXISTS (SELECT 1 FROM pat_info WHERE staff_cd IS NOT NULL) THEN ''2''
	        ELSE ''3''
	      END
	    WHEN ''1'' THEN
	      CASE
	        WHEN EXISTS (SELECT 1 FROM ord_info WHERE user_id_1 IS NOT NULL) THEN ''1''
	        WHEN EXISTS (SELECT 1 FROM pat_info WHERE staff_cd IS NOT NULL) THEN ''2''
	        ELSE ''3''
	      END
	    WHEN ''2'' THEN
	      CASE
	        WHEN EXISTS (SELECT 1 FROM pat_info WHERE staff_cd IS NOT NULL) THEN ''2''
	        ELSE ''3''
	      END
	    WHEN ''3'' THEN ''3''
	    WHEN ''4'' THEN ''4''
	    WHEN ''5'' THEN ''5''
	    WHEN ''6'' THEN ''6''
	  END
	) AS trans_kbn
)
SELECT
	staff_cd,
	trans_kbn,
	(
	  CASE 
	    WHEN (SELECT trans_kbn FROM select_staff_cd) IN (''0'',''1'',''2'') THEN ''0''
	    WHEN (SELECT trans_kbn FROM select_staff_cd)  = ''3'' THEN (
	      SELECT value FROM mcom_xml_info WHERE 1 = 1 AND key2 = ''FIXED_DOCTOR_NAME1''
	    )
	    WHEN (SELECT trans_kbn FROM select_staff_cd)  = ''4'' THEN (
	      SELECT value FROM mcom_xml_info WHERE 1 = 1 AND key2 = ''FIXED_DOCTOR_NAME2''
	    )
	    WHEN (SELECT trans_kbn FROM select_staff_cd)  = ''5'' THEN (
	      SELECT value FROM mcom_xml_info WHERE 1 = 1 AND key2 = ''FIXED_NURSE_NAME1''
	    )
	    WHEN (SELECT trans_kbn FROM select_staff_cd)  = ''6'' THEN (
	      SELECT value FROM mcom_xml_info WHERE 1 = 1 AND key2 = ''FIXED_NURSE_NAME2''
	    )
	  END
	) AS staff_name,
	COALESCE(
	  (SELECT rst_course_name FROM ord_info),
	  (SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_XML_INFO'' AND key2 = ''DEPARTMENT_NAME'')
	) AS department_name,
	COALESCE(
	  (
	    SELECT in_hospital_cd_1
	    FROM ord_info
	    LEFT OUTER JOIN mst_course AS mcs ON mcs.course_cd = ord_info.rst_course_cd
	  ),
	  (
	    SELECT value FROM coop_ini_info WHERE 1 = 1 AND key1 = ''MCOM_XML_INFO'' AND key2 = ''DEPARTMENT_CODE''
	  )
	) AS department_cd,
	CASE
		WHEN (SELECT value FROM presciption_in_patient_setting) = ''1'' 
			THEN 
				CASE (SELECT rst_in_out_class FROM ord_info) 
					WHEN ''1'' THEN ''入院''
					WHEN ''0'' THEN ''外来''
				END
		ELSE ''''
	END AS in_patient_flag,
	CASE (SELECT rst_in_out_class FROM ord_info) 
		WHEN ''1'' THEN ''院外''
		WHEN ''0'' THEN ''院内''
		ELSE ''''
	END AS presciption_inout
FROM
	select_staff_cd', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-306001, ' select
 ltrim(hosp_pat_id,''0'') AS hosp_pat_id,
 personal_info_decrypt(pat_last_name)||'' ''||personal_info_decrypt(pat_first_name) as pat_name,
 personal_info_decrypt(pat_last_name_kana)||'' ''||personal_info_decrypt(pat_first_name_kana) as pat_name_kana,
 personal_info_decrypt(pat_last_name_alpha)||'' ''||personal_info_decrypt(pat_first_name_alpha) as pat_name_alpha,
 pat_birthday as pat_birthday_yyyymmdd,
 to_char(to_date(pat_birthday, ''YYYYMMDD''), ''YYYY/MM/DD'') as pat_birthday,
 case when pat_birthday is null then null
 else to_char(date_part(''year'',age(''now'', to_date(pat_birthday, ''YYYYMMDD''))), ''FM999'')
 end as pat_age,
 case when pat_sex = 1 then 0   when pat_sex = 2 then 1 else 2 end as pat_sex,
 pat_blood_type_abo,
 pat_blood_type_rh,
 pat_blood_type_abo * 10 +  pat_blood_type_rh as pat_blood_type_abo_rh,
 pat_blood_type_serovar as pat_blood_type_serovar,
 in_out_class,
 case in_out_class when 0 then ''外来'' when 1 then ''入院'' else ''不明'' end as in_out_class_name,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''zip_cd'')) as pat_zip,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''address'')) as pat_address,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''tel1'')) as pat_tel1,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''tel2'')) as pat_tel2,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''fax'')) as pat_fax,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''e_mail'')) as pat_e_mail,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''work_name'')) as pat_work_name,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''work_tel'')) as pat_work_tel,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''memo1'')) as pat_memo1,
 trim(both ''"'' from personal_info_decrypt(pat_contact_info->>''memo2'')) as pat_memo2,
 nationality as nationality,
 COALESCE(severity_cd,0) as severity_cd,
 COALESCE(transport_cd,0) as transport_cd,
 is_die,
 die_date,
 die_cd,
 die_cd as die_cd1,
 -- 透析困難有無
 case when jsonb_array_length(dial_diff_com_info) > 0 then 1 else 0 end as dial_diff_com_info_flag,
 up_date,
 insu_class, 
 insu_name
 from
 pat_personal_main
 left outer join (select pat_id, insu_class, insu_name from pat_insurance where pat_id = @patId and is_del = ''0'' order by is_selected desc limit 1) as insurance on insurance.pat_id = pat_personal_main.pat_id
 where
 is_del = ''0''
 and
 pat_personal_main.pat_id = @patId', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-458, 'WITH staff_info AS ( 
  SELECT
    staff_info ->> ''staff_cd'' AS staff_cd 
  FROM
    pat_main AS pat 
    CROSS JOIN LATERAL json_array_elements(pat.charge_staff_info ::json) staff_info 
  WHERE
    pat.pat_id = @patId
    AND staff_info ->> ''is_main'' = ''1'' 
  ORDER BY
    staff_info ->> ''ctl_no'' ASC 
  LIMIT 1
), 
memo_info AS ( 
  SELECT
    string_agg(replace(replace(memo_info->>''content'', CHR(10), ''''), CHR(13), ''''), ''　'') AS memo
  FROM
    pat_main AS pat 
    CROSS JOIN LATERAL json_array_elements(pat.pat_memo_info ::json) memo_info 
  WHERE
    pat.pat_id = @patId
    AND memo_info->>''content'' IS NOT NULL
) 
SELECT
  ord.rst_start_date AS start_date   --透析開始日時
  , TO_CHAR(ord.rst_start_date, ''YYYYMMDDHH24MISS'') AS start_date14
  , CASE 
    WHEN ord.up_user_id IS NOT NULL AND LENGTH(ord.up_user_id ::TEXT) <> 0 THEN 
      ord.up_user_id 
    WHEN ord.rst_charge_user_info ->> ''user_id_1'' IS NOT NULL AND LENGTH(ord.rst_charge_user_info ->> ''user_id_1'' ::TEXT) <> 0 THEN 
      (ord.rst_charge_user_info ->> ''user_id_1'') :: BIGINT
    ELSE (SELECT staff_cd :: BIGINT FROM staff_info) 
    END AS staff_cd   -- 担当医
  , mcs.in_hospital_cd_1 AS course_cd   --診療科コード１
  , mcs.course_name AS course_name   --診療科名
	, (SELECT memo FROM memo_info) AS memo -- メモ
FROM
  ord_main as ord
  LEFT OUTER JOIN mst_course AS mcs ON mcs.course_cd = ord.rst_course_cd
WHERE
  ord.ord_no = @ordNo  
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom処方薬剤連携(患者情報)', '2020-05-13 11:51:04.000', CURRENT_TIMESTAMP, NULL);