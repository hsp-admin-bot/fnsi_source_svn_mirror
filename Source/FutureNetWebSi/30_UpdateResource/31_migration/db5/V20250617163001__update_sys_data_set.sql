DELETE FROM sys_data_set WHERE sql_cd IN 
(-1201003);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201003, '--設定関連
with medicine_mode as (
    -- セット薬剤出力切り替え
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as flg
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''RST_SET_MEDICINE_RESOLVE''
        and info->>''key2'' = ''KOU_COAG_RESOLVE_MODE''
),
medicine_idx as (
    -- 薬剤マスタの使用院内コード番号 
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as idx
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''SX_DIAL_INFO''
        and info->>''key2'' = ''MEDICINE_INHOSP''
),
mix_medicine_idx as (
    -- 調合薬剤マスタの使用院内コード番号 
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as idx
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''SX_DIAL_INFO''
        and info->>''key2'' = ''MEDICINE_MIX_INHOSP''
),
create_number_function AS (
    --1未満の数量の出力設定
    SELECT COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') as value
    FROM mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
    WHERE facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info->>''key0'','''') = @key0
        AND info ->> ''key1'' = ''DIALYSISSEND''
        AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION''
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
),
cond_info AS (
  SELECT 
    TO_NUMBER( rst_cond_info -> ''25'' ->> ''value'', ''FM999999999999'' ) AS medicine_cd,
    (rst_cond_info -> ''25'') ->> ''medicine_type'' AS medicine_type,
CASE
    -- 数量 どちらかが入力されいない場合、一方を出力
   WHEN NULLIF(rst_cond_info -> ''26'' ->> ''value'', '''') IS NULL
   AND NULLIF(rst_cond_info -> ''28'' ->> ''value'', '''') IS NULL THEN NULL
  ELSE
    TRUNC(
      COALESCE(NULLIF(rst_cond_info -> ''26'' ->> ''value'', '''')::numeric, 0) +
      COALESCE(NULLIF(rst_cond_info -> ''28'' ->> ''value'', '''')::numeric, 0),
    2) * 100
    END AS total_value
  FROM do_ord_main
)

SELECT * FROM
  (select
  -- コード
    COALESCE(CASE 
      WHEN ci.medicine_type = ''1'' THEN
        CASE (SELECT idx FROM medicine_idx)
          WHEN ''1'' THEN m.in_hospital_cd_1
          WHEN ''2'' THEN m.in_hospital_cd_2
          WHEN ''3'' THEN m.in_hospital_cd_3
          WHEN ''4'' THEN m.in_hospital_cd_4
          ELSE m.in_hospital_cd_1
        END
      WHEN ci.medicine_type = ''2'' THEN
        CASE (SELECT idx FROM mix_medicine_idx)
          WHEN ''1'' THEN mm.in_hospital_cd_1
          WHEN ''2'' THEN mm.in_hospital_cd_2
          WHEN ''3'' THEN mm.in_hospital_cd_3
          ELSE mm.in_hospital_cd_1
        END
    END, '''') AS code,

    -- 総量（value + factor 8桁まで）
    CASE 
      WHEN ci.medicine_cd IS NOT NULL 
      THEN CASE
        WHEN (SELECT value FROM create_number_function) = ''1''
        THEN RIGHT(TO_CHAR(FLOOR(ci.total_value), ''FM999999999000''), 8)
        ELSE RIGHT(TO_CHAR(FLOOR(ci.total_value), ''FM999999999999''), 8)
        END
      ELSE ''''
    END AS quantity,
    
    -- 単位
    COALESCE(CASE 
      WHEN ci.medicine_type = ''1'' THEN m.unit
      WHEN ci.medicine_type = ''2'' THEN mm.unit
    END, '''') AS unit
  
  FROM cond_info ci
  LEFT JOIN mst_medicine m ON ci.medicine_cd = m.medicine_cd
  LEFT JOIN mst_medicine_mix mm ON ci.medicine_cd = mm.medicine_mix_cd
  
  where ci.medicine_type = ''1'' or (ci.medicine_type = ''2'' AND COALESCE((SELECT flg FROM medicine_mode), ''0'')  IN (''0'',''1''))
 ) as all_data
 where code != ''''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_抗凝固剤', '2025-05-23 17:36:09.485', CURRENT_TIMESTAMP, NULL);
