DELETE FROM sys_data_set WHERE sql_cd IN 
(-1202001);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1202001, 'WITH do_pat_exam_main AS (
    SELECT
        exam_main_cd
        , reg_exam_date
        , reg_order_class
        , exam_order_info
        , is_del
        , order_exam_set_info
        , pat_id
        , 0 AS idx
        , up_date
    FROM pat_exam_main_hst
    WHERE exam_main_cd = @ordNo
    AND is_del = ''0''
    UNION
    SELECT
        exam_main_cd
        , reg_exam_date
        , reg_order_class
        , exam_order_info
        , is_del
        , order_exam_set_info
        , pat_id
        , 0 AS idx
        , up_date
    FROM pat_exam_main
    WHERE exam_main_cd = @ordNo
    AND is_del = ''0''
    ORDER BY
        idx ASC
        , up_date DESC
    LIMIT 1
),
dialysis_kbn_1 as (
    -- 透析区分1(透析前)
    select coalesce(nullif(info->>''value'', ''0''), info->>''default_v'') as kbn
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''CONV_EXAMIN_ORDER_CLASS_TO_KARTE''
        and info->>''key2'' = ''1''
),
dialysis_kbn_2 as (
    -- 透析区分2(透析後)
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as kbn
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''CONV_EXAMIN_ORDER_CLASS_TO_KARTE''
        and info->>''key2'' = ''2''
),
dialysis_kbn_0 as (
    -- 透析区分0(その他)
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as kbn
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''CONV_EXAMIN_ORDER_CLASS_TO_KARTE''
        and info->>''key2'' = ''0''
)


select
  TO_CHAR(reg_exam_date, ''YYYYMMDD'') as exam_date_yyyymmdd,  --検査予定日
  TO_CHAR(reg_exam_date, ''YYMMDD'')   as exam_date_yymmdd,     --採取日

  COALESCE(CASE reg_order_class    
    WHEN ''1'' THEN coalesce( (SELECT kbn FROM dialysis_kbn_1) , ''1'')
    WHEN ''2'' THEN coalesce( (SELECT kbn FROM dialysis_kbn_2) , ''2'')
    WHEN ''0'' THEN coalesce( (SELECT kbn FROM dialysis_kbn_0) , ''0'')
    ELSE NULL  END , '''') AS dialysis_kbn --透析区分
from do_pat_exam_main



', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SX_血液検査依頼検査情報', '2025-06-13 14:55:54.000', CURRENT_TIMESTAMP, NULL);


