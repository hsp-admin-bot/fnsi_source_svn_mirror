DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2200,-2221,-2051)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2200, '-- 【SQL_CD=-2200】6.3対応
WITH 
    ord_main_head as
    (
        select
            ord_main.ord_no 
           ,ord_main.pat_id 
           ,ord_main.treat_date 
           ,ord_main.treat_week 
           ,ord_main.facility_cd 
           ,ord_main.ind_cond_info 
           ,ord_main.ind_equip_info 
           ,ord_main.ind_treatment_cd 
           ,ord_main.ind_treat_start_time 
           ,ord_main.up_date 
        from
            ord_main
        WHERE
            ord_main.is_del = ''0''
            AND ord_main.facility_cd = @facilityCd
            AND ord_main.pat_id IS NOT NULL
            AND @fromDate <= treat_date AND treat_date < @toDate
    ),
    mst_treatment_disp_order_tbl AS 
    (
        SELECT
            one_json ->> ''code'' AS treatment_cd
            , json_idx AS treatment_cd_order
        FROM
            mst_selector
            CROSS JOIN lateral jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(one_json, json_idx)
        WHERE
            facility_cd = @facilityCd
            AND master_physical_name = ''mst_treatment''
    ),
    ntss_db5_om_1 AS 
    (
        SELECT
            ntss_db5_om_1.ord_no
            , ROW_NUMBER() OVER (PARTITION BY ntss_db5_om_1.pat_id, ntss_db5_om_1.treat_date ORDER BY ntss_db5_om_1.ind_treat_start_time ASC, mst_treatment_disp_order_tbl.treatment_cd_order ASC) AS plural
        FROM
            ord_main_head ntss_db5_om_1
            LEFT JOIN mst_treatment_disp_order_tbl
            ON ntss_db5_om_1.ind_treatment_cd ::text = mst_treatment_disp_order_tbl.treatment_cd
    ),
    ntss_db5_mst_e AS 
    ( 
        select
            ntss_db5_mst_e.equipment_cd,
            ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
            ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
            ntss_db5_mst_e.up_date AS up_date,
            ntss_db5_mst_e.equipment_name AS equipment_name,
            ntss_db5_mst_e.unit AS unit, 
            ntss_db5_mst_e.class_cd AS class_cd
        FROM 
            mst_equipment ntss_db5_mst_e -- 医療材料マスタ 
        WHERE 
            ntss_db5_mst_e.facility_cd = @facilityCd 
    ),
    mst_equipment_class AS 
    ( 
        select
            mst_equipment_class.class_name as class_name,
            mst_equipment_class.class_cd
        FROM 
            mst_equipment_class -- 医療材料分類マスタ 
        WHERE
            mst_equipment_class.facility_cd = @facilityCd 
    ),
    ntss_db5_om_iei_json AS 
    (
        SELECT
            ntss_db5_om_iei_json ->> ''amount'' AS amount,
            ntss_db5_om_iei_json ->> ''class_name'' AS class_name,
            ntss_db5_om_iei_json ->> ''name'' AS NAME,
            ntss_db5_om_iei_json ->> ''cd'' AS cd,
            ntss_db5_om_iei_json ->> ''class_cd'' AS class_cd,
            ntss_db5_om_iei_json ->> ''needle_type'' AS needle_type,
            ntss_db5_om_iei_json ->> ''ind_user_id'' AS ind_user_id,
            om.ord_no AS ord_no
        FROM
            ord_main_head om
            CROSS JOIN LATERAL json_array_elements ( om.ind_equip_info :: JSON ) ntss_db5_om_iei_json
    ),
    ntss_db5_om_ici_json as
    (
		select
			ntss_db5_om_ici_json.key AS key
		    , ntss_db5_om_ici_json.value::json ->> ''value'' AS value
		    , ntss_db5_om_ici_json.value::json ->> ''ind_user_id'' AS ind_user_id
		    , om.ord_no AS ord_no
		FROM
		    ord_main_head om
		    CROSS JOIN lateral json_each_text(om.ind_cond_info::JSON) ntss_db5_om_ici_json
		WHERE 
			ntss_db5_om_ici_json.key IN(''6'',''7'',''8'',''9'',''10'',''11'',''12'',''13'')
	),
    ntss_db5_mst_list AS 
    (
        SELECT
            ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
            ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
            mst_equipment_class.class_name AS class_name, -- 医療材料分類マスタから取得
            ntss_db5_mst_e.equipment_name AS equipname,
            om.needle_type AS puncture_class,
            om.amount AS amount,
            ntss_db5_mst_e.unit AS unit,
            '''' AS comments,
            om.ord_no AS ord_no,
            ntss_db5_mst_e.up_date AS up_date,
            ntss_db5_mst_e.equipment_cd,
            om.ind_user_id,
            om.cd
        FROM
            ntss_db5_om_iei_json om
            LEFT JOIN ntss_db5_mst_e ON om.cd = ntss_db5_mst_e.equipment_cd::TEXT
            LEFT JOIN mst_equipment_class ON om.class_cd = mst_equipment_class.class_cd::TEXT
    ), 
    ntss_db5_mst_list_ici AS 
    (
        SELECT
            ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
            ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
            mst_equipment_class.class_name AS class_name, -- 医療材料分類マスタから取得
            ntss_db5_mst_e.equipment_name AS equipname,
            ntss_db5_mst_e.unit AS unit,
            '''' AS comments,
            om.ord_no AS ord_no,
            ntss_db5_mst_e.up_date AS up_date,
            ntss_db5_mst_e.equipment_cd,
            om.ind_user_id,
            om.value,
            om.key
        FROM
            ntss_db5_om_ici_json om
            LEFT JOIN ntss_db5_mst_e ON om.value = ntss_db5_mst_e.equipment_cd::TEXT
            LEFT JOIN mst_equipment_class ON ntss_db5_mst_e.class_cd = mst_equipment_class.class_cd
    ), 
    ntss_db5_ptp AS 
    (
        SELECT
            ntss_db5_ptp.pat_id, 
            ntss_db5_ptp.treat_week, 
            ntss_db5_ptp.ind_treatment_cd,
            ''1'' AS flg
        FROM
            pat_treatment_pattern ntss_db5_ptp
        WHERE
            ntss_db5_ptp.facility_cd = @facilityCd
    ),
    ntss_db5_mst_sel AS
    (
        SELECT
            facility_cd
            , ntss_db5_mst_sel_json ->> ''code'' AS code
            , ROW_NUMBER() OVER() AS sortkey
        FROM
            mst_selector ms
        CROSS JOIN LATERAL json_array_elements(ms.order_settings ::json -> ''items'') ntss_db5_mst_sel_json
        WHERE ms.master_physical_name = ''mst_equipment''
        AND ms.facility_cd = @facilityCd 
    )
    ,union_tmp AS
    (
	SELECT
	    ord_main_head.pat_id AS patid
	    ,ord_main_head.treat_date AS dialysisdate -- 透析日
	    ,to_char( ord_main_head.up_date, ''YYYY-MM-DD hh24:mi:ss'' ) AS update -- 更新日時
	    ,ntss_db5_mst_list.in_hospital_cd_1 AS equipcd -- 医療材料コード(院内コード1)
	    ,ntss_db5_mst_list.in_hospital_cd_2 AS equipcd2 -- 医療材料コード(院内コード2)
	    ,ntss_db5_mst_list.class_name AS equipclassname -- 医療材料分類名
	    ,ntss_db5_mst_list.equipname AS equipname -- 医療材料名
	    , CASE ntss_db5_mst_list.puncture_class
	        WHEN ''1'' THEN ntss_db5_mst_list.puncture_class
	        WHEN ''2'' THEN ntss_db5_mst_list.puncture_class
	        WHEN ''3'' THEN ntss_db5_mst_list.puncture_class
	        ELSE ''0''
	        END AS punctureclass -- 穿刺針区分
	    ,ntss_db5_mst_list.amount AS amount -- 数量
	    ,ntss_db5_mst_list.unit AS unit -- 単位
	    ,ntss_db5_mst_list.ind_user_id AS indicatorcd -- 指示者
	    ,  CASE
	        WHEN ntss_db5_ptp.flg = ''1''
	            THEN ''0''
	        ELSE ''1''
	        END AS opeindplan    -- 予定作成区分
	    ,ord_main_head.ord_no AS dialysisno --透析番号
	    ,ntss_db5_mst_list.cd AS cd
	FROM
	    ord_main_head
	    LEFT JOIN ntss_db5_mst_list ON ntss_db5_mst_list.ord_no = ord_main_head.ord_no
	    LEFT JOIN ntss_db5_ptp
	        ON ntss_db5_ptp.pat_id = ord_main_head.pat_id
	        AND ntss_db5_ptp.treat_week = ord_main_head.treat_week
	        AND ntss_db5_ptp.ind_treatment_cd = ord_main_head.ind_treatment_cd
	UNION ALL
		SELECT
	    ord_main_head.pat_id AS patid
	    ,ord_main_head.treat_date AS dialysisdate -- 透析日
	    ,to_char( ord_main_head.up_date, ''YYYY-MM-DD hh24:mi:ss'' ) AS update -- 更新日時
	    ,ntss_db5_mst_list_ici.in_hospital_cd_1 AS equipcd -- 医療材料コード(院内コード1)
	    ,ntss_db5_mst_list_ici.in_hospital_cd_2 AS equipcd2 -- 医療材料コード(院内コード2)
	    ,ntss_db5_mst_list_ici.class_name AS equipclassname -- 医療材料分類名
	    ,ntss_db5_mst_list_ici.equipname AS equipname -- 医療材料名
	    , CASE ntss_db5_mst_list_ici.key
	        WHEN ''9'' THEN ''1''
	        WHEN ''10'' THEN ''2''
	        WHEN ''11'' THEN ''3''
	        ELSE ''0''
	        END AS punctureclass -- 穿刺針区分
	    ,''1'' AS amount -- 数量
	    ,ntss_db5_mst_list_ici.unit AS unit -- 単位
	    ,ntss_db5_mst_list_ici.ind_user_id AS indicatorcd -- 指示者
	    ,  CASE
	        WHEN ntss_db5_ptp.flg = ''1''
	            THEN ''0''
	        ELSE ''1''
	        END AS opeindplan    -- 予定作成区分
	    ,ord_main_head.ord_no AS dialysisno --透析番号
	    ,ntss_db5_mst_list_ici.value AS cd
	FROM
	    ord_main_head
	    LEFT JOIN ntss_db5_mst_list_ici ON ntss_db5_mst_list_ici.ord_no = ord_main_head.ord_no
	    LEFT JOIN ntss_db5_ptp
	        ON ntss_db5_ptp.pat_id = ord_main_head.pat_id
	        AND ntss_db5_ptp.treat_week = ord_main_head.treat_week
	        AND ntss_db5_ptp.ind_treatment_cd = ord_main_head.ind_treatment_cd
	        )
 	SELECT
 		'''' AS hosppatid -- 患者ID(連携用)
 		,union_tmp.patid
 		,union_tmp.dialysisdate -- 透析日
 		,ntss_db5_om_1.plural AS plural -- 同日複数回
	    ,(row_number() over (PARTITION BY union_tmp.dialysisno ORDER BY ntss_db5_mst_sel.sortkey ASC, (union_tmp.cd)::integer))::text AS ctlno -- 項目番号
 		,union_tmp.update -- 更新日時
 		,union_tmp.equipcd -- 医療材料コード(院内コード1)
 		,union_tmp.equipcd2 -- 医療材料コード(院内コード2)
 		,union_tmp.equipclassname -- 医療材料分類名
 		,union_tmp.equipname -- 医療材料名
 		,union_tmp.punctureclass -- 穿刺針区分
 		,union_tmp.amount-- 数量
 		,union_tmp.unit -- 単位
 		,'''' AS comments -- コメント
 		,union_tmp.indicatorcd --指示者コード(連携用)
 		,union_tmp.opeindplan-- 予定作成区分
 		,union_tmp.dialysisno --透析番号
 		,union_tmp.indicatorcd AS userid -- 指示者
	FROM
	 	union_tmp
		LEFT JOIN ntss_db5_mst_sel ON union_tmp.cd ::TEXT = ntss_db5_mst_sel.code
	    LEFT JOIN ntss_db5_om_1 ON ntss_db5_om_1.ord_no = union_tmp.dialysisno
;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2221, 'SELECT
	cast(user_id as varchar) AS userid
	,facility_cd AS facilitycd
	,disp_user_id AS indicatorcd --指示者
FROM
	mst_user_authentication
WHERE facility_cd = @facilityCd;', 1, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2051, 'SELECT
	hosp_pat_id AS hosppatid,
	pat_id AS patid
FROM
	pat_personal_main 
WHERE facility_cd = @facilityCd;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
