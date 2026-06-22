DELETE FROM sys_data_set WHERE sql_cd IN 
(-1201010);


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201010, '--設定関連
with number_ini as (
    -- 0処理設定 0：デフォルト動作「0」～「99」　1：修正動作「000」～「099」
    select coalesce(nullif(info->>''value'', ''''), info->>''default_v'') as value
    from mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info::json) info
    where facility_cd = @facilityCd
        and is_del = ''0''
        and coalesce(info->>''key0'', '''') = @key0
        and info->>''key1'' = ''DIALYSISSEND''
        and info->>''key2'' = ''CREATE_NUMBER_FUNCTION''
),
do_ord_main AS (
  (
    SELECT
      ord_i.del_date as up_date_switch,
      ord_i.ord_no AS ord_no,
      ord_i.rst_treatment_info AS rst_treatment_info
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
      ord_i.rst_treatment_info AS rst_treatment_info
    FROM ord_main AS ord_i
    WHERE ord_i.ord_no = @ordNo
  )
  ORDER BY
    up_date_switch DESC NULLS LAST
  LIMIT 1
),
treat_json AS (
  SELECT 
    jsonb_array_elements(rst_treatment_info)::jsonb AS elem
  FROM do_ord_main
),
oxygen_vals AS (
  SELECT 
    TRUNC((elem  ->> ''oxygen_amount'')::numeric, 2) AS oxygen_amount
  FROM treat_json
  WHERE (elem  ->> ''oxygen_amount'') IS NOT NULL
),
oxygen_total AS (
  SELECT SUM(oxygen_amount) AS total_amount FROM oxygen_vals
)
SELECT
  CASE 
    WHEN total_amount IS NULL THEN ''''
    WHEN (SELECT value FROM number_ini) = ''1'' and  total_amount < 1 THEN
      -- 0.00～0.99 ⇒ ''000''～''099''
      RIGHT(LPAD(TO_CHAR(TRUNC(total_amount, 2), ''FM9V99''), 3, ''0''), 6)
    ELSE
      -- 通常
      RIGHT(TO_CHAR(TRUNC(total_amount, 2), ''FM9999999999V99''), 6)
  END AS oxygen_amount
FROM oxygen_total;

', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'SX_酸素吸入量(透析実績)', '2025-05-30 17:21:59.877', CURRENT_TIMESTAMP, NULL);


