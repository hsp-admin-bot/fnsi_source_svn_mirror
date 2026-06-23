DELETE FROM "ntss"."sys_data_set" where sql_cd in (201,222);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (201, 'with prescription_tbl as ( 
	SELECT a.* FROM ( 
		SELECT
			(o ->> ''Rp'') AS rp
			,(o ->> ''sub_no'') as sub_no
			, (o ->> ''F1'') AS issue_name--調剤指示名
			, CASE WHEN (o ->> ''type'') IN (''3'', ''5'') THEN (o ->> ''F2'') || '' '' || (o ->> ''F3'') || '' '' || (o ->> ''F4'')
				ELSE (o ->> ''F2'') END AS usage_detail--用法詳細
			, op.ord_prescription_no AS ord_prescription_no 
			, CASE WHEN (o ->> ''F5'') = ''0'' or (o ->> ''F5'') = '''' then '' '' ELSE (o ->> ''F5'') END AS day_count
			, CASE WHEN (o ->> ''F5'') = ''0'' or (o ->> ''F5'') = '''' then '' '' ELSE (o ->> ''F6'') END AS day_count_unit
			, ROW_NUMBER() OVER (PARTITION BY  (o ->> ''Rp''),(o ->> ''sub_no'')   ORDER BY (o ->> ''Rp''),(o ->> ''sub_no'')  ASC) AS rn 
		FROM
			ord_prescription AS op
			, jsonb_array_elements(prescription_detail) AS o 
		WHERE
			op.is_disp = ''1'' 
			AND op.is_del = ''0''
			AND o ->> ''type'' <> ''1'' 
			AND o ->> ''type'' <> ''6'' 
			AND o ->> ''type'' <> ''E'' 
			AND o ->> ''type'' <> ''0'' 
			AND op.facility_cd = @facilityCd
			AND op.ord_prescription_no = @ordPrescriptionNo 
	) a 
	WHERE 
		a.rn = 1
), comont_info as (
	select 
	COALESCE(pt.rp, com1.rp) as rp,
	COALESCE(pt.sub_no, com1.sub_no) as sub_no,
	pt.issue_name,
	pt.usage_detail,
	pt.ord_prescription_no,
	pt.day_count,
	pt.day_count_unit,
	com1.issue_name as comment_info
	 from (select com.* from (SELECT
			(o ->> ''Rp'') AS rp
			,(o ->> ''sub_no'') as sub_no
			, (o ->> ''F1'') AS issue_name--調剤指示名
			, CASE WHEN (o ->> ''type'') IN (''3'', ''5'') THEN (o ->> ''F2'') || '' '' || (o ->> ''F3'') || '' '' || (o ->> ''F4'')
				ELSE (o ->> ''F2'') END AS usage_detail--用法詳細
			, op.ord_prescription_no AS ord_prescription_no 
			, CASE WHEN (o ->> ''F5'') = ''0'' or (o ->> ''F5'') = '''' then '' '' ELSE (o ->> ''F5'') END AS day_count
			, CASE WHEN (o ->> ''F5'') = ''0'' or (o ->> ''F5'') = '''' then '' '' ELSE (o ->> ''F6'') END AS day_count_unit
			, ROW_NUMBER() OVER (PARTITION BY  (o ->> ''Rp''),(o ->> ''sub_no'')   ORDER BY (o ->> ''Rp''),(o ->> ''sub_no'') ASC) AS rn 
		FROM
			ord_prescription AS op
			, jsonb_array_elements(prescription_detail) AS o 
		WHERE
			op.is_disp = ''1'' 
			AND op.is_del = ''0''
			AND o ->> ''type'' = ''6'' 
			AND op.facility_cd = @facilityCd
			AND op.ord_prescription_no = @ordPrescriptionNo  )  com where com.rn = 1 	AND com.issue_name <>'''' ) com1  
			FULL OUTER JOIN prescription_tbl pt 
		on pt.rp = com1.rp and pt.sub_no = com1.sub_no
) 
SELECT
	ord_pt.rp
	, ord_pt.unchg
	, ord_pt.medicine_name
	, ord_pt.mix_name
	, coin.issue_name
	, coin.usage_detail 
	, ord_pt.rst_value
	, ord_pt.unit
	, ord_pt.r
	, coin.day_count
	, coin.day_count_unit
	, ord_pt.ord_prescription_no
	, coin.comment_info
FROM ( 
	SELECT
		json_idx
		,	(o ->> ''Rp'') AS rp
		,(o ->> ''sub_no'') AS sub_no
		, CASE WHEN ( o ->> ''unchg'' ) = ''x'' THEN ''2'' ELSE ''1'' END AS unchg 
		, (o ->> ''F1'') AS medicine_name--薬剤名
		, (o ->> ''F2'') AS mix_name--用法
		, ( o ->> ''F5'' ) AS rst_value--量
		, ( o ->> ''F6'' ) AS unit--単位
		, ( o ->> ''R'' ) AS r --薬剤処方箋用表示
		, op.ord_prescription_no AS ord_prescription_no 
	FROM
		ord_prescription AS op
		cross join lateral jsonb_array_elements(prescription_detail) with ordinality as tmp(o, json_idx)
	WHERE
		op.is_disp = ''1'' 
		AND op.is_del = ''0'' 
		AND o ->> ''type'' = ''1''
		AND op.facility_cd = @facilityCd
		AND op.ord_prescription_no = @ordPrescriptionNo 
) ord_pt
left join comont_info coin 
		on coin.rp = ord_pt.rp and coin.sub_no = ord_pt.sub_no
ORDER BY ord_pt.json_idx ASC
', 2, '[{"preview": "×", "can_calc": "0", "data_code": "unchg", "data_name": "後発不可", "data_type": "string", "conv_table": [{"code": "1", "disp": "", "item": "可"}, {"code": "2", "disp": "×", "item": "不可"}], "data_class": "薬剤情報", "field_name": "unchg", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456", "can_calc": "0", "data_code": "Rp", "data_name": "RP番号", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "rp", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "調剤指示名", "can_calc": "0", "data_code": "issue_name", "data_name": "調剤指示名", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "issue_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "舌下", "can_calc": "0", "data_code": "mix_name", "data_name": "用法", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "mix_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "用法詳細", "can_calc": "0", "data_code": "usage_detail", "data_name": "用法詳細", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "usage_detail", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤１", "can_calc": "0", "data_code": "R", "data_name": "薬剤名称", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "r", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤名", "can_calc": "0", "data_code": "medicine_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "medicine_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "F5", "data_name": "用量", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "rst_value", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "0", "data_code": "F6", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "unit", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "舌下", "can_calc": "0", "data_code": "mix_name", "data_name": "用法", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "mix_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7", "can_calc": "1", "data_code": "day_count", "data_name": "日数・回数", "data_type": "decimal", "conv_table": [], "data_class": "処方（詳細）", "field_name": "day_count", "disp_format": "0", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "1", "data_code": "day_count_unit", "data_name": "調剤単位", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "day_count_unit", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "1", "data_code": "comment_info", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "comment_info", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 9]}', '処方：@facilityCd @ordPrescriptionNo  使用', '2021-11-09 13:42:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (222, 'with prescription_tbl as ( 
    SELECT a.* FROM ( SELECT
          (o ->> ''Rp'') AS rp
				,(o ->> ''sub_no'') as sub_no
        , (o ->> ''F1'') AS issue_name--調剤指示名
        , CASE WHEN (o ->> ''type'') IN (''3'', ''5'') THEN (o ->> ''F2'') || '' '' || (o ->> ''F3'') || '' '' || (o ->> ''F4'')
               ELSE (o ->> ''F2'') END AS usage_detail--用法詳細
        , op.ord_prescription_no AS ord_prescription_no 
            ,CASE WHEN (o ->> ''F5'') = ''0'' or (o ->> ''F5'') = '''' then '' '' else (o ->> ''F5'') end AS day_count
                , CASE WHEN (o ->> ''F5'') = ''0'' or (o ->> ''F5'') = '''' then '' '' else (o ->> ''F6'') end  AS day_count_unit
                ,ROW_NUMBER() OVER (PARTITION BY  (o ->> ''Rp''),(o ->> ''sub_no'')  ORDER BY  (o ->> ''Rp''),(o ->> ''sub_no'')  ASC) AS rn
    FROM
        ord_prescription AS op
        , jsonb_array_elements(prescription_detail) AS o 
    WHERE
        op.pat_id = @patId  
    AND op.is_del = ''0''
    AND o ->> ''type'' <> ''1'' 
    AND o ->> ''type'' <> ''6'' 
    AND o ->> ''type'' <> ''E'' 
    AND o ->> ''type'' <> ''0'' 
    AND op.ord_prescription_no = @ordPreNo ) a WHERE a.rn = 1 
), comont_info as (
	select 
	COALESCE(pt.rp, com1.rp) as rp,
	COALESCE(pt.sub_no, com1.sub_no) as sub_no,
	pt.issue_name,
	pt.usage_detail,
	pt.ord_prescription_no,
	pt.day_count,
	pt.day_count_unit,
	com1.issue_name as comment_info
	 from (select com.* from (SELECT
			(o ->> ''Rp'') AS rp
			,(o ->> ''sub_no'') as sub_no
			, (o ->> ''F1'') AS issue_name--調剤指示名
			, CASE WHEN (o ->> ''type'') IN (''3'', ''5'') THEN (o ->> ''F2'') || '' '' || (o ->> ''F3'') || '' '' || (o ->> ''F4'')
				ELSE (o ->> ''F2'') END AS usage_detail--用法詳細
			, op.ord_prescription_no AS ord_prescription_no 
			, CASE WHEN (o ->> ''F5'') = ''0'' or (o ->> ''F5'') = '''' then '' '' ELSE (o ->> ''F5'') END AS day_count
			, CASE WHEN (o ->> ''F5'') = ''0'' or (o ->> ''F5'') = '''' then '' '' ELSE (o ->> ''F6'') END AS day_count_unit
			, ROW_NUMBER() OVER (PARTITION BY  (o ->> ''Rp''),(o ->> ''sub_no'')   ORDER BY (o ->> ''Rp''),(o ->> ''sub_no'') ASC) AS rn 
		FROM
			ord_prescription AS op
			, jsonb_array_elements(prescription_detail) AS o 
		WHERE
			op.is_disp = ''1'' 
			AND op.is_del = ''0''
			AND o ->> ''type'' = ''6''
			AND op.pat_id = @patId 
			AND op.ord_prescription_no = @ordPreNo  )  com where com.rn = 1 	AND com.issue_name <>'''' ) com1  
			FULL OUTER JOIN prescription_tbl pt 
		on pt.rp = com1.rp and pt.sub_no = com1.sub_no
) 
select
    ord_pt.rp
        ,ord_pt.unchg
    , ord_pt.medicine_name
    , ord_pt.mix_name
    , pt.issue_name
    , pt.usage_detail 
    ,ord_pt.rst_value
    ,ord_pt.unit
    ,ord_pt.r
    ,pt.day_count
    ,pt.day_count_unit
    ,ord_pt.ord_prescription_no
		,pt.comment_info
from
    ( 
    SELECT
        json_idx
				,(o ->> ''sub_no'') as sub_no
        ,(o ->> ''Rp'') AS rp
                ,CASE WHEN ( o ->> ''unchg'' ) = ''x'' THEN ''2''
             ELSE ''1'' END AS unchg,--unchg  
        (o ->> ''F1'') AS medicine_name--薬剤名
        , (o ->> ''F2'') AS mix_name--用法
        , CASE WHEN (o ->> ''F5'') = ''0'' or (o ->> ''F5'') = '''' THEN '' '' ELSE (o ->> ''F5'') END AS rst_value--量
        ,( o ->> ''F6'' ) AS unit--単位
        ,( o ->> ''R'' ) AS r --薬剤処方箋用表示
        , op.ord_prescription_no AS ord_prescription_no 
    FROM
        ord_prescription AS op
        cross join lateral jsonb_array_elements(prescription_detail) with ordinality as tmp(o, json_idx)
    WHERE
        op.pat_id = @patId  
        AND op.is_del = ''0'' 
        AND o ->> ''type'' = ''1'' 
        AND op.ord_prescription_no = @ordPreNo 
    ) ord_pt
    left join comont_info pt 
        on pt.rp = ord_pt.rp and pt.sub_no = ord_pt.sub_no
    ORDER BY ord_pt.json_idx ASC', 2, '[{"preview": "×", "can_calc": "0", "data_code": "unchg", "data_name": "後発不可", "data_type": "string", "conv_table": [{"code": "1", "disp": "", "item": "可"}, {"code": "2", "disp": "×", "item": "不可"}], "data_class": "薬剤情報", "field_name": "unchg", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456", "can_calc": "0", "data_code": "Rp", "data_name": "RP番号", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "rp", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "調剤指示名", "can_calc": "0", "data_code": "issue_name", "data_name": "調剤指示名", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "issue_name", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "舌下", "can_calc": "0", "data_code": "mix_name", "data_name": "用法", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "mix_name", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "用法詳細", "can_calc": "0", "data_code": "usage_detail", "data_name": "用法詳細", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "usage_detail", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤１", "can_calc": "0", "data_code": "R", "data_name": "薬剤名称", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "r", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤名", "can_calc": "0", "data_code": "medicine_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "medicine_name", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "F5", "data_name": "用量", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "rst_value", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "0", "data_code": "F6", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "unit", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "舌下", "can_calc": "0", "data_code": "mix_name", "data_name": "用法", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "mix_name", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7", "can_calc": "1", "data_code": "day_count", "data_name": "日数・回数", "data_type": "decimal", "conv_table": [], "data_class": "処方（詳細）", "field_name": "day_count", "disp_format": "0", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "1", "data_code": "day_count_unit", "data_name": "調剤単位", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "day_count_unit", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "1", "data_code": "comment_info", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "処方（詳細）", "field_name": "comment_info", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 9]}', '処方(最新)：@facilityCd @patId  使用', '2024-04-29 11:07:34.164',CURRENT_TIMESTAMP, '[{"sql_cd": 223, "field_name": "ord_prescription_no", "replace_var": "@ordPreNo"}]');
