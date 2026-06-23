DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2503,-2051)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2503, 'with union_tmp as
(
	SELECT
     ntss_db5_om.pat_id AS patid
    , ntss_db5_om.treat_date AS dialysisdate    --透析日
    , ntss_db5_om.ord_no AS dialysisno          --透析番号
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , ntss_db5_mst_e.in_hospital_cd_1 AS equipcd --医療材料コード(院内コード1)
    , ntss_db5_mst_e.in_hospital_cd_2 AS equipcd2 --医療材料コード(院内コード2)
    , ntss_db5_om_rqi_json ->> ''name'' AS equipname --医療材料名
    , ntss_db5_om_rqi_json ->> ''class_name'' AS equipclassname --医療材料分類名
    , CASE ntss_db5_om_rqi_json ->> ''needle_type''
        WHEN ''1'' THEN ntss_db5_om_rqi_json ->> ''needle_type''
        WHEN ''2'' THEN ntss_db5_om_rqi_json ->> ''needle_type''
        WHEN ''3'' THEN ntss_db5_om_rqi_json ->> ''needle_type''
        ELSE ''0''
      END AS punctureclass --穿刺針区分
    , ntss_db5_om_rqi_json ->> ''amount'' AS amount --数量
    , ntss_db5_mst_e.unit AS unit               --単位
    , ntss_db5_om_rqi_json ->> ''cd'' AS cd--コード用
    , ntss_db5_om.facility_cd  AS facilitycd
FROM
    ord_main ntss_db5_om
    CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_equip_info ::json) ntss_db5_om_rqi_json
    LEFT JOIN mst_equipment ntss_db5_mst_e
        ON (ntss_db5_mst_e.equipment_cd)::text = ntss_db5_om_rqi_json ->> ''cd''
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_om.rst_dialysis_state IN (''1'',''2'',''3'',''4'',''5'')
    AND ntss_db5_om.pat_id IS NOT NULL
    AND ntss_db5_om.treat_date IS NOT NULL
UNION ALL
    SELECT
         ntss_db5_om.pat_id AS patid
        , ntss_db5_om.treat_date AS dialysisdate --透析日
        , ntss_db5_om.ord_no AS dialysisno --透析番号
        , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
        , ntss_db5_mst_e.in_hospital_cd_1 AS equipcd --医療材料コード(院内コード1)
        , ntss_db5_mst_e.in_hospital_cd_2 AS equipcd2 --医療材料コード(院内コード2)
	    , rst_cond_info_json.value::JSON ->> ''value_name_1'' AS equipname --医療材料名
	    , ntss_db5_mst_c.class_name AS equipclassname --医療材料分類名
	    , CASE rst_cond_info_json.key
	        WHEN ''9'' THEN ''1''
	        WHEN ''10'' THEN ''2''
	        WHEN ''11'' THEN ''3''
	        ELSE ''0''
	      END AS punctureclass --穿刺針区分
	    , ''1'' AS amount --数量
	    , rst_cond_info_json.value::JSON ->> ''unit'' AS unit               --単位
    	, rst_cond_info_json.value::JSON ->> ''value'' AS cd--コード用
    	, ntss_db5_om.facility_cd  AS facilitycd
    FROM
        ord_main ntss_db5_om
        CROSS JOIN lateral json_each_text(ntss_db5_om.rst_cond_info::JSON) rst_cond_info_json
	    LEFT JOIN mst_equipment ntss_db5_mst_e
	        ON (ntss_db5_mst_e.equipment_cd)::text = rst_cond_info_json.value::JSON ->> ''value''
	   	LEFT JOIN mst_equipment_class ntss_db5_mst_c
	        ON ntss_db5_mst_c.class_cd = ntss_db5_mst_e.class_cd
    WHERE
        rst_cond_info_json.key IN(''6'',''7'',''8'',''9'',''10'',''11'',''12'',''13'')
        AND ntss_db5_om.is_del = ''0''
        AND ntss_db5_om.facility_cd = @facilityCd
        AND ntss_db5_om.rst_dialysis_state IN (''1'',''2'',''3'',''4'',''5'')
        AND ntss_db5_om.pat_id IS NOT NULL
        AND ntss_db5_om.treat_date IS NOT null)
SELECT
	'''' AS hosppatid                             --患者ID
	,union_tmp.patid
	, union_tmp.dialysisdate
	, union_tmp.dialysisno
	, (row_number() over (PARTITION BY union_tmp.dialysisno ORDER BY ntss_db5_mst_sel.sortkey ASC, (union_tmp.cd)::integer))::text AS ctlno --項目番号
	, union_tmp.update
	, union_tmp.equipcd
	, union_tmp.equipcd2
	, union_tmp.equipname
	, union_tmp.equipclassname
	, union_tmp.punctureclass
	, union_tmp.amount
	, union_tmp.unit
	, '''' as comments
	from
		union_tmp
	    LEFT JOIN mst_equipment ntss_db5_mst_e
	        ON (ntss_db5_mst_e.equipment_cd)::text = union_tmp.cd
	    LEFT JOIN (
	        SELECT
	          facility_cd
	          , ntss_db5_mst_sel_json
	          , ROW_NUMBER() OVER() AS sortkey
	        FROM
	        	mst_selector ms
	        CROSS JOIN LATERAL json_array_elements(ms.order_settings ::json -> ''items'') ntss_db5_mst_sel_json
	        WHERE ms.master_physical_name = ''mst_equipment'') AS ntss_db5_mst_sel
	        ON (ntss_db5_mst_e.equipment_cd)::text = ntss_db5_mst_sel.ntss_db5_mst_sel_json ->> ''code''
	        AND union_tmp.facilitycd = ntss_db5_mst_sel.facility_cd;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2051, 'SELECT
	hosp_pat_id AS hosppatid,
	pat_id AS patid
FROM
	pat_personal_main 
WHERE facility_cd = @facilityCd;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
