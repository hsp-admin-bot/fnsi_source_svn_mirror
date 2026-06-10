DELETE FROM ntss.sys_data_set WHERE sql_cd IN (-64);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-64, 'WITH document_no_info AS(
  SELECT
    ''0'' AS order_no 
    , CASE WHEN COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') = ''1'' 
      THEN ''01''
      ELSE ''00'' 
      END AS document_no 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info->>''key1'' = ''FJI_COM_INFO''
    AND info->>''key2'' = ''DOCUMENT_NO_SETTING''
  UNION
  SELECT
    ''1'' AS order_no 
    , ''00'' AS document_no 
  ORDER BY order_no ASC LIMIT 1
)
, ord_coop_no_info as (
  SELECT
    ctl_no,
		ord_no,
		facility_cd,
	  coop_ord_no
  FROM
	  ord_coop_no
	WHERE
	  pat_id = @patId
		AND
		ord_no = @ordNo
		AND 
		coop_cd = (SELECT coop_cd FROM sys_coop_journal WHERE ctl_no = @ctlNo)
	ORDER BY
	  up_date DESC
	LIMIT 1
)
SELECT
	ocn.coop_ord_no || (SELECT document_no FROM document_no_info) AS ord_no
FROM
  ord_main AS ord
	, ord_coop_no_info AS ocn
WHERE
  ord.ord_no = @ordNo
	AND ord.facility_cd = @facilityCd
	AND ord.ord_no = ocn.ord_no
	AND ord.facility_cd = ocn.facility_cd', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：文書番号(オーダ番号)取得', '2022-03-28 14:02:26.673', CURRENT_TIMESTAMP, NULL);
