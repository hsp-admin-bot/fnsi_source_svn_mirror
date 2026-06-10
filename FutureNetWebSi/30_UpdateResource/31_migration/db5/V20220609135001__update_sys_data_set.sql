DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (-107);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-107, 'with IN_HOSPITAL as (
SELECT
      COALESCE( 
        NULLIF(info ->> ''value'', '''')
        , info ->> ''default_v''
      ) AS staff_cd
    FROM
      mst_coop_ini AS ini 
      CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
    WHERE
      facility_cd = @facilityCd 
      AND is_del = ''0'' 
      AND info ->> ''key1'' = ''TREATMENT'' 
      AND info ->> ''key2'' = ''IN_HOSPITAL_CD'' limit 1
)
SELECT
CASE WHEN IN_HOSPITAL.staff_cd = ''1'' THEN 
  COALESCE(NULLIF(mtt.in_hospital_cd_a1, ''''), ''-'')
	ELSE CASE WHEN IN_HOSPITAL.staff_cd = ''2'' THEN
  COALESCE(NULLIF(mtt.in_hospital_cd_a2, ''''), ''-'')
	ELSE ''-''
	END
END AS treatment_cd --治療項目コード１
  FROM
    ord_main AS ord
    LEFT OUTER JOIN mst_treatment AS mtt ON mtt.treatment_cd = ord.rst_treatment_cd,
		IN_HOSPITAL
WHERE
  ord.ord_no = @ordNo', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）実績）透析条件', '2020-03-17 15:42:41', CURRENT_TIMESTAMP, NULL);