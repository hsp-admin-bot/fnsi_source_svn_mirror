delete from ntss.sys_data_set
where sql_cd in (-1102027);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102027, '-- sys_coop_journalの取得＆ファイル名list作成
WITH distribute_setting AS (
  SELECT COALESCE(
           mcd.distribute_setting->''protocolInfo''->>''fileNameDelimiter'',''|''
         ) AS file_name_delimiter,
         COALESCE(
           REPLACE(
             mcd.distribute_setting->''protocolInfo''->>''fileSplitDelimiterFormat'',
             ''%s'',''%''
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
    -- dump_pathからデミリッタ（パイプ）を使用してファイル名をlistに埋める
   string_to_array(dump_path, ds.file_name_delimiter) AS path_array
  FROM sys_coop_journal
  CROSS JOIN distribute_setting ds
  WHERE ctl_no = @ctlNo
)
-- dumpをSHIFT_JIS変換
, decoded AS (
  SELECT
    ctl_no,
    convert_from(dump, ''SHIFT_JIS'') AS text_data
  FROM sys_coop_journal
  WHERE ctl_no = @ctlNo
)
-- dumpを行ごとにレコードに変換
, lines AS (
  SELECT
    l.ctl_no,
    row_number() OVER (PARTITION BY l.ctl_no ORDER BY ordinality) AS rn,
    line
  FROM decoded l,
  LATERAL ntss.extract_csv_records(text_data) WITH ORDINALITY AS t(line, ordinality)
)
-- get_sys_coop_journalで作成したファイル名listからファイル名を取り出す
, datas AS (
  SELECT
    get_sys_coop_journal.ctl_no,
    crud,
    array_length(path_array, 1) AS file_count,

    CASE
      WHEN array_length(path_array, 1) = 12 THEN path_array[1]
      WHEN array_length(path_array, 1) = 7  THEN path_array[1]
      ELSE NULL
    END AS res_file,

    CASE
      WHEN array_length(path_array, 1) = 12 THEN path_array[2]
      WHEN array_length(path_array, 1) = 11 THEN path_array[1]
      WHEN array_length(path_array, 1) = 7  THEN path_array[2]
      WHEN array_length(path_array, 1) = 6  THEN path_array[1]
      ELSE NULL
    END AS treat_file,

    CASE
      WHEN array_length(path_array, 1) = 12 THEN path_array[9]
      WHEN array_length(path_array, 1) = 11 THEN path_array[8]
      ELSE NULL
    END AS inj_file,

    CASE
      WHEN array_length(path_array, 1) = 12 THEN path_array[10]
      WHEN array_length(path_array, 1) = 11 THEN path_array[9]
      ELSE NULL
    END AS inj_detail_file,

    CASE
      WHEN array_length(path_array, 1) = 12 THEN path_array[12]
      WHEN array_length(path_array, 1) = 11 THEN path_array[11]
      WHEN array_length(path_array, 1) = 7  THEN path_array[7]
      WHEN array_length(path_array, 1) = 6  THEN path_array[6]
      ELSE NULL
    END AS med_file

FROM get_sys_coop_journal
)
--ファイル間の区切り位置を生成
, target_datas AS (
  SELECT
    datas.ctl_no,
    REPLACE(ds.file_split_delimite_format, ''%'', COALESCE(res_file,''NO_FILE_res_''  || ctl_no)) AS res_header,
    REPLACE(ds.file_split_delimite_format, ''%'', COALESCE(treat_file,''NO_FILE_treat_'' || ctl_no)) AS treat_header,
    REPLACE(ds.file_split_delimite_format, ''%'', COALESCE(inj_file,''NO_FILE_inj_'' || ctl_no)) AS inj_header,
    REPLACE(ds.file_split_delimite_format, ''%'', COALESCE(inj_detail_file,''NO_FILE_inj_detail_'' || ctl_no)) AS inj_detail_header,
    REPLACE(ds.file_split_delimite_format, ''%'', COALESCE(med_file,''NO_FILE_med_'' || ctl_no)) AS med_header
  FROM datas
  CROSS JOIN distribute_setting ds
)
-- data行の特定
, matched_res AS (
  SELECT l1.ctl_no, l1.rn FROM lines l1 JOIN target_datas t ON l1.line = t.res_header AND l1.ctl_no = t.ctl_no
)
, matched_treat AS (
  SELECT l1.ctl_no, l1.rn FROM lines l1 JOIN target_datas t ON l1.line = t.treat_header AND l1.ctl_no = t.ctl_no
)
, matched_inj AS (
  SELECT l1.ctl_no, l1.rn FROM lines l1 JOIN target_datas t ON l1.line = t.inj_header AND l1.ctl_no = t.ctl_no
)
, matched_inj_detail AS (
  SELECT l1.ctl_no, l1.rn FROM lines l1 JOIN target_datas t ON l1.line = t.inj_detail_header AND l1.ctl_no = t.ctl_no
)
, matched_med AS (
  SELECT l1.ctl_no, l1.rn FROM lines l1 JOIN target_datas t ON l1.line = t.med_header AND l1.ctl_no = t.ctl_no
)
, all_datas AS (
  SELECT l.ctl_no, l.rn FROM lines l WHERE l.line LIKE ''-----%''
)
-- 注射の実施単位の次の行を取得
, next_inj_item AS (
  SELECT mi.ctl_no, MIN(h.rn) AS next_rn
  FROM matched_inj mi
  JOIN all_datas h ON h.ctl_no = mi.ctl_no AND h.rn > mi.rn
  GROUP BY mi.ctl_no
)
-- 注射の実施単位の次の行を取得
, next_inj_unit AS (
  SELECT mid.ctl_no, MIN(h.rn) AS next_rn
  FROM matched_inj_detail mid
  JOIN all_datas h ON h.ctl_no = mid.ctl_no AND h.rn > mid.rn
  GROUP BY mid.ctl_no
)
-- 注射単位を抽出し行のCSVをlistに変換
, inj_item_lines AS (
  SELECT l.ctl_no, array_agg(field ORDER BY ordinality) AS cols
  FROM lines l
  JOIN matched_inj mi ON l.ctl_no = mi.ctl_no
  JOIN next_inj_item nh ON l.ctl_no = nh.ctl_no
  CROSS JOIN LATERAL ntss.parse_csv_row(l.line) WITH ORDINALITY AS t(field, ordinality)
  WHERE l.rn > mi.rn AND l.rn < nh.next_rn
    AND l.line NOT LIKE ''-----%''
    AND l.line <> ''''
  GROUP BY l.ctl_no, l.rn
)
-- 注射単位を抽出し行のCSVをlistに変換
, inj_detail_lines AS (
  SELECT l.ctl_no, array_agg(field ORDER BY ordinality) AS cols
  FROM lines l
  JOIN matched_inj_detail mid ON l.ctl_no = mid.ctl_no
  JOIN next_inj_unit nh ON l.ctl_no = nh.ctl_no
  CROSS JOIN LATERAL ntss.parse_csv_row(l.line) WITH ORDINALITY AS t(field, ordinality)
  WHERE l.rn > mid.rn AND l.rn < nh.next_rn
    AND l.line NOT LIKE ''-----%''
    AND l.line <> ''''
  GROUP BY l.ctl_no, l.rn
)
-- RP番号を紐づけて項目取得
, joined_injection AS (
  SELECT
    iu.ctl_no,
    iu.cols[6]AS rp_no,
    coalesce(iu.cols[12], '''') AS tech,
    coalesce(id.cols[7], '''') AS medicine_no,
    coalesce(id.cols[8], '''') AS medicine_code
  FROM inj_item_lines iu
  JOIN inj_detail_lines id
    ON iu.ctl_no = id.ctl_no AND iu.cols[6] = id.cols[6]
    WHERE coalesce(iu.cols[6], '''') <> '''' OR coalesce(id.cols[7], '''') <> ''''
)
-- RPのメモ作成
, injection_summary AS (
  SELECT
    joined_injection.ctl_no,
    string_agg(
      ''|'' || lpad(rp_no, 2, ''0'') || rpad(tech, 2, '' '') || lpad(medicine_no, 2, ''0'') || rpad(medicine_code, 6, '' ''),
      ''''
    ) AS inj_memo
  FROM joined_injection
  GROUP BY joined_injection.ctl_no
)
-- RPのjson作成
, item_list_json AS (
  SELECT
    ctl_no,
    json_agg(json_build_object(''rp_no'', rp_no,''medicine_no'', medicine_no)) AS item_list
  FROM joined_injection
  GROUP BY ctl_no
)
-- 各種データをlistに変換
, res_data AS (
  SELECT l.ctl_no, array_agg(field ORDER BY ordinality) AS cols
  FROM lines l
  JOIN matched_res mr ON l.ctl_no = mr.ctl_no AND l.rn = mr.rn + 1
  CROSS JOIN LATERAL ntss.parse_csv_row(l.line) WITH ORDINALITY AS t(field, ordinality)
  GROUP BY l.ctl_no, l.rn
)
, treat_data AS (
  SELECT l.ctl_no, array_agg(field ORDER BY ordinality) AS cols
  FROM lines l
  JOIN matched_treat mt ON l.ctl_no = mt.ctl_no AND l.rn = mt.rn + 1
  CROSS JOIN LATERAL ntss.parse_csv_row(l.line) WITH ORDINALITY AS t(field, ordinality)
  GROUP BY l.ctl_no, l.rn
)
, inj_data AS (
  SELECT l.ctl_no, array_agg(field ORDER BY ordinality) AS cols
  FROM lines l
  JOIN matched_inj mi ON l.ctl_no = mi.ctl_no AND l.rn = mi.rn + 1
  CROSS JOIN LATERAL ntss.parse_csv_row(l.line) WITH ORDINALITY AS t(field, ordinality)
  GROUP BY l.ctl_no, l.rn
)
, med_data AS (
  SELECT l.ctl_no, array_agg(field ORDER BY ordinality) AS cols
  FROM lines l
  JOIN matched_med mm ON l.ctl_no = mm.ctl_no AND l.rn = mm.rn + 1
  CROSS JOIN LATERAL ntss.parse_csv_row(l.line) WITH ORDINALITY AS t(field, ordinality)
  GROUP BY l.ctl_no, l.rn
)
, get_new_sys_coop_journal AS (
  SELECT
    substring((string_to_array(dump_path, ''|''))[1] from ''([0-9]{8})[0-9]{6}'') AS res_day,
    substring((string_to_array(dump_path, ''|''))[1] from ''[0-9]{8}([0-9]{6})'') AS res_time
  FROM sys_coop_journal
  WHERE coop_cd = ''ind_dial''
    AND facility_cd = @facilityCd
    AND ord_no = @ordNo
    AND pat_id = @patId
    AND crud = ''C''
    AND dump_path IS NOT NULL
  ORDER BY up_date DESC
  LIMIT 1
)
-- ファイル名から発生日、SEQ番号を取得
, file_info AS (
  SELECT
    datas.ctl_no,
    datas.crud,
    res_file,
    treat_file,
    inj_file,
    inj_detail_file,
    med_file,

    CASE
      WHEN datas.crud = ''D'' THEN to_char(to_date(NULLIF(treat_data.cols[3], ''''), ''YYYY-MM-DD''), ''YYYYMMDD'')
      ELSE substring(treat_file from ''_([0-9]{8})_'')
    END AS treat_day,
    CASE
      WHEN datas.crud = ''D'' THEN to_char(to_timestamp(NULLIF(treat_data.cols[4], ''''), ''HH24:MI:SS''), ''HH24MISS'')
      ELSE substring(treat_file from ''_[0-9]{8}_([0-9]{6})_[0-9]'')
    END AS treat_time,

    CASE
      WHEN datas.crud = ''D'' THEN to_char(to_date(NULLIF(inj_data.cols[3], ''''), ''YYYY-MM-DD''), ''YYYYMMDD'')
      ELSE substring(inj_file from ''_([0-9]{8})_'')
    END AS inj_day,
    CASE
      WHEN datas.crud = ''D'' THEN to_char(to_timestamp(NULLIF(inj_data.cols[4], ''''), ''HH24:MI:SS''), ''HH24MISS'')
      ELSE substring(inj_file from ''_[0-9]{8}_([0-9]{6})_[0-9]'')
    END AS inj_time,

    CASE
      WHEN datas.crud = ''D'' THEN to_char(to_date(NULLIF(med_data.cols[3], ''''), ''YYYY-MM-DD''), ''YYYYMMDD'')
      ELSE substring(med_file from ''_([0-9]{8})_'')
    END AS med_day,
    CASE
      WHEN datas.crud = ''D'' THEN to_char(to_timestamp(NULLIF(med_data.cols[4], ''''), ''HH24:MI:SS''), ''HH24MISS'')
      ELSE substring(med_file from ''_[0-9]{8}_([0-9]{6})'')
    END AS med_time,

    CASE
      WHEN datas.crud = ''D'' THEN (SELECT res_day FROM get_new_sys_coop_journal)
      ELSE substring(res_file from ''([0-9]{8})[0-9]{6}'')
    END AS res_day,
    CASE
      WHEN datas.crud = ''D'' THEN (SELECT res_time FROM get_new_sys_coop_journal)
      ELSE substring(res_file from ''[0-9]{8}([0-9]{6})'')
    END AS res_time

  FROM datas
 LEFT JOIN res_data    ON res_data.ctl_no = datas.ctl_no
 LEFT JOIN treat_data  ON treat_data.ctl_no = datas.ctl_no
 LEFT  JOIN inj_data    ON inj_data.ctl_no = datas.ctl_no
 LEFT JOIN med_data    ON med_data.ctl_no = datas.ctl_no
)
, create_memo AS (
SELECT json_build_object(
  ''coop_cd'', ''ind_dial'',
  ''ord_no'',@ordNo::text,
  ''memo'',
    ''R|'' ||  @sendStatus || ''|'' || coalesce(res_data.cols[2], '''') || ''|'' || coalesce(file_info.res_day, '''') || ''|'' || coalesce(file_info.res_time, '''') || ''|'' || coalesce(res_data.cols [10], '''') ||
    ''#T|'' || @sendStatus || ''|'' || coalesce(treat_data.cols[5], '''') || ''|'' || coalesce(file_info.treat_day, '''') || ''|'' || coalesce(file_info.treat_time, '''') ||
    ''#I|'' || @sendStatus || ''|'' || coalesce(inj_data.cols[5], '''') || ''|'' || coalesce(file_info.inj_day, '''') || ''|'' || coalesce(file_info.inj_time, '''') || coalesce(injection_summary.inj_memo, '''') ||
    ''#K|'' || @sendStatus || ''|'' || coalesce(med_data.cols[5], '''') || ''|'' || coalesce(file_info.med_day, '''') || ''|'' || coalesce(file_info.med_time, ''''),
  ''sequence_no'', res_data.cols [10],
  ''treatment_user_id'', treat_data.cols[5],
  ''treatment_send_day'', file_info.treat_day,
  ''treatment_seq_no'', file_info.treat_time,
  ''injection_user_id'', inj_data.cols[5],
  ''injection_send_day'', file_info.inj_day,
  ''injection_seq_no'', file_info.inj_time,
  ''medical_send_day'', file_info.med_day,
  ''medical_seq_no'', file_info.med_time,
  ''item_list'', item_list_json.item_list
) AS result_json
FROM file_info
LEFT JOIN res_data    ON res_data.ctl_no = file_info.ctl_no
LEFT JOIN treat_data  ON treat_data.ctl_no = file_info.ctl_no
LEFT JOIN inj_data    ON inj_data.ctl_no = file_info.ctl_no
LEFT JOIN med_data    ON med_data.ctl_no = file_info.ctl_no
LEFT JOIN get_sys_coop_journal ON get_sys_coop_journal.ctl_no = file_info.ctl_no
LEFT JOIN injection_summary ON injection_summary.ctl_no = file_info.ctl_no
LEFT JOIN item_list_json ON item_list_json.ctl_no = file_info.ctl_no
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
    ''Secom''', 2, '[]'::jsonb, '0', '{"applications": [6]}'::jsonb, NULL, '透析指示連携_送信履歴メモ', '2025-06-12 17:30:57.105', CURRENT_TIMESTAMP, NULL);