DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-310014,-310015,-1102027,-1103015,-1104005,-1105011,-1105012,-1106005,-1107008,-1108001);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310014, 'with
min_staff_ctl_no AS (
SELECT min(staff.value ->> ''ctl_no'') AS min_is_main_ctl_no
FROM pat_main 
        CROSS JOIN
            LATERAL json_array_elements(pat_main.charge_staff_info::json) staff
    WHERE
        pat_id = @patId
        AND staff.value ->> ''is_main'' = ''1'' 
)
,staff AS (
SELECT 
    staff.value ->> ''staff_cd'' staff_cd
from pat_main 
        CROSS JOIN
            LATERAL json_array_elements(pat_main.charge_staff_info::json) staff
    WHERE
        pat_id = @patId
        and staff.value ->> ''ctl_no'' = (SELECT min_is_main_ctl_no FROM min_staff_ctl_no)
)
,def_doctor AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''DEFAULT_DOCTOR''
)
, doctor_data as(
SELECT 
    CASE 
    WHEN (SELECT min_is_main_ctl_no FROM min_staff_ctl_no) IS NULL THEN (SELECT value FROM def_doctor)
    ELSE (SELECT staff_cd FROM staff)
    END AS staff_cd
)
,exam_data as (
    select
        TO_CHAR(
            reg_exam_date,
            ''YYYYMMDD''
        ) as exam_date,
        case
            reg_order_class
    when ''0'' then '' ''
            else reg_order_class
        end as exam_timing,
        order_exam_set_info
    from
        ntss.pat_exam_main
    where
        exam_main_cd = @ordNo ::integer
        --    )
),
output_item as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
    cross join
            lateral json_array_elements(
            ini.coop_ini_info::json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''OUTPUT_ITEM''
)
,
exam_set as(
    select
        exam_set.other_exam_time
    from
        (
            select
                order_exam_set_info
            from
                exam_data
        ) p
    cross join lateral json_array_elements(
            p.order_exam_set_info ::json
        ) info
    inner join mst_exam_set as exam_set 
                on
        info ->> ''set_cd'' = (
            exam_set.exam_set_cd || ''''
        )
),
before_margin as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
    cross join
            lateral json_array_elements(
            ini.coop_ini_info::json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''BEFORE_MARGIN''
),
after_margin as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
    cross join
            lateral json_array_elements(
            ini.coop_ini_info::json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''AFTER_MARGIN''
),
ord_data as(
    select
        ord.ord_no,
        ord.ind_treat_start_time,
        ind_cond_info -> ''1'' ->> ''value'' as plan_dialysis_time
    from
        (
            select
                *
            from
                ord_main
            where
                pat_id = @patId ::integer
                and treat_date = (
                    select
                        exam_date
                    from
                        exam_data
                )
                and is_del = ''0''
            order by
                ind_treat_start_time asc
            limit 1
        ) ord
),
exam_time as (
    select
        (
            select
                ord_no
            from
                ord_data
        ) as ord_no,
        exam_date,
        exam_timing,
        case
            exam_timing
  when ''1'' then 
  to_char(
                (
                    (
                        select
                            ind_treat_start_time
                        from
                            ord_data
                    )::time - (
                        (
                            select
                                value
                            from
                                before_margin
                        ) || '' minutes''
                    )::interval
                ),
                ''HH24MI''
            )
            when ''2'' then 
  to_char(
                (
                    (
                        select
                            ind_treat_start_time
                        from
                            ord_data
                    )::time + (
                        (
                            select
                                plan_dialysis_time
                            from
                                ord_data
                        ) || '' minutes''
                    )::interval + (
                        (
                            select
                                value
                            from
                                after_margin
                        ) || '' minutes''
                    )::interval
                ),
                ''HH24MI''
            )
            else (
                select
                    other_exam_time
                from
                    exam_set
            )
        end as exam_time
    from
        exam_data
),
output_in_out as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
    cross join
            lateral json_array_elements(
            ini.coop_ini_info::json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''OUTPUT_IN_OUT''
),
item_set_no as (
    --SELECT info.value ->> ''no'' AS no
    select
        info ->> ''set_cd'' as no
    from
        (
            select
                m.*
            from
                pat_exam_main as m
            where
                m.is_del = ''0''
                and jsonb_array_length(m.order_exam_set_info) > 0
                    and m.exam_main_cd = @ordNo ::integer
        ) p
    cross join lateral json_array_elements(
            p.order_exam_set_info ::json
        ) info
    inner join mst_exam_set as item 
                on
        info ->> ''set_cd'' = (
            item.exam_set_cd || ''''
        )
),
exam_items AS (
select
    item_cd,
    item_name,
    in_hospital_cd1,
    in_hospital_cd2,
    in_hospital_cd3
from
    (
        select
            info ->> ''set_cd'' as seq_no,
            ''6'' as sub_no,
            -- 子（検査項目）
            info ->> ''item_cd'' as item_cd,
            info ->> ''item_name'' as item_name,
            item.in_hospital_cd1,
            item.in_hospital_cd2,
            item.in_hospital_cd3
        from
            (
                select
                    m.*
                from
                    pat_exam_main as m
                where
                    m.is_del = ''0''
                    and jsonb_array_length(m.order_exam_set_info) > 0
                        and m.exam_main_cd = @ordNo ::integer
            ) p
        cross join lateral json_array_elements(
                p.exam_order_info ::json
            ) info
        join mst_exam_item as item 
            on
            info ->> ''item_cd'' = (
                item.exam_item_cd || ''''
            )
            and 
                case (select value from output_in_out)
                when ''1'' then item.is_in_hospital = ''0''
                when ''2'' then item.is_in_hospital = ''1''
                else true
            end
        where
            info ->> ''set_cd'' in (
                select
                    no
                from
                    item_set_no
            )
            and
          case
                (
                    select
                        value
                    from
                        output_item
                )
                when ''1'' then false
                else true
            end
    union all
        select
            info ->> ''set_cd'' as seq_no,
            ''5'' as sub_no,
            -- 親（検査セット）
            info ->> ''set_cd'' as item_cd,
            info ->> ''set_name'' as item_name,
            item.in_hospital_cd1,
            item.in_hospital_cd2,
            item.in_hospital_cd3
        from
            (
                select
                    m.*
                from
                    pat_exam_main as m
                where
                    m.is_del = ''0''
                    and jsonb_array_length(m.order_exam_set_info) > 0
                        and m.exam_main_cd = @ordNo ::integer
            ) p
        cross join lateral json_array_elements(
                p.order_exam_set_info ::json
            ) info
        left outer join mst_exam_set as item
            on
            info ->> ''set_cd'' = (
                item.exam_set_cd || ''''
            )
        where
            info ->> ''set_cd'' in (
                select
                    no
                from
                    item_set_no
            )
            and 
          case
                (
                    select
                        value
                    from
                        output_item
                )
                when ''2'' then false
                else true
            end
    ) exam_all
order by
    item_cd
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
    @patId::integer,
    ''{"pkg": "MED"}''::jsonb,
    jsonb_build_object(
        ''ord_no'', (SELECT ord_no FROM ord_data),
        ''hosp_pat_id'', LPAD(@hospPatId::text, 12, ''0''),
        ''exam_date'', (SELECT exam_date FROM exam_data), 
        ''exam_timing'', (SELECT exam_timing FROM exam_data),
        ''exam_time'', (SELECT exam_time FROM exam_time),
        ''staff_cd'',(SELECT staff_cd FROM doctor_data),
        ''exam_items'',
        (select jsonb_agg(
            jsonb_build_object(
                    ''exam_cd'',item_cd,
                    ''exam_name'',item_name,
                    ''in_hospital_cd1'',in_hospital_cd1,
                    ''in_hospital_cd2'',in_hospital_cd2,
                    ''in_hospital_cd3'',in_hospital_cd3
                )
            )
            from exam_items
        )::jsonb),
    ''1'',
    ''0'',
    - 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    ''MED''
FROM
    exam_items
    limit 1', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Medicom検査依頼実績連携', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310015, 'UPDATE
    pat_exam_main
SET
    is_lock = ''1''
WHERE
    exam_main_cd = @ordNo', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'Medicom検査依頼実績連携 検査依頼変更不可更新', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);

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
    ''Secom''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '透析指示連携_送信履歴メモ', '2025-06-12 17:30:57.105', CURRENT_TIMESTAMP, NULL);

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
    ''Secom''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '透析実績連携_送信履歴メモ', '2025-08-01 17:08:51.755', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1104005, 'WITH
  get_sequence_no AS (
	SELECT save_2->>''sequence_no'' AS sequence_no
	FROM pat_coop_detail
	WHERE save_2->>''ord_no'' = @ordNo
	  AND save_2->>''coop_cd'' = ''ind_dial''
	ORDER BY up_date DESC
	LIMIT 1
  )
