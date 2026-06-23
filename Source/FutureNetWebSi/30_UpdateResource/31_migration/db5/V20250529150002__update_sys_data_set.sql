DELETE FROM sys_data_set WHERE sql_cd IN (-500012);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-500012, 'WITH 
ssi_in_hospital_cd AS ( 
  SELECT
    info->>''key2'' AS key2
    , COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    AND COALESCE(info->>''key0'','''') = @key0
    AND info->>''key1'' = ''SSI_ORDER_RECV''
    AND info->>''key2'' = ''IN_HOSPITAL_CD''
) 
select
	bed_cd as ind_bed_cd
from
	mst_bed
where
	is_del = ''0''
	and is_disp = ''1''
	and facility_cd = @facilityCd
	and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = @indBedCd AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = @indBedCd AND COALESCE(in_hospital_cd_2,'''') <> ''''
      END
union all
select
    0 as ind_bed_cd
where not exists (
    select 1
    from mst_bed
    where
is_del = ''0''
and is_disp = ''1''
and facility_cd = @facilityCd
and CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN ''1'' THEN in_hospital_cd_1 = @indBedCd AND COALESCE(in_hospital_cd_1,'''') <> ''''
        WHEN ''2'' THEN in_hospital_cd_2 = @indBedCd AND COALESCE(in_hospital_cd_2,'''') <> ''''
      END
  
  limit 1
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIのベッド(SELECT)', '2025-04-06 12:25:16.884', CURRENT_TIMESTAMP, NULL);