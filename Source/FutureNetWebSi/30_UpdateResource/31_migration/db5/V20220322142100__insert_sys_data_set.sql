INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-63, 'WITH pdf_path_info AS (
SELECT
				0 AS order_no,
        COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS pdf_file_path
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
    WHERE
        facility_cd = @facilityCd 
        AND is_del = ''0'' 
        AND info ->> ''key1'' = ''REPORT_SEND'' 
        AND info ->> ''key2'' = ''URL_PREFIX'' 
)
,data_info AS (
  SELECT
    TO_CHAR((CASE WHEN ord.rst_fn_dialysis_no IS NOT NULL AND ord.rst_fn_dialysis_no > 0 THEN ord.rst_fn_dialysis_no ELSE ord.ord_no END), ''FM0999999999999999999'') AS ord_no
    , ord.rst_edition
    , coop.hosp_pat_id
  FROM
    ord_main AS ord, sys_coop_journal AS coop
  WHERE
    ord.ord_no = @ordNo
  AND coop.ctl_no = @ctlNo
  AND coop.ord_no = ord.ord_no
)
SELECT
  pdf_path_info.pdf_file_path|| LTRIM(data_info.hosp_pat_id) 
	|| ''/''
  || LTRIM(data_info.hosp_pat_id) 
  || (CASE WHEN CHAR_LENGTH(ord_no::TEXT) > 12 THEN RIGHT(ord_no::TEXT,12) ELSE RPAD(ord_no::TEXT, 12, ''0'') END)
  || LPAD(rst_edition::TEXT, 4, ''0'') 
  || ''.pdf'' AS pdf_file
FROM data_info,pdf_path_info
WHERE pdf_path_info.order_no = 0', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）PDFファイルパスの取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
