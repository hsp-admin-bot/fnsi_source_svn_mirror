delete from "ntss"."sys_data_set" where "sql_cd" in (-57);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-57, 'WITH default_bed_code_conv AS (
  -- ベッド の連携設定で切り替え 
  SELECT
    0 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS bed_code_conv
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
    , '''' AS bed_code_conv
  ORDER BY order_no ASC LIMIT 1
)
select 
CASE (select bed_code_conv from default_bed_code_conv) WHEN ''1'' THEN mbd.in_hospital_cd_1  WHEN ''2'' THEN mbd.in_hospital_cd_2  ELSE ''V9999999'' end as bed_cd
from 
   ord_main AS ord
     LEFT OUTER JOIN mst_bed AS mbd ON mbd.bed_cd = ord.rst_bed_cd
WHERE
  ord.ord_no = @ordNo 
    AND ord.is_del =''0'' 
    AND ord.facility_cd = @facilityCd ', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）透析実績：予約枠コード（bed_cd）', '2022-03-07 14:56:57.011', CURRENT_TIMESTAMP, NULL);
