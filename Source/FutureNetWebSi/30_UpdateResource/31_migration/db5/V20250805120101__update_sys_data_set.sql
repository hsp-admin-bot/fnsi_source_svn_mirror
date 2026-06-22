delete from ntss.sys_data_set
where sql_cd in (-1103015);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1103015, '-- 実績の送信履歴メモ
WITH
  get_ini AS (
    SELECT
      coalesce(nullif(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
      info ->> ''key2'' as key2
    FROM mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
    WHERE
      facility_cd = @facilityCd
      AND is_del = ''0''
      AND coalesce(info ->> ''key0'', '''') = @key0
      AND info ->> ''key1'' = ''SCM_DIALYSISSEND''
      AND info ->> ''key2'' IN (''INJECT_IDX_FILE_STR'',''TREAT_IDX_FILE_STR'',''KARTE_FILE_STR'')
  )
,  distribute_setting AS (
  SELECT COALESCE(
      mcd.distribute_setting->''protocolInfo''->>''fileNameDelimiter'',
      ''|''
    ) AS file_name_delimiter,
    COALESCE(
      REPLACE(
        mcd.distribute_setting->''protocolInfo''->>''fileSplitDelimiterFormat'',
        ''%s'',
        ''%''
      ),
      ''----- % -----''
    ) AS file_split_delimite_format
  FROM mst_coop_distribute mcd
  WHERE mcd.facility_cd = @facilityCd
    AND coop_cd = @coopCd
    AND is_del = ''0''
)
, get_sys_coop_journal AS (
    SELECT
      ctl_no,
      crud,
      string_to_array(dump_path, ds.file_name_delimiter) AS path_array,
      array_length(string_to_array(dump_path, ds.file_name_delimiter), 1) AS file_count
    FROM sys_coop_journal
    CROSS JOIN distribute_setting ds
    WHERE ctl_no = @ctlNo
  )
, inject_match_count AS (
    SELECT
      j.ctl_no,
      COUNT(*) AS rp_count
    FROM get_sys_coop_journal j,
         get_ini i,
         unnest(j.path_array) AS file
    WHERE file LIKE ''%'' || i.value || ''%''
      AND i.key2 = ''INJECT_IDX_FILE_STR''
    GROUP BY j.ctl_no
  )
, classified_files AS (
  SELECT
    j.ctl_no,
    j.crud,
    MAX(CASE WHEN j.path_array[i] LIKE ''%'' || ti.value || ''%'' THEN j.path_array[i] END) AS treat_file,
    MAX(CASE WHEN j.path_array[i] LIKE ''%'' || ii.value || ''%'' THEN j.path_array[i] END) AS inject_file,
    MAX(CASE WHEN j.path_array[i] LIKE ''%'' || ki.value || ''%'' THEN j.path_array[i] END) AS med_file
  FROM get_sys_coop_journal j
  JOIN get_ini ti ON ti.key2 = ''TREAT_IDX_FILE_STR''
  JOIN get_ini ki ON ki.key2 = ''KARTE_FILE_STR''
  JOIN get_ini ii ON ii.key2 = ''INJECT_IDX_FILE_STR''
  , generate_subscripts(j.path_array, 1) AS i
  GROUP BY j.ctl_no, j.crud
)
, decoded AS (
    SELECT ctl_no, convert_from(dump, ''SHIFT_JIS'') AS text_data
    FROM sys_coop_journal
    WHERE ctl_no = @ctlNo
  )
, lines AS (
    SELECT
      l.ctl_no,
      row_number() OVER (PARTITION BY l.ctl_no ORDER BY ordinality) AS rn,
      line
    FROM decoded l,
    LATERAL ntss.extract_csv_records(text_data) WITH ORDINALITY AS t(line, ordinality)
  )
, matched_treat AS (
  SELECT
    l1.ctl_no,
    l1.rn,
    ''treat'' AS file_type
  FROM lines l1
  JOIN classified_files cf ON l1.ctl_no = cf.ctl_no
  JOIN distribute_setting ds ON TRUE
  WHERE cf.treat_file IS NOT NULL
    AND l1.line = REPLACE(ds.file_split_delimite_format, ''%'', cf.treat_file)
)
, matched_inject AS (
  SELECT
    l1.ctl_no,
    l1.rn,
    ''inject'' AS file_type
  FROM lines l1
  JOIN classified_files cf ON l1.ctl_no = cf.ctl_no
  JOIN distribute_setting ds ON TRUE
  WHERE cf.inject_file IS NOT NULL
    AND l1.line = REPLACE(ds.file_split_delimite_format, ''%'', cf.inject_file)
)
, matched_med AS (
  SELECT
    l1.ctl_no,
    l1.rn,
    ''med'' AS file_type
  FROM lines l1
  JOIN classified_files cf ON l1.ctl_no = cf.ctl_no
  JOIN distribute_setting ds ON TRUE
  WHERE cf.med_file IS NOT NULL
    AND l1.line = REPLACE(ds.file_split_delimite_format, ''%'', cf.med_file)
)
, treat_data AS (
    SELECT
      l.ctl_no,
      array_agg(field ORDER BY ordinality) AS cols
    FROM lines l
    JOIN matched_treat mt ON l.ctl_no = mt.ctl_no AND l.rn = mt.rn + 1
    CROSS JOIN LATERAL ntss.parse_csv_row(l.line) WITH ORDINALITY AS t(field, ordinality)
    GROUP BY l.ctl_no, l.rn
  )
, med_data AS (
    SELECT
      l.ctl_no,
      array_agg(field ORDER BY ordinality) AS cols
    FROM lines l
    JOIN matched_med mm ON l.ctl_no = mm.ctl_no AND l.rn = mm.rn + 1
    CROSS JOIN LATERAL ntss.parse_csv_row(l.line) WITH ORDINALITY AS t(field, ordinality)
    GROUP BY l.ctl_no, l.rn
  )
, inj_data AS (
    SELECT
      l.ctl_no,
      array_agg(field ORDER BY ordinality) AS cols
    FROM lines l
    JOIN matched_inject mi ON l.ctl_no = mi.ctl_no AND l.rn = mi.rn + 1
    CROSS JOIN LATERAL ntss.parse_csv_row(l.line) WITH ORDINALITY AS t(field, ordinality)
    GROUP BY l.ctl_no, l.rn
  )
, create_memo AS (
    SELECT json_build_object(
      ''coop_cd'', ''rst_dial'',
      ''ord_no'', @ordNo::text,
      ''memo'',
        ''#T|'' ||  to_char(to_date(nullif(treat_data.cols[3], ''''), ''YYYY-MM-DD''), ''YYYYMMDD'') || ''|'' || to_char(to_timestamp(nullif(treat_data.cols[4], ''''), ''HH24:MI:SS''), ''HH24MISS'') ||
        ''#I|'' ||  COALESCE(to_char(to_date(nullif(inj_data.cols[3], ''''), ''YYYY-MM-DD''), ''YYYYMMDD''), '''') || ''|'' || COALESCE(to_char(to_timestamp(nullif(inj_data.cols[4], ''''), ''HH24:MI:SS''), ''HH24MISS''), '''') || ''|'' || COALESCE(imc.rp_count::text, ''0'') ||
        ''#K|'' || to_char(to_date(nullif(med_data.cols[3], ''''), ''YYYY-MM-DD''), ''YYYYMMDD'') || ''|'' || to_char(to_timestamp(nullif(med_data.cols[4], ''''), ''HH24:MI:SS''), ''HH24MISS'')
    ) AS result_json
    FROM treat_data
    LEFT JOIN LATERAL (
      SELECT * FROM inj_data WHERE inj_data.ctl_no = treat_data.ctl_no LIMIT 1
    ) inj_data ON true
    LEFT JOIN LATERAL (
      SELECT * FROM med_data WHERE med_data.ctl_no = treat_data.ctl_no LIMIT 1
    ) med_data ON true
    LEFT JOIN inject_match_count imc ON treat_data.ctl_no = imc.ctl_no
  )
  INSERT INTO ntss.pat_coop_detail(
    facility_cd,
    pat_id,
    save_1,
    save_2,
    is_disp,
    is_del,
    user_id,
    up_date,
    reg_date,
    coop_version
)
SELECT
    @facilityCd,
    @patId::bigint,
    ''{"pkg": "Secom"}''::jsonb,
    (SELECT result_json FROM create_memo),
    ''1'',
    ''0'',
    - 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    ''Secom''', 2, '[]'::jsonb, '0', '{"applications": [6]}'::jsonb, NULL, '透析実績連携_送信履歴メモ', '2025-08-01 17:08:51.755', CURRENT_TIMESTAMP, NULL);