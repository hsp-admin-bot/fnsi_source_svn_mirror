DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (138, 201, 221, 222);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (138, 'WITH prescription_data AS (
	SELECT
		json_idx,
		CASE WHEN ( o ->> ''Rp'' ) = '''' THEN NULL ELSE ( o ->> ''Rp'' ) END AS rp,--RP番号
		CASE WHEN ( o ->> ''unchg'' ) = ''x'' THEN ''2'' ELSE ''1'' END AS unchg,--後発不可
		CASE WHEN ( o ->> ''pat_req'' ) = ''x'' THEN ''2'' ELSE ''1'' END AS pat_req,--患者希望
		( o ->> ''type'' ) AS TYPE,
		( o ->> ''F1'' ) AS f1,--F1
		( o ->> ''F2'' ) AS f2,--F2
		( o ->> ''F3'' ) AS f3,--F3
		( o ->> ''F4'' ) AS f4,--F4
		( o ->> ''F5'' ) AS f5,--量
		( o ->> ''F6'' ) AS f6,--単位
		( o ->> ''R'' ) AS r,--薬剤名称
		op.ord_prescription_no AS ord_prescription_no --処方オーダー番号
	FROM
		ord_prescription AS op
		cross join lateral jsonb_array_elements(prescription_detail) with ordinality as tmp(o, json_idx) 
	WHERE
		op.is_disp = ''1'' 
		AND op.is_del = ''0'' 
		AND o ->> ''type'' <> ''0''
		AND op.facility_cd = @facilityCd
		AND op.ord_prescription_no = @ordPrescriptionNo
  ORDER BY json_idx ASC
)
SELECT
	CASE WHEN rp = LAG(rp) OVER() THEN NULL ELSE rp END as rp,
	unchg,
	pat_req,
	TYPE,
	f1,
	f2,
	f3,
	f4,
	f5,
	f6,
	r,
	ord_prescription_no
FROM prescription_data;', 2, '[{"preview": "123456", "can_calc": "0", "data_code": "Rp", "data_name": "RP番号", "data_type": "string", "conv_table": [], "data_class": "処方箋", "field_name": "rp", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤１", "can_calc": "0", "data_code": "R", "data_name": "処方箋用表示", "data_type": "string", "conv_table": [], "data_class": "処方箋", "field_name": "r", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "内服", "can_calc": "0", "data_code": "type", "data_name": "タグ", "data_type": "string", "conv_table": [{"code": "1", "disp": "薬剤", "item": "薬剤"}, {"code": "2", "disp": "内服", "item": "内服"}, {"code": "3", "disp": "外用", "item": "外用"}, {"code": "4", "disp": "頓服内服", "item": "頓服内服"}, {"code": "5", "disp": "頓服外用", "item": "頓服外用"}, {"code": "6", "disp": "コメント", "item": "コメント"}, {"code": "E", "disp": "最終行", "item": "最終行"}], "data_class": "処方箋", "field_name": "type", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "✓", "can_calc": "0", "data_code": "unchg", "data_name": "後発不可", "data_type": "string", "conv_table": [{"code": "1", "disp": "", "item": "可"}, {"code": "2", "disp": "✓", "item": "不可"}], "data_class": "処方箋", "field_name": "unchg", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "✓", "can_calc": "0", "data_code": "pat_req", "data_name": "患者希望", "data_type": "string", "conv_table": [{"code": "1", "disp": "", "item": "希望しない"}, {"code": "2", "disp": "✓", "item": "希望する"}], "data_class": "処方箋", "field_name": "pat_req", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤名", "can_calc": "0", "data_code": "F1", "data_name": "薬剤名/用法", "data_type": "string", "conv_table": [], "data_class": "処方箋", "field_name": "f1", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "調剤指示名", "can_calc": "0", "data_code": "F2", "data_name": "調剤指示名/用法詳細", "data_type": "string", "conv_table": [], "data_class": "処方箋", "field_name": "f2", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "舌下", "can_calc": "0", "data_code": "F3", "data_name": "部位", "data_type": "string", "conv_table": [], "data_class": "処方箋", "field_name": "f3", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "F4", "data_name": "左右", "data_type": "string", "conv_table": [], "data_class": "処方箋", "field_name": "f4", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "F5", "data_name": "用量", "data_type": "string", "conv_table": [], "data_class": "処方箋", "field_name": "f5", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "0", "data_code": "F6", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "処方箋", "field_name": "f6", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 9]}', '処方：@facilityCd @ordPrescriptionNo 使用', '2021-02-16 13:42:00', CURRENT_TIMESTAMP, NULL);
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
	, ord_pt.pat_req
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
		, CASE WHEN ( o ->> ''unchg'' ) = ''x'' THEN ''2'' ELSE ''1'' END AS unchg--後発不可
		, CASE WHEN ( o ->> ''pat_req'' ) = ''x'' THEN ''2'' ELSE ''1'' END AS pat_req--患者希望
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
', 2, '[{"preview": "✓", "can_calc": "0", "data_code": "unchg", "data_name": "後発不可", "data_type": "string", "conv_table": [{"code": "1", "disp": "", "item": "可"}, {"code": "2", "disp": "✓", "item": "不可"}], "data_class": "薬剤情報", "field_name": "unchg", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "✓", "can_calc": "0", "data_code": "pat_req", "data_name": "患者希望", "data_type": "string", "conv_table": [{"code": "1", "disp": "", "item": "希望しない"}, {"code": "2", "disp": "✓", "item": "希望する"}], "data_class": "薬剤情報", "field_name": "pat_req", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456", "can_calc": "0", "data_code": "Rp", "data_name": "RP番号", "data_type": "string", "conv_table": [], "data_class": "処方(詳細)", "field_name": "rp", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "調剤指示名", "can_calc": "0", "data_code": "issue_name", "data_name": "調剤指示名", "data_type": "string", "conv_table": [], "data_class": "処方(詳細)", "field_name": "issue_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "舌下", "can_calc": "0", "data_code": "mix_name", "data_name": "用法", "data_type": "string", "conv_table": [], "data_class": "処方(詳細)", "field_name": "mix_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "用法詳細", "can_calc": "0", "data_code": "usage_detail", "data_name": "用法詳細", "data_type": "string", "conv_table": [], "data_class": "処方(詳細)", "field_name": "usage_detail", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤１", "can_calc": "0", "data_code": "R", "data_name": "薬剤名称", "data_type": "string", "conv_table": [], "data_class": "処方(詳細)", "field_name": "r", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤名", "can_calc": "0", "data_code": "medicine_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "medicine_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "F5", "data_name": "用量", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "rst_value", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "0", "data_code": "F6", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "unit", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "舌下", "can_calc": "0", "data_code": "mix_name", "data_name": "用法", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "mix_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7", "can_calc": "1", "data_code": "day_count", "data_name": "日数・回数", "data_type": "decimal", "conv_table": [], "data_class": "処方(詳細)", "field_name": "day_count", "disp_format": "0", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "1", "data_code": "day_count_unit", "data_name": "調剤単位", "data_type": "string", "conv_table": [], "data_class": "処方(詳細)", "field_name": "day_count_unit", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "1", "data_code": "comment_info", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "処方(詳細)", "field_name": "comment_info", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 9]}', '処方：@facilityCd @ordPrescriptionNo  使用', '2021-11-09 13:42:00', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (221, 'WITH prescription_data AS (
	SELECT
        json_idx,
        CASE WHEN ( o ->> ''Rp'' ) = '''' THEN NULL
             ELSE ( o ->> ''Rp'' ) END AS rp,--RP番号
        CASE WHEN ( o ->> ''unchg'' ) = ''x'' THEN ''2''
             ELSE ''1'' END AS unchg,--unchg
        CASE WHEN ( o ->> ''pat_req'' ) = ''x'' THEN ''2''
             ELSE ''1'' END AS pat_req,--pat_req
        ( o ->> ''type'' ) AS TYPE,--type
        ( o ->> ''F1'' ) AS f1,--F1
        ( o ->> ''F2'' ) AS f2,--F2
        ( o ->> ''F3'' ) AS f3,--F3
        ( o ->> ''F4'' ) AS f4,--F4
        ( o ->> ''F5'' ) AS f5,--量
        ( o ->> ''F6'' ) AS f6,--単位
        ( o ->> ''R'' ) AS r,--薬剤名称
        op.ord_prescription_no AS ord_prescription_no --処方オーダー番号
    FROM
        ord_prescription AS op
        cross join lateral jsonb_array_elements(prescription_detail) with ordinality as tmp(o, json_idx) 
    WHERE
	op.is_del = ''0'' 
	AND op.is_disp = ''1''
	AND o ->> ''type'' <> ''0'' 
	AND op.ord_prescription_no = @ordPreNo
    ORDER BY ord_prescription_no, json_idx ASC
)
SELECT
	CASE WHEN rp = LAG(rp) OVER() THEN NULL
	   ELSE rp END as rp,
	unchg,
	pat_req,
	TYPE,
	f1,
	f2,
	f3,
	f4,
	f5,
	f6,
	r,
	ord_prescription_no
