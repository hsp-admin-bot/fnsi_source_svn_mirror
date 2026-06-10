DELETE FROM sys_data_set WHERE sql_cd IN 
(-1201004);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201004, '--設定関連
with medicine_idx as (
    -- 透析液の使用院内コード番号 
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as idx
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''SX_DIAL_INFO''
        and info->>''key2'' = ''MEDICINE_INHOSP''
),
do_ord_main AS (
  (
    SELECT
      ord_i.del_date as up_date_switch,
      ord_i.ord_no AS ord_no,
      ord_i.rst_equip_info AS rst_equip_info,
      ord_i.rst_cond_info AS rst_cond_info
    FROM ord_main_restore as ord_i
    JOIN sys_coop_journal AS journal ON ord_i.ord_no = journal.ord_no
    WHERE ord_i.ord_no = @ordNo
      AND journal.ctl_no = @ctlNo
      AND ord_i.ord_no = journal.ord_no
      AND journal.reg_date >= ord_i.del_date
    ORDER BY ord_i.del_date DESC LIMIT 1
  )
  UNION
  (
    SELECT
      ord_i.rst_edition_date as up_date_switch,
      ord_i.ord_no AS ord_no,
      ord_i.rst_equip_info AS rst_equip_info,
      ord_i.rst_cond_info AS rst_cond_info
    FROM ord_main AS ord_i
    WHERE ord_i.ord_no = @ordNo
  )
  ORDER BY
    up_date_switch DESC NULLS LAST
  LIMIT 1
)

SELECT * FROM
  (select
  COALESCE(
     CASE (SELECT idx FROM medicine_idx)
          WHEN ''1'' THEN mdr.in_hospital_cd_1
          WHEN ''2'' THEN mdr.in_hospital_cd_2
          WHEN ''3'' THEN mdr.in_hospital_cd_3
          WHEN ''4'' THEN mdr.in_hospital_cd_4
          ELSE mdr.in_hospital_cd_1
      END, '''') AS medicine_cd, -- 透析液コード
      
  COALESCE(
      RIGHT(TO_CHAR(FLOOR(TRUNC(COALESCE(NULLIF(ord.rst_cond_info -> ''17'' ->> ''value'', '''')::numeric, 0),2) * 100), ''FM999999999999''), 6)
      ,'''') as quantity, -- 数量
            
  COALESCE(mdr.unit_second, '''') AS unit          -- 単位

from do_ord_main as ord
  LEFT JOIN mst_medicine mdr ON mdr.medicine_cd = TO_NUMBER( ord.rst_cond_info -> ''15'' ->> ''value'', ''FM999999999999'' )
 ) as all_data
 where medicine_cd != ''''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_薬剤', '2025-05-23 17:36:09.485', CURRENT_TIMESTAMP, NULL);
