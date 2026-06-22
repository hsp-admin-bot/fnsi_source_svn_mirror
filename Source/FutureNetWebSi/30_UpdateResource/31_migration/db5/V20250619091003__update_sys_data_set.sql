DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-1101505);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1101505, 'WITH
-- 1) content をセミコロンで分解
raw_entries AS (
  SELECT unnest(string_to_array(trim(both '';'' FROM ''@content''), '';'')) AS entry
),
-- 2) コロンで分割して in_hospital_cd, name, raw_state を取得
split_info AS (
  SELECT
    split_part(entry, '':'', 1) AS in_hospital_cd,
    split_part(entry, '':'', 2) AS name,
    split_part(entry, '':'', 3) AS raw_state
  FROM raw_entries
  WHERE entry <> ''''
),
-- 3) 生データ(key2)→変換後値(value) のマップ
state_map AS (
  SELECT
    info ->> ''key2''   AS raw_key,
    info ->> ''value''  AS state_val
  FROM mst_coop_ini ini
  CROSS JOIN LATERAL jsonb_array_elements(ini.coop_ini_info) AS info
  WHERE
    ini.facility_cd = ''@facilityCd''
    AND ini.is_del    = ''0''
    AND ini.is_disp   = ''1''
    AND info ->> ''key1'' = ''CONV_INFECTION_TO_FNW''
),
-- 4) mst_infection から facility_cd／is_del 絞り込み
infection_map AS (
  SELECT
    infection_cd,
    in_hospital_cd_1
  FROM ntss.mst_infection
  WHERE
    facility_cd = ''@facilityCd''
    AND is_del    = ''0''
),
-- 5) 新しい各エントリを組み立て
new_array AS (
  SELECT
    im.infection_cd,
    -- state_map がヒットすれば変換値、なければ ''0''
    COALESCE(sm.state_val, ''0'')       AS infect,
    to_char(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS up_date,
    NULL::text                        AS exam_date
  FROM split_info si
  -- raw_state → state_val
  LEFT JOIN state_map sm
    ON si.raw_state = sm.raw_key
  -- in_hospital_cd で infection_cd を取得
  JOIN infection_map im
    ON im.in_hospital_cd_1 = si.in_hospital_cd
)
-- 6) pat_main を更新
UPDATE pat_main pm
SET infect_info = (
  SELECT jsonb_agg(e.elem)
  FROM (
    SELECT elem
    FROM LATERAL jsonb_array_elements(infect_info) AS elem
    WHERE (elem->>''infection_cd'')::int NOT IN (SELECT infection_cd FROM new_array)
    UNION ALL
    SELECT jsonb_build_object(
      ''infect'',       na.infect,
      ''up_date'',      na.up_date,
      ''exam_date'',    to_jsonb(na.exam_date),
      ''infection_cd'', na.infection_cd
    )
    FROM new_array na
  ) AS e(elem)
),
up_date = CURRENT_TIMESTAMP
WHERE
  pm.pat_id = @patId
  AND pm.facility_cd = ''@facilityCd''
  AND pm.is_del = ''0'';', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)セコム)患者プロファイル　感染症更新', '2025-05-18 22:33:06.096', CURRENT_TIMESTAMP, NULL);