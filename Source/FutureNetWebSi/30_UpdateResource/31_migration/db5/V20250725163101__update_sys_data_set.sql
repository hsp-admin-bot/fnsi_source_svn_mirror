delete from ntss.sys_data_set
where sql_cd in (-1102027);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1102027, '-- sys_coop_journalの取得＆ファイル名list作成
WITH get_sys_coop_journal AS (
  SELECT
    coop_result,
    ctl_no,
    -- dump_pathからデミリッタ（パイプ）を使用してファイル名をlistに埋める
    string_to_array(dump_path, ''|'') AS path_array
  FROM sys_coop_journal
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
    path_array[1]  AS res_file,
    path_array[2]  AS treat_file,
    path_array[9]  AS inj_file,
    path_array[10] AS inj_detail_file,
    path_array[12] AS med_file
  FROM get_sys_coop_journal
)
-- ファイル名から発生日、SEQ番号を取得
, file_info AS (
  SELECT
    datas.ctl_no,
    res_file,
    treat_file,
    inj_file,
    inj_detail_file,
    med_file,
    substring(treat_file from ''_([0-9]{8})_'') AS treat_day,
    substring(treat_file from ''_[0-9]{8}_([0-9]{6})_[0-9]'') AS treat_time,

    substring(inj_file from ''_([0-9]{8})_'') AS inj_day,
    substring(inj_file from ''_[0-9]{8}_([0-9]{6})_[0-9]'') AS inj_time,

    substring(med_file from ''_([0-9]{8})_'') AS med_day,
    substring(med_file from ''_[0-9]{8}_([0-9]{6})'') AS med_time,

    substring(res_file from ''([0-9]{8})[0-9]{6}'') AS res_day,
    substring(res_file from ''[0-9]{8}([0-9]{6})'') AS res_time
  FROM datas
)
--ファイル間の区切り位置を生成
, target_datas AS (
  SELECT
    datas.ctl_no,
    ''----- '' || res_file   || '' -----'' AS res_header,
    ''----- '' || treat_file || '' -----'' AS treat_header,
    ''----- '' || inj_file   || '' -----'' AS inj_header,
    ''----- '' || inj_detail_file || '' -----'' AS inj_detail_header,
    ''----- '' || med_file   || '' -----'' AS med_header
  FROM datas
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
    iu.cols[6]::bigint AS rp_no,
    coalesce(iu.cols[12], '''') AS tech,
    coalesce(id.cols[7], '''') AS medicine_no,
    coalesce(id.cols[8], '''') AS medicine_code
  FROM inj_item_lines iu
  JOIN inj_detail_lines id
    ON iu.ctl_no = id.ctl_no AND iu.cols[6] = id.cols[6]
)
-- RPのメモ作成
, injection_summary AS (
  SELECT
    joined_injection.ctl_no,
    string_agg(
      ''|'' || lpad(rp_no::text, 2, ''0'') || rpad(tech, 2, '' '') || lpad(medicine_no, 2, ''0'') || rpad(medicine_code, 6, '' ''),
      ''''
    ) AS inj_memo
  FROM joined_injection
  GROUP BY joined_injection.ctl_no
)
-- RPのjson作成
, item_list_json AS (
  SELECT
    ctl_no,
    json_agg(json_build_object(''rp_no'', rp_no::text,''medicine_no'', medicine_no)) AS item_list
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
, create_memo AS (
SELECT json_build_object(
  ''coop_cd'', ''ind_dial'',
  ''ord_no'',@ordNo::text,
  ''memo'',
    ''R|'' ||  coalesce(res_data.cols[2], '''') || ''|'' || coalesce(get_sys_coop_journal.coop_result, '''') || ''|'' || coalesce(file_info.res_day, '''') || ''|'' || coalesce(file_info.res_time, '''') || ''|'' || coalesce(res_data.cols [10], '''') ||
    ''#T|'' || coalesce(get_sys_coop_journal.coop_result, '''') || ''|'' || coalesce(treat_data.cols[5], '''') || ''|'' || coalesce(file_info.treat_day, '''') || ''|'' || coalesce(file_info.treat_time, '''') ||
    ''#I|'' || coalesce(get_sys_coop_journal.coop_result, '''') || ''|'' || coalesce(inj_data.cols[5], '''') || ''|'' || coalesce(file_info.inj_day, '''') || ''|'' || coalesce(file_info.inj_time, '''') || coalesce(injection_summary.inj_memo, '''') ||
    ''#K|'' || coalesce(get_sys_coop_journal.coop_result, '''') || ''|'' || coalesce(med_data.cols[5], '''') || ''|'' || coalesce(file_info.inj_day, '''') || ''|'' || coalesce(file_info.inj_time, ''''),
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
JOIN res_data    ON res_data.ctl_no = file_info.ctl_no
JOIN treat_data  ON treat_data.ctl_no = file_info.ctl_no
JOIN inj_data    ON inj_data.ctl_no = file_info.ctl_no
JOIN med_data    ON med_data.ctl_no = file_info.ctl_no
JOIN get_sys_coop_journal ON get_sys_coop_journal.ctl_no = file_info.ctl_no
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