, create_memo AS (
    SELECT json_build_object(
      ''coop_cd'', ''accept'',
      ''ord_no'', @ordNo::text,
      ''sequence_no'', sequence_no
    ) AS result_json
    FROM get_sequence_no
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
    ''Secom''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '再来受付_送信履歴メモ', '2025-08-19 13:36:50.942', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1105011, 'WITH in_hosp_code AS (
	--検体検査マスタの院内コード参照先
	SELECT
		coalesce(
			nullif(info ->> ''value'', ''''),
			info ->> ''default_v''
		) AS value
	FROM
		mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0''
		AND coalesce(info ->> ''key0'', '''') = @key0
		AND info ->> ''key1'' = ''SCM_EXAM_ORDER_SEND''
		AND info ->> ''key2'' = ''IN_HOSP_CODE''
)
, in_hosp_code_set as (
	--検体検査マスタの院内コード参照先
	select
		coalesce(
			nullif(info ->> ''value'', ''''),
			info ->> ''default_v''
		) as value
	from
		mst_coop_ini as ini
		cross join LATERAL json_array_elements(ini.coop_ini_info :: json) info
	where
		facility_cd = @facilityCd
		and is_del = ''0''
		and coalesce(info ->> ''key0'', '''') = @key0
		and info ->> ''key1'' = ''SCM_EXAM_ORDER_SEND''
		and info ->> ''key2'' = ''IN_HOSP_CODE_SET''
)
, get_ocuurdate_seqno AS ( --ファイルパスから送信日時取得
    SELECT
        substring(dump_path, 18, 8) AS occur_date
        , substring(dump_path, 27, 6) AS seq_no
    FROM sys_coop_journal scj
    WHERE scj.ctl_no = @ctlNo
)
, mst_exam_item_disp AS ( --出力検査項目
    SELECT *
        , CASE (SELECT value FROM in_hosp_code)
            WHEN ''1'' THEN mei.in_hospital_cd1
            WHEN ''2'' THEN mei.in_hospital_cd2
            WHEN ''3'' THEN mei.in_hospital_cd3
            ELSE mei.in_hospital_cd1
            END AS hosp_cd
    FROM mst_exam_item mei
    WHERE mei.facility_cd = @facilityCd
    AND mei.is_del = ''0''
    AND NULLIF((CASE (SELECT value FROM in_hosp_code)
            WHEN ''1'' THEN mei.in_hospital_cd1
            WHEN ''2'' THEN mei.in_hospital_cd2
            WHEN ''3'' THEN mei.in_hospital_cd3
            ELSE mei.in_hospital_cd1
        END), '''') IS NOT NULL
)
, mst_exam_set_disp AS ( --出力検査セット
    SELECT distinct
        mes.*
        , CASE (SELECT value FROM in_hosp_code_set)
            WHEN ''1'' THEN mes.in_hospital_cd1
            WHEN ''2'' THEN mes.in_hospital_cd2
            WHEN ''3'' THEN mes.in_hospital_cd3
            else mes.in_hospital_cd1
        END AS hosp_cd
    FROM mst_exam_set mes
    WHERE mes.facility_cd = @facilityCd
    AND mes.is_del = ''0''
    AND NULLIF((CASE (SELECT value FROM in_hosp_code_set)
            WHEN ''1'' THEN mes.in_hospital_cd1
            WHEN ''2'' THEN mes.in_hospital_cd2
            WHEN ''3'' THEN mes.in_hospital_cd3
            ELSE mes.in_hospital_cd1
        END), '''') IS NOT NULL
)
, pat_exam_main_data AS ( --送信対象
    SELECT
        mesd.exam_set_cd AS set_cd
        , mesd.hosp_cd AS hosp_cd
        , t.idx AS set_idx
        , 0 AS item_idx
    FROM pat_exam_main pem
    CROSS JOIN lateral jsonb_array_elements(order_exam_set_info) WITH ordinality t(info,idx)
    LEFT JOIN mst_exam_set_disp mesd ON mesd.exam_set_cd = (t.info ->> ''set_cd'') ::int
    WHERE pem.facility_cd = @facilityCd
    AND pem.pat_id = @patId
    AND pem.exam_main_cd = @ordNo
    AND LEFT(CASE (SELECT value FROM in_hosp_code_set)
            WHEN ''1'' THEN mesd.in_hospital_cd1
            WHEN ''2'' THEN mesd.in_hospital_cd2
            WHEN ''3'' THEN mesd.in_hospital_cd3
            ELSE mesd.in_hospital_cd1
        END,1) = ''S''
    union all
    SELECT
        mesd.exam_set_cd AS set_cd
        , meid.hosp_cd AS hosp_cd
        , t.idx AS set_idx
        , ROW_NUMBER() OVER(partition by mesd.exam_set_cd order by meid.hosp_cd) AS item_idx
    FROM pat_exam_main pem
    CROSS JOIN lateral jsonb_array_elements(order_exam_set_info) WITH ordinality t(info,idx)
    LEFT JOIN mst_exam_set_disp mesd on mesd.exam_set_cd = (t.info ->> ''set_cd'') ::int
    CROSS JOIN lateral jsonb_array_elements(exam_item_info)  WITH ordinality t2(info,idx)
    LEFT JOIN mst_exam_item_disp meid on (t2.info->>''exam_item_cd'')::int = meid.exam_item_cd
    WHERE pem.facility_cd = @facilityCd
    AND pem.pat_id = @patId
    AND pem.exam_main_cd = @ordNo
    AND meid.hosp_cd IS NOT NULL
    ORDER BY set_idx,item_idx
    LIMIT 250
)
, pat_exam_set_list AS ( --送信対象セットCD
    SELECT distinct
        pemd.set_cd
        , pemd.set_idx
    FROM pat_exam_main_data pemd
    WHERE pemd.item_idx IN (0, 1)
)
, add_memo AS (
    SELECT string_agg(memo, ''#'') AS memo
    FROM (
        SELECT
            concat((select occur_date from get_ocuurdate_seqno), ''|'', (select seq_no from get_ocuurdate_seqno), ''|'', set_cd) AS memo
        FROM pat_exam_set_list
        ORDER BY set_idx
    ) memo_list
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
    @patId::integer,
    ''{"pkg": "Secom"}''::jsonb,
    jsonb_build_object(
        ''coop_cd'', ''exam_ord'',
        ''ord_no'', @ordNo ::int,
        ''memo'', (SELECT memo FROM add_memo)
        ),
    ''1'',
    ''0'',
    - 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    ''Secom''
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_検体検査オーダー連携_送信履歴メモ(登録・更新)', '2025-07-17 09:25:31.386', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1105012, 'INSERT INTO ntss.pat_coop_detail(
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
    @patId::integer,
    ''{"pkg": "Secom"}''::jsonb,
    jsonb_build_object(
        ''coop_cd'', ''exam_ord'',
        ''ord_no'', @ordNo ::int,
        ''memo'', ''''
        ),
    ''1'',
    ''0'',
    - 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    ''Secom''', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_検体検査オーダー連携_送信履歴メモ(削除)', '2025-07-17 09:25:31.386', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1106005, 'WITH get_ocuurdate_seqno AS (
    --ファイルパスから送信日時取得
    SELECT
        SUBSTRING(dump_path FROM LENGTH(dump_path) - 20 FOR 8) AS occure_date,
        SUBSTRING(dump_path FROM LENGTH(dump_path) - 11 FOR 6) AS seq_no
    FROM
        sys_coop_journal scj
    WHERE
        scj.ctl_no = @ctlNo
)
INSERT
    INTO
    ntss.pat_coop_detail(
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
    @patId::integer,
    ''{"pkg": "Secom"}''::jsonb,
    jsonb_build_object(
        ''coop_cd'', ''rad_ord'',
        ''ord_no'', @ordNo ::int,
        ''memo'', (SELECT CONCAT(occure_date, ''|'', seq_no) FROM get_ocuurdate_seqno)
        ),
    ''1'',
    ''0'',
    - 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    @coopVersion', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_放射線オーダ連携_送信履歴メモ', '2025-07-14 21:24:14.285', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1107008, 'UPDATE ntss.ord_coop_no
SET  status=''1''
WHERE 
  facility_cd = @facilityCd
  AND pat_id = @patId
  AND ord_no = @ordNo
  AND coop_cd = @coopCd
  AND is_disp = ''1''
  AND is_del = ''0''
  AND coop_version = @coopVersion', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム　指示変更履歴　スキップじのord_coop_no更新処理', '2025-08-10 12:59:50.555', CURRENT_TIMESTAMP, NULL);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1108001, 'INSERT
    INTO
    pat_coop_detail(
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
    @patId::numeric,
    ''{"pkg": "Secom"}''::jsonb,
    jsonb_build_object(
        ''coop_cd'', ''rep_dial'',
        ''ord_no'', @ordNo ::numeric,
        ''memo'', dump_path
        ),
    ''1'',
    ''0'',
    - 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    @coopVersion
FROM
        sys_coop_journal
WHERE
        ctl_no = @ctlNo;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_レポート連携_送信履歴メモ', '2025-08-01 22:58:55.634', CURRENT_TIMESTAMP, NULL);