FROM prescription_data;', 2, '[{"preview": "123456", "can_calc": "0", "data_code": "Rp", "data_name": "RP番号", "data_type": "string", "conv_table": [], "data_class": "処方箋", "field_name": "rp", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤１", "can_calc": "0", "data_code": "R", "data_name": "処方箋用表示", "data_type": "string", "conv_table": [], "data_class": "処方箋", "field_name": "r", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "内服", "can_calc": "0", "data_code": "type", "data_name": "タグ", "data_type": "string", "conv_table": [{"code": "1", "disp": "薬剤", "item": "薬剤"}, {"code": "2", "disp": "内服", "item": "内服"}, {"code": "3", "disp": "外用", "item": "外用"}, {"code": "4", "disp": "頓服内服", "item": "頓服内服"}, {"code": "5", "disp": "頓服外用", "item": "頓服外用"}, {"code": "6", "disp": "コメント", "item": "コメント"}, {"code": "E", "disp": "最終行", "item": "最終行"}], "data_class": "処方箋", "field_name": "type", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "✓", "can_calc": "0", "data_code": "unchg", "data_name": "後発不可", "data_type": "string", "conv_table": [{"code": "1", "disp": "", "item": "可"}, {"code": "2", "disp": "✓", "item": "不可"}], "data_class": "処方箋", "field_name": "unchg", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "✓", "can_calc": "0", "data_code": "pat_req", "data_name": "患者希望", "data_type": "string", "conv_table": [{"code": "1", "disp": "", "item": "希望しない"}, {"code": "2", "disp": "✓", "item": "希望する"}], "data_class": "処方箋", "field_name": "pat_req", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤名", "can_calc": "0", "data_code": "F1", "data_name": "薬剤名/用法", "data_type": "string", "conv_table": [], "data_class": "処方箋", "field_name": "f1", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "調剤指示名", "can_calc": "0", "data_code": "F2", "data_name": "調剤指示名/用法詳細", "data_type": "string", "conv_table": [], "data_class": "処方箋", "field_name": "f2", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "舌下", "can_calc": "0", "data_code": "F3", "data_name": "部位", "data_type": "string", "conv_table": [], "data_class": "処方箋", "field_name": "f3", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "左", "can_calc": "0", "data_code": "F4", "data_name": "左右", "data_type": "string", "conv_table": [], "data_class": "処方箋", "field_name": "f4", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "F5", "data_name": "用量", "data_type": "string", "conv_table": [], "data_class": "処方箋", "field_name": "f5", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "0", "data_code": "F6", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "処方箋", "field_name": "f6", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 9]}', '処方(最新)：@ordPreNo 使用', '2024-05-08 22:46:39.994', CURRENT_TIMESTAMP, '[{"sql_cd": 223, "field_name": "ord_prescription_no", "replace_var": "@ordPreNo"}]');
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
                ,ROW_NUMBER() OVER (PARTITION BY op.ord_prescription_no, (o ->> ''Rp''),(o ->> ''sub_no'')  ORDER BY  (o ->> ''Rp''),(o ->> ''sub_no'')  ASC) AS rn
    FROM
        ord_prescription AS op
        , jsonb_array_elements(prescription_detail) AS o 
    WHERE
    op.is_del = ''0''
    AND op.is_disp = ''1''
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
    , ord_pt.unchg
    , ord_pt.pat_req
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
             ELSE ''1'' END AS unchg--後発不可
        ,CASE WHEN ( o ->> ''pat_req'' ) = ''x'' THEN ''2''
             ELSE ''1'' END AS pat_req--患者希望 
        ,(o ->> ''F1'') AS medicine_name--薬剤名
        , (o ->> ''F2'') AS mix_name--用法
        , CASE WHEN (o ->> ''F5'') = ''0'' or (o ->> ''F5'') = '''' THEN '' '' ELSE (o ->> ''F5'') END AS rst_value--量
        ,( o ->> ''F6'' ) AS unit--単位
        ,( o ->> ''R'' ) AS r --薬剤処方箋用表示
        , op.ord_prescription_no AS ord_prescription_no 
    FROM
        ord_prescription AS op
        cross join lateral jsonb_array_elements(prescription_detail) with ordinality as tmp(o, json_idx)
    WHERE
        op.is_disp  = ''1'' 
        AND op.is_del = ''0''
        AND o ->> ''type'' = ''1'' 
        AND op.ord_prescription_no = @ordPreNo
    ) ord_pt
    left join comont_info pt 
        on pt.rp = ord_pt.rp
		AND pt.ord_prescription_no = ord_pt.ord_prescription_no
    ORDER BY ord_prescription_no, ord_pt.json_idx ASC
', 2, '[{"preview": "✓", "can_calc": "0", "data_code": "unchg", "data_name": "後発不可", "data_type": "string", "conv_table": [{"code": "1", "disp": "", "item": "可"}, {"code": "2", "disp": "✓", "item": "不可"}], "data_class": "薬剤情報", "field_name": "unchg", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "✓", "can_calc": "0", "data_code": "pat_req", "data_name": "患者希望", "data_type": "string", "conv_table": [{"code": "1", "disp": "", "item": "希望しない"}, {"code": "2", "disp": "✓", "item": "希望する"}], "data_class": "薬剤情報", "field_name": "pat_req", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456", "can_calc": "0", "data_code": "Rp", "data_name": "RP番号", "data_type": "string", "conv_table": [], "data_class": "処方(詳細)", "field_name": "rp", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "調剤指示名", "can_calc": "0", "data_code": "issue_name", "data_name": "調剤指示名", "data_type": "string", "conv_table": [], "data_class": "処方(詳細)", "field_name": "issue_name", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "舌下", "can_calc": "0", "data_code": "mix_name", "data_name": "用法", "data_type": "string", "conv_table": [], "data_class": "処方(詳細)", "field_name": "mix_name", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "用法詳細", "can_calc": "0", "data_code": "usage_detail", "data_name": "用法詳細", "data_type": "string", "conv_table": [], "data_class": "処方(詳細)", "field_name": "usage_detail", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤１", "can_calc": "0", "data_code": "R", "data_name": "薬剤名称", "data_type": "string", "conv_table": [], "data_class": "処方(詳細)", "field_name": "r", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "薬剤名", "can_calc": "0", "data_code": "medicine_name", "data_name": "薬剤名", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "medicine_name", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1", "can_calc": "0", "data_code": "F5", "data_name": "用量", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "rst_value", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "0", "data_code": "F6", "data_name": "単位", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "unit", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "舌下", "can_calc": "0", "data_code": "mix_name", "data_name": "用法", "data_type": "string", "conv_table": [], "data_class": "薬剤情報", "field_name": "mix_name", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "7", "can_calc": "1", "data_code": "day_count", "data_name": "日数・回数", "data_type": "decimal", "conv_table": [], "data_class": "処方(詳細)", "field_name": "day_count", "disp_format": "0", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "1", "data_code": "day_count_unit", "data_name": "調剤単位", "data_type": "string", "conv_table": [], "data_class": "処方(詳細)", "field_name": "day_count_unit", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日分", "can_calc": "1", "data_code": "comment_info", "data_name": "コメント", "data_type": "string", "conv_table": [], "data_class": "処方(詳細)", "field_name": "comment_info", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 9]}', '処方(最新)：@ordPreNo  使用', '2024-04-29 11:07:34.164', CURRENT_TIMESTAMP, '[{"sql_cd": 223, "field_name": "ord_prescription_no", "replace_var": "@ordPreNo"}]');
