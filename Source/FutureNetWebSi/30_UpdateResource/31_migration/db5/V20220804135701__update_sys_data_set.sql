DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (-58);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-58, 'WITH bed_code_info AS (
  SELECT
    0 AS order_no 
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS bed_code_kbn 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''FJI_COM_INFO'' 
    AND info ->> ''key2'' = ''BED_CODE_CONV'' 
  UNION
  SELECT
    1 AS order_no 
    , '''' AS bed_code_kbn 
  ORDER BY order_no ASC LIMIT 1
)
SELECT
  CASE
    WHEN ((ord.ind_kur_cd IS NOT NULL AND ord.ind_kur_cd != 0) AND (ord.ind_bed_cd IS NULL OR ord.ind_bed_cd = 0)) THEN ''V9999999''
    ELSE 
      CASE 
        WHEN (SELECT bed_code_kbn FROM bed_code_info) = ''1'' 
          THEN mb.in_hospital_cd_1
        WHEN (SELECT bed_code_kbn from bed_code_info) = ''2'' 
          THEN mb.in_hospital_cd_2
        ELSE ''V9999999''
      END 
  END AS in_hospital_cd
FROM
  ord_main ord 
LEFT OUTER JOIN 
  mst_bed mb 
ON ord.ind_bed_cd = mb.bed_cd
WHERE
  ord.ord_no = @ordNo AND 
  ord.facility_cd = @facilityCd AND 
  ord.is_del = ''0''', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析予約：予約枠コード取得', '2022-03-07 15:48:46', CURRENT_TIMESTAMP, NULL);
