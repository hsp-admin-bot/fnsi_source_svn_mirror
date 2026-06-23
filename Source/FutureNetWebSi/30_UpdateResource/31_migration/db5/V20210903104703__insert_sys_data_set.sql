DELETE FROM sys_data_set a WHERE a.sql_cd in (-2220,-2221);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2220, 'with ntss_db5_om_1 as (
	SELECT
		ntss_db5_om_1.ord_no AS ord_no
		,ntss_db5_om_1.pat_id
		,ntss_db5_om_1.treat_date AS treat_date
		,COUNT( ntss_db5_om_1.treat_date ) AS treat_date_count
	FROM
		ord_main ntss_db5_om_1
	WHERE 1=1
		AND ntss_db5_om_1.facility_cd = @facilityCd
	GROUP BY
		ntss_db5_om_1.ord_no,
		ntss_db5_om_1.pat_id,
		ntss_db5_om_1.treat_date
)
SELECT
	'''' AS hosppatid --患者ID
	,ntss_db5_om.pat_id AS patid
	,ntss_db5_om.treat_date AS dialysisdate --透析日
	,CASE
		WHEN ntss_db5_om_1.treat_date_count > 1
		THEN 1
		ELSE 0
	 END AS plural --同日複数回
	 ,row_number() over(ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
	 ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
	 ,ntss_db5_om_iic_json ->> ''content'' AS addition --指示簿指示
	 ,'''' AS indicatorcd --指示者
	 ,ntss_db5_om_iic_json ->> ''ind_user_id'' AS userid
	 ,CASE
		WHEN ntss_db5_om.treat_type = 0
		THEN ''1''
		ELSE ''0''
	 END AS opeindplan --予定作成区分
FROM
    ord_main ntss_db5_om
    INNER JOIN ntss_db5_om_1
    ON ntss_db5_om_1.ord_no = ntss_db5_om.ord_no
    cross join lateral json_array_elements(ntss_db5_om.ind_ind_comment_info ::json) ntss_db5_om_iic_json
WHERE ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
    AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
	AND ntss_db5_om.pat_id IS NOT NULL
	AND ntss_db5_om_1.treat_date IS NOT NULL;', 2, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2221, 'SELECT
	ntss_db6_mua.user_id AS userid
	,ntss_db6_mua.facility_cd AS facilitycd
	,ntss_db6_mua.disp_user_id AS indicatorcd --指示者
FROM
	mst_user_authentication ntss_db6_mua
WHERE ntss_db6_mua.facility_cd = @facilityCd;', 1, '[]', '1', '{"applications": [5]}', '{"classes": []}', '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["userid"]}', '2021-02-26 17:51:54.726', '2021-02-26 17:51:54.726', NULL);