DELETE FROM ntss.sys_data_set WHERE sql_cd=-1103025;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-1103024;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-1103018;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-1103013;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-1103012;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-1103011;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-1103010;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-1103004;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-1103002;

INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103025, '-- SQL: -1103025 begin
WITH base AS (
  SELECT
    (@time::timestamptz + (@rpNo::int * INTERVAL ''1 second'')) AS ts_added
)
SELECT
  TO_CHAR(ts_added, ''YYYY-MM-DD'') AS occurrence_date,
  TO_CHAR(ts_added, ''HH24:MI:SS'') AS seq_no
FROM base;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 注射実績/注射中止 発生日・SEQ番号取得用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103024, '-- SQL:-1103024
WITH coop_ini_info AS (
    --連携設定取得(pre_sqlにて取得)
    SELECT CASE
            WHEN @key2 = ''NULL'' THEN ''NULL''
            ELSE coop_info->>''value''
        END AS value
    FROM json_array_elements(@coop_ini_info::json) coop_info
    WHERE (
            @key2 = ''NULL''
            OR (
                COALESCE(coop_info->>''key1'', '''') = @key1
                AND COALESCE(coop_info->>''key2'', '''') = @key2
            )
        )
    LIMIT 1
)
, input_values AS (
    SELECT LPAD(RIGHT(@hosp_pat_id, 8), 8, ''0'')::text AS hospital_id,
        (
            SELECT value
            FROM coop_ini_info
        )::text AS ini_value,
        TO_CHAR(@time::timestamptz, ''YYYYMMDD_HH24MISS'') AS timestamp
)
, folder_values AS (
    SELECT COALESCE(NULLIF(info->>''value'', ''''), info->>''default_v'') AS value
    FROM mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE facility_cd = @facilityCd
        AND is_del = ''0''
        AND COALESCE(info->>''key0'', '''') = @key0
        AND info->>''key1'' = @key1
        AND info->>''key2'' IN (''TREAT_FOLDER'', ''INJECT_FOLDER'')
)
,folder_check AS (
    select COUNT(DISTINCT value) = 1 AS is_same_folder
    FROM folder_values
)
,params AS (
    SELECT CASE
            WHEN ( SELECT is_same_folder FROM folder_check ) THEN 2
            ELSE 1
        END AS increment
),
suffix as (
	select
		case when @isCancel::boolean = false then 
			case when ( SELECT is_same_folder FROM folder_check ) then @suffix::INTEGER + 1
			else @suffix::INTEGER
			end 
		else 
			case when ( SELECT is_same_folder FROM folder_check ) then @maxSuffix::INTEGER + @suffix::INTEGER + 1
			else @maxSuffix::INTEGER + @suffix::INTEGER
			end 
		end
		as value
),
filename AS (
    SELECT i.hospital_id || ''_'' || i.ini_value || ''_'' || i.timestamp || ''_'' || suffix.value || ''.'' || @file_extension AS filename
    FROM input_values i
        CROSS JOIN suffix
)
SELECT *
FROM filename;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 注射実績ファイル_ファイル名生成用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100005, "field_name": "coop_ini_info", "replace_var": "@coop_ini_info"}, {"sql_cd": -1100006, "field_name": "hosp_pat_id", "replace_var": "@hosp_pat_id"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103018, '-- SQL: -1103018 begin
WITH RECURSIVE coop_ini_info AS (
    --連携設定から取得
    SELECT
        COALESCE(
            NULLIF(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) AS value,
        info ->> ''key1'' AS key1,
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) AS info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' IN(
            ''SCM_CONV_UNIT_MEDI'',
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_COMMON''
        )
),
ini_unit AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
),
ini_value AS(
    --連携設定取得値
    SELECT
        (
            SELECT
                value
            FROM
                coop_ini_info
            WHERE
                key1 = ''SCM_IN_HOSPITAL_CD''
                AND key2 = ''MST_MEDICINE''
        ) AS hosp_get_mst_medicine,
        (
            SELECT
                value
            FROM
                coop_ini_info
            WHERE
                key1 = ''SCM_IN_HOSPITAL_CD''
                AND key2 = ''MST_PROCEDURE''
        ) AS hosp_get_mst_procedure
),
mst_medi_mix AS (
    --調整薬剤マスタ
    SELECT
        t1.idx AS idx,
        medicine_mix_cd AS mix_cd,
        t1.info ->> ''solvent'' AS solvent,
        t1.info ->> ''cd'' AS medi_cd,
        t1.info ->> ''amount'' AS amount,
        mst.unit AS unit,
        mst.is_shot AS is_shot,
        mst.in_hospital_cd_1 AS in_hospital_cd_1,
        mst.in_hospital_cd_2 AS in_hospital_cd_2,
        mst.in_hospital_cd_3 AS in_hospital_cd_3,
        mst.in_hospital_cd_4 AS in_hospital_cd_4,
        mst.is_disp AS is_disp,
        mst.is_del AS is_del
    FROM
        mst_medicine_mix AS mix
        CROSS JOIN LATERAL json_array_elements(mix.mix_info :: json) WITH ORDINALITY AS t1(info, idx)
        INNER JOIN mst_medicine AS mst 
            ON
                mst.medicine_cd :: text = info ->> ''cd''
                AND mst.is_shot = ''1''
                AND mst.is_del = ''0''
                AND mst.is_disp = ''1''
    WHERE
        mix.is_del = ''0''
        AND mix.facility_cd = @facilityCd
        AND mst.facility_cd = @facilityCd
),
do_ord_main AS (
    (
        SELECT
            res.del_date AS up_date_switch,
            res.rst_medi_info AS rst_medi_info,
            res.treat_date :: TIMESTAMP AS treat_date
        FROM
            ord_main_restore AS res
            JOIN sys_coop_journal AS journal
                ON
                    res.ord_no = journal.ord_no
        WHERE
            res.ord_no = @ordNo
            AND res.facility_cd = @facilityCd
            AND journal.facility_cd = @facilityCd
            AND journal.ctl_no = @ctlNo
            AND journal.reg_date >= res.del_date
        ORDER BY
            res.del_date DESC
        LIMIT
            1
    )
    UNION
    (
        SELECT
            main.rst_edition_date AS up_date_switch,
            main.rst_medi_info AS rst_medi_info,
            main.treat_date :: TIMESTAMP AS treat_date
        FROM
            ord_main AS main
        WHERE
            main.ord_no = @ordNo
            AND main.facility_cd = @facilityCd
    )
    ORDER BY
        up_date_switch DESC NULLS LAST
    LIMIT
        1
), medi_indo AS (
    -- 投与薬剤情報
    SELECT
        t1.idx AS idx,
        t1.medi_info ->> ''cd'' AS mst_cd,
        CASE
            WHEN (om.treat_date >= mst_pro.in_hosp_a_startdate)
            AND (om.treat_date >= mst_pro.in_hosp_b_startdate) THEN CASE
                WHEN mst_pro.in_hosp_a_startdate >= mst_pro.in_hosp_b_startdate THEN CASE
                    ini_value.hosp_get_mst_procedure
                    WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
                    WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
                END
                WHEN mst_pro.in_hosp_a_startdate < mst_pro.in_hosp_b_startdate THEN CASE
                    ini_value.hosp_get_mst_procedure
                    WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
                    WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
                END
            END
            WHEN om.treat_date >= mst_pro.in_hosp_a_startdate THEN CASE
                ini_value.hosp_get_mst_procedure
                WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
                WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
            END
            WHEN om.treat_date >= mst_pro.in_hosp_b_startdate THEN CASE
                ini_value.hosp_get_mst_procedure
                WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
                WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
            END
            ELSE NULL
        END AS pro_hosp_cd,
        CASE
            WHEN json_array_length(om.rst_medi_info :: json) = 0 THEN NULL
            ELSE CASE
                t1.medi_info ->> ''medicine_type''
                WHEN ''1'' THEN CASE
                    ini_value.hosp_get_mst_medicine
                    WHEN ''1'' THEN mst_medi.in_hospital_cd_1
                    WHEN ''2'' THEN mst_medi.in_hospital_cd_2
                    WHEN ''3'' THEN mst_medi.in_hospital_cd_3
                    WHEN ''4'' THEN mst_medi.in_hospital_cd_4
                    ELSE NULL
                END
                WHEN ''2'' THEN CASE
                    ini_value.hosp_get_mst_medicine
                    WHEN ''1'' THEN mst_mix.in_hospital_cd_1
                    WHEN ''2'' THEN mst_mix.in_hospital_cd_2
                    WHEN ''3'' THEN mst_mix.in_hospital_cd_3
                    WHEN ''4'' THEN mst_mix.in_hospital_cd_4
                    ELSE NULL
                END
            END
        END AS hosp_cd,
        CASE
            WHEN json_array_length(om.rst_medi_info :: json) = 0 THEN NULL
            ELSE CASE
                t1.medi_info ->> ''medicine_type''
                WHEN ''1'' THEN (medi_info ->> ''amount'') :: numeric
                WHEN ''2'' THEN CASE
                    mst_mix.solvent
                    WHEN ''0'' THEN (medi_info ->> ''amount'') :: numeric * mst_mix.amount :: numeric
                    WHEN ''1'' THEN mst_mix.amount :: numeric
                END
                ELSE 0
            END
        END AS amount,
        CASE
            WHEN json_array_length(om.rst_medi_info :: json) = 0 THEN NULL
            ELSE CASE
                t1.medi_info ->> ''medicine_type''
                WHEN ''1'' THEN mst_medi.unit
                WHEN ''2'' THEN mst_mix.unit
            END
        END AS unit,
        CASE
            WHEN json_array_length(om.rst_medi_info :: json) = 0 THEN NULL
            ELSE CASE
                t1.medi_info ->> ''medicine_type''
                WHEN ''1'' THEN mst_medi.is_shot
                WHEN ''2'' THEN mst_mix.is_shot
            END
        END AS is_shot,
        CASE
            t1.medi_info ->> ''medicine_type''
            WHEN ''1'' THEN mst_medi.is_disp
            WHEN ''2'' THEN mst_mix.is_disp
        END AS is_disp
    FROM
        do_ord_main om
        CROSS JOIN LATERAL json_array_elements(om.rst_medi_info :: json) WITH ORDINALITY AS t1(medi_info, idx)
        LEFT JOIN mst_medicine AS mst_medi
            ON mst_medi.medicine_cd :: text = medi_info ->> ''cd''
                AND medi_info ->> ''medicine_type'' :: text = ''1''
                AND mst_medi.facility_cd = @facilityCd
        LEFT JOIN mst_medi_mix AS mst_mix
            ON
                mst_mix.mix_cd :: text = medi_info ->> ''cd''
                AND medi_info ->> ''medicine_type'' :: text = ''2''
        LEFT JOIN mst_procedure AS mst_pro
            ON
                mst_pro.procedure_cd :: text = t1.medi_info ->> ''procedure_cd''
                AND mst_pro.facility_cd = @facilityCd
        CROSS JOIN ini_value
    WHERE
        medi_info ->> ''effect_flg'' = ''1''
        AND (
            (
                medi_info ->> ''medicine_type'' :: text = ''1''
                AND mst_medi.is_del = ''0''
            )
            OR (
                medi_info ->> ''medicine_type'' :: text = ''2''
                AND mst_mix.is_del = ''0''
            )
        )
) 
,
memo_text AS (
    -- 送信履歴メモ.memoから取得
    SELECT
        save_2 ->> ''memo'' AS memo
    FROM
        pat_coop_detail
    WHERE
        pat_id = @patId
        AND save_2 ->> ''coop_cd'' = ''ind_dial''
        AND pat_coop_detail.facility_cd = @facilityCd
        AND save_2 ->> ''ord_no'' = @ordNo :: text
    ORDER BY
        up_date DESC
    LIMIT
        1
), bounds AS (
    SELECT
        memo,
        POSITION(''#I|'' IN memo) AS i_pos,
        POSITION(''#K'' IN memo) AS k_pos
    FROM
        memo_text
),
extracted AS (
    SELECT
        substring(memo FROM i_pos + 3 FOR k_pos - (i_pos + 3)) AS i_segment
    FROM
        bounds
),
split_parts AS (
    SELECT
        string_to_array(i_segment, ''|'') AS parts
    FROM
        extracted
),
item_info AS (
    SELECT
        parts [i] AS item_value,
        i - 4 AS item_index
    FROM
        split_parts,
        generate_series(5, CARDINALITY(parts)) AS i
),
get_items AS (
    SELECT
        item_index,
        item_value,
        substring(item_value FROM 1 FOR 2) AS rp_no,
        substring(item_value FROM 3 FOR 2) AS technique,
        substring(item_value FROM 5 FOR 2) AS med_no,
        substring(item_value FROM 7 FOR 6) AS med_code
    FROM
        item_info
), 
get_items_total AS (
    -- 同手技同薬剤コードは一つだけ出力
    SELECT
        DISTINCT ON (technique, med_code) *
    FROM
        get_items
    ORDER BY
        technique,
        med_code,
        item_index
), 
medi_indo_mi_cut AS (
    -- コード桁数処理
    SELECT
        *,
        CASE
            WHEN octet_length(hosp_cd) <= 4 THEN hosp_cd
            ELSE (
                SELECT
                    substring(hosp_cd FROM MIN(i))
                FROM
                    generate_series(1, char_length(hosp_cd)) AS i
                WHERE
                    octet_length(substring(hosp_cd FROM i)) <= 6
            )
        END AS hosp_cd_trimmed,
        RIGHT(pro_hosp_cd, 2) AS pro_hosp_cd_trimmed
    FROM
        medi_indo
),
unit_choice AS (
    SELECT
    	DISTINCT
    		ON (hosp_cd_trimmed, pro_hosp_cd_trimmed) hosp_cd_trimmed,
        pro_hosp_cd,
        unit
    FROM
        medi_indo_mi_cut
    WHERE
        is_shot = ''1''
        AND is_disp = ''1''
    ORDER BY
        hosp_cd_trimmed,
        pro_hosp_cd_trimmed,
        idx
),
select_seq AS (
    SELECT
        gi.rp_no :: numeric AS rp_no,
        gi.med_no :: numeric AS medi_no,
        mi.hosp_cd_trimmed AS medi_cd,
        LEAST(SUM(TRUNC(mi.amount, 2) :: FLOAT8), 9999999.99) :: text AS amount,
        MIN(ini_unit.value) AS unit
    FROM
        get_items_total gi
        INNER JOIN medi_indo_mi_cut AS mi ON gi.med_code = LPAD(mi.hosp_cd_trimmed, 6, '' '')
        AND gi.technique = LPAD(pro_hosp_cd_trimmed, 2, '' '')
        LEFT JOIN unit_choice uc ON mi.hosp_cd_trimmed = uc.hosp_cd_trimmed
        AND mi.pro_hosp_cd = uc.pro_hosp_cd
        LEFT JOIN ini_unit ON uc.unit = ini_unit.key2
    WHERE
        mi.is_shot = ''1''
        AND mi.is_disp = ''1''
    GROUP BY
        gi.rp_no,
        gi.med_no,
        mi.hosp_cd_trimmed
    ORDER BY
        rp_no,
        medi_no
),
raw_data AS (
    SELECT
        @contentJson :: jsonb AS data
),
ROWS AS (
    SELECT
        JSONB_ARRAY_ELEMENTS(data) AS ROW
    FROM
        raw_data
),
rp_no_switch AS (
    (
        SELECT
            (ROW ->> 8) :: numeric AS rp_no
        FROM
            ROWS
        WHERE
            @crud = ''del''
            AND @dumpResult = ''1''
    )
    UNION ALL
    (
        SELECT
            rp_no
        FROM
            select_seq
        WHERE
            @crud = ''del''
            AND @dumpResult <> ''1''
    )
)

SELECT DISTINCT
	''01'' AS detail_id,
    rp_no,
    (SELECT MAX(rp_no) FROM rp_no_switch) AS max_rp_no
FROM
    rp_no_switch
WHERE
    EXISTS (SELECT 1 FROM rp_no_switch)
ORDER BY
    rp_no
-- SQL: -1103018 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 注射実績(削除電文用)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103013, '-- SQL: -1103013 begin
WITH RECURSIVE coop_ini_info AS (
    --連携設定から取得
    SELECT
        COALESCE(
            NULLIF(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) AS value,
        info ->> ''key1'' AS key1,
        info ->> ''key2'' AS key2
    FROM
        mst_coop_ini AS ini
        CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info::json) AS info
    WHERE
        ini.facility_cd = @facilityCd
        AND ini.is_del = ''0''
        AND COALESCE(info ->> ''key0'', '''') = @key0
        AND info ->> ''key1'' IN(
            ''SCM_CONV_UNIT_MEDI'',
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_COMMON''
        )
),
ini_unit AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
),
ini_value AS(
    --連携設定取得値
    SELECT
        (
            SELECT
                value
            FROM
                coop_ini_info
            WHERE
                key1 = ''SCM_IN_HOSPITAL_CD''
                AND key2 = ''MST_MEDICINE''
        ) AS hosp_get_mst_medicine,
        (
            SELECT
                value
            FROM
                coop_ini_info
            WHERE
                key1 = ''SCM_IN_HOSPITAL_CD''
                AND key2 = ''MST_PROCEDURE''
        ) AS hosp_get_mst_procedure
),
mst_medi_mix AS (
    --調整薬剤マスタ
    SELECT
        t1.idx AS idx,
        medicine_mix_cd AS mix_cd,
        t1.info ->> ''solvent'' AS solvent,
        t1.info ->> ''cd'' AS medi_cd,
        t1.info ->> ''amount'' AS amount,
        mst.unit AS unit,
        mst.is_shot AS is_shot,
        mst.in_hospital_cd_1 AS in_hospital_cd_1,
        mst.in_hospital_cd_2 AS in_hospital_cd_2,
        mst.in_hospital_cd_3 AS in_hospital_cd_3,
        mst.in_hospital_cd_4 AS in_hospital_cd_4,
        mst.is_disp AS is_disp,
        mst.is_del AS is_del
    FROM
        mst_medicine_mix AS mix
        CROSS JOIN LATERAL json_array_elements(mix.mix_info::json) WITH ORDINALITY AS t1(info, idx)
        INNER JOIN mst_medicine AS mst
            ON
                mst.medicine_cd::text = info ->> ''cd''
                AND mst.is_shot = ''1''
                AND mst.is_del = ''0''
                AND mst.is_disp = ''1''
    WHERE
        mix.is_del = ''0''
        AND mix.facility_cd = @facilityCd
        AND mst.facility_cd = @facilityCd
),
do_ord_main AS (
    (
        SELECT
            res.del_date AS up_date_switch,
            res.rst_medi_info AS rst_medi_info,
            res.treat_date::TIMESTAMP AS treat_date
        FROM
            ord_main_restore AS res
            JOIN sys_coop_journal AS journal
                ON
                    res.ord_no = journal.ord_no
        WHERE
            res.ord_no = @ordNo
            AND res.facility_cd = @facilityCd
            AND journal.facility_cd = @facilityCd
            AND journal.ctl_no = @ctlNo
            AND journal.reg_date >= res.del_date
        ORDER BY
            res.del_date DESC
        LIMIT
            1
    )
    UNION
    (
        SELECT
            main.rst_edition_date AS up_date_switch,
            main.rst_medi_info AS rst_medi_info,
            main.treat_date::TIMESTAMP AS treat_date
        FROM
            ord_main AS main
        WHERE
            main.ord_no = @ordNo
            AND main.facility_cd = @facilityCd
    )
    ORDER BY
        up_date_switch DESC NULLS LAST
    LIMIT
        1
), medi_indo AS (
    -- 投与薬剤情報
    SELECT
        t1.idx AS idx,
        t1.medi_info ->> ''cd'' AS mst_cd,
        CASE
            WHEN (om.treat_date >= mst_pro.in_hosp_a_startdate)
            AND (om.treat_date >= mst_pro.in_hosp_b_startdate) THEN CASE
                WHEN mst_pro.in_hosp_a_startdate >= mst_pro.in_hosp_b_startdate THEN CASE
                    ini_value.hosp_get_mst_procedure
                    WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
                    WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
                END
                WHEN mst_pro.in_hosp_a_startdate < mst_pro.in_hosp_b_startdate THEN CASE
                    ini_value.hosp_get_mst_procedure
                    WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
                    WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
                END
            END
            WHEN om.treat_date >= mst_pro.in_hosp_a_startdate THEN CASE
                ini_value.hosp_get_mst_procedure
                WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
                WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
            END
            WHEN om.treat_date >= mst_pro.in_hosp_b_startdate THEN CASE
                ini_value.hosp_get_mst_procedure
                WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
                WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
            END
            ELSE NULL
        END AS pro_hosp_cd,
        CASE
            WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
            ELSE CASE
                t1.medi_info ->> ''medicine_type''
                WHEN ''1'' THEN CASE
                    ini_value.hosp_get_mst_medicine
                    WHEN ''1'' THEN mst_medi.in_hospital_cd_1
                    WHEN ''2'' THEN mst_medi.in_hospital_cd_2
                    WHEN ''3'' THEN mst_medi.in_hospital_cd_3
                    WHEN ''4'' THEN mst_medi.in_hospital_cd_4
                    ELSE NULL
                END
                WHEN ''2'' THEN CASE
                    ini_value.hosp_get_mst_medicine
                    WHEN ''1'' THEN mst_mix.in_hospital_cd_1
                    WHEN ''2'' THEN mst_mix.in_hospital_cd_2
                    WHEN ''3'' THEN mst_mix.in_hospital_cd_3
                    WHEN ''4'' THEN mst_mix.in_hospital_cd_4
                    ELSE NULL
                END
            END
        END AS hosp_cd,
        CASE
            WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
            ELSE CASE
                t1.medi_info ->> ''medicine_type''
                WHEN ''1'' THEN (medi_info ->> ''amount'')::numeric
                WHEN ''2'' THEN CASE
                    mst_mix.solvent
                    WHEN ''0'' THEN (medi_info ->> ''amount'')::numeric * mst_mix.amount::numeric
                    WHEN ''1'' THEN mst_mix.amount::numeric
                END
                ELSE 0
            END
        END AS amount,
        CASE
            WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
            ELSE CASE
                t1.medi_info ->> ''medicine_type''
                WHEN ''1'' THEN mst_medi.unit
                WHEN ''2'' THEN mst_mix.unit
            END
        END AS unit,
        CASE
            WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
            ELSE CASE
                t1.medi_info ->> ''medicine_type''
                WHEN ''1'' THEN mst_medi.is_shot
                WHEN ''2'' THEN mst_mix.is_shot
            END
        END AS is_shot,
        CASE
            t1.medi_info ->> ''medicine_type''
            WHEN ''1'' THEN mst_medi.is_disp
            WHEN ''2'' THEN mst_mix.is_disp
        END AS is_disp
    FROM
        do_ord_main om
        CROSS JOIN LATERAL json_array_elements(om.rst_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
        LEFT JOIN mst_medicine AS mst_medi
            ON mst_medi.medicine_cd::text = medi_info ->> ''cd''
                AND medi_info ->> ''medicine_type''::text = ''1''
                AND mst_medi.facility_cd = @facilityCd
        LEFT JOIN mst_medi_mix AS mst_mix
            ON
                mst_mix.mix_cd::text = medi_info ->> ''cd''
                AND medi_info ->> ''medicine_type''::text = ''2''
        LEFT JOIN mst_procedure AS mst_pro
            ON
                mst_pro.procedure_cd::text = t1.medi_info ->> ''procedure_cd''
                AND mst_pro.facility_cd = @facilityCd
        CROSS JOIN ini_value
    WHERE
        medi_info ->> ''effect_flg'' = ''1''
        AND (
            (
                medi_info ->> ''medicine_type''::text = ''1''
                AND mst_medi.is_del = ''0''
            )
            OR (
                medi_info ->> ''medicine_type''::text = ''2''
                AND mst_mix.is_del = ''0''
            )
        )
)
,
memo_text AS (
    -- 送信履歴メモ.memoから取得
    SELECT
        save_2 ->> ''memo'' AS memo
    FROM
        pat_coop_detail
    WHERE
        pat_id = @patId
        AND save_2 ->> ''coop_cd'' = ''ind_dial''
        AND pat_coop_detail.facility_cd = @facilityCd
        AND save_2 ->> ''ord_no'' = @ordNo::text
    ORDER BY
        up_date DESC
    LIMIT
        1
), bounds AS (
    SELECT
        memo,
        POSITION(''#I|'' IN memo) AS i_pos,
        POSITION(''#K'' IN memo) AS k_pos
    FROM
        memo_text
),
extracted AS (
    SELECT
        substring(memo FROM i_pos + 3 FOR k_pos - (i_pos + 3)) AS i_segment
    FROM
        bounds
),
split_parts AS (
    SELECT
        string_to_array(i_segment, ''|'') AS parts
    FROM
        extracted
),
item_info AS (
    SELECT
        parts [i] AS item_value,
        i - 4 AS item_index
    FROM
        split_parts,
        generate_series(5, CARDINALITY(parts)) AS i
),
get_items AS (
    SELECT
        item_index,
        item_value,
        substring(item_value FROM 1 FOR 2) AS rp_no,
        substring(item_value FROM 3 FOR 2) AS technique,
        substring(item_value FROM 5 FOR 2) AS med_no,
        substring(item_value FROM 7 FOR 6) AS med_code
    FROM
        item_info
),
get_items_total AS (
    -- 同手技同薬剤コードは一つだけ出力
    SELECT
        DISTINCT ON (technique, med_code) *
    FROM
        get_items
    ORDER BY
        technique,
        med_code,
        item_index
),
medi_indo_mi_cut AS (
    -- コード桁数処理
    SELECT
        *,
        CASE
            WHEN octet_length(hosp_cd) <= 4 THEN hosp_cd
            ELSE (
                SELECT
                    substring(hosp_cd FROM MIN(i))
                FROM
                    generate_series(1, char_length(hosp_cd)) AS i
                WHERE
                    octet_length(substring(hosp_cd FROM i)) <= 6
            )
        END AS hosp_cd_trimmed,
        RIGHT(pro_hosp_cd, 2) AS pro_hosp_cd_trimmed
    FROM
        medi_indo
),
unit_choice AS (
    SELECT
        DISTINCT
            ON (hosp_cd_trimmed, pro_hosp_cd_trimmed) hosp_cd_trimmed,
        pro_hosp_cd,
        unit
    FROM
        medi_indo_mi_cut
    WHERE
        is_shot = ''1''
        AND is_disp = ''1''
    ORDER BY
        hosp_cd_trimmed,
        pro_hosp_cd_trimmed,
        idx
),
select_seq AS (
    SELECT
        gi.rp_no::numeric AS rp_no,
        gi.med_no::numeric AS medi_no,
        mi.hosp_cd_trimmed AS medi_cd,
        LEAST(SUM(TRUNC(mi.amount, 2)::FLOAT8), 9999999.99)::text AS amount,
        MIN(ini_unit.value) AS unit
    FROM
        get_items_total gi
        INNER JOIN medi_indo_mi_cut AS mi ON gi.med_code = LPAD(mi.hosp_cd_trimmed, 6, '' '')
        AND gi.technique = LPAD(pro_hosp_cd_trimmed, 2, '' '')
        LEFT JOIN unit_choice uc ON mi.hosp_cd_trimmed = uc.hosp_cd_trimmed
        AND mi.pro_hosp_cd = uc.pro_hosp_cd
        LEFT JOIN ini_unit ON uc.unit = ini_unit.key2
    WHERE
        mi.is_shot = ''1''
        AND mi.is_disp = ''1''
    GROUP BY
        gi.rp_no,
        gi.med_no,
        mi.hosp_cd_trimmed
    ORDER BY
        rp_no,
        medi_no
),
ord_main_switch AS(
    -- ord_mainまたはord_main_restoreから、当連携処理のord_noに該当するの最新のレコードを取得する
    (
        SELECT
            TRUE AS is_from_ord_main,
            ord.rst_dialysis_state AS rst_dialysis_state,
            ord.rst_edition_date AS up_date_switch
        FROM
            ord_main ord
        WHERE
            ord.ord_no = @ordNo
            AND is_del = ''0''
    )
    UNION
    (
        SELECT
            FALSE AS is_from_ord_main,
            ord.rst_dialysis_state AS rst_dialysis_state,
            ord.del_date AS up_date_switch
        FROM
            ord_main_restore AS ord
            JOIN sys_coop_journal AS journal ON ord.ord_no = journal.ord_no
        WHERE
            ord.ord_no = @ordNo
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT
            1
    )
    ORDER BY
        up_date_switch DESC NULLS LAST
    LIMIT
        1
), inject_cancel_file_output_flg AS (
    -- 注射中止ファイル出力有無を判断するフラグを取得する
    SELECT
        CASE
            -- 処理対象ord_noに紐づく最新のオーダーがord_main_restoreから取得できた場合
            -- 注射中止ファイルを出力する
            WHEN oms.is_from_ord_main = FALSE THEN TRUE -- それ以外の場合
            -- rst_dialysis_stateが存在して、ord_main_restore.del_dateよりも最新の場合（実績が更新されている）
            -- 注射中止ファイルを出力しない
            ELSE FALSE
        END AS value
    FROM
        ord_main_switch AS oms
),
raw_data AS (
    SELECT
        @contentJson::jsonb AS data
),
ROWS AS (
    SELECT
        JSONB_ARRAY_ELEMENTS(data) AS ROW
    FROM
        raw_data
),
get_rp_no AS (
    SELECT
        ROW ->> 8 AS rp_no
    FROM
        ROWS
),
rp_no_switch AS(
    (
        SELECT
            (ROW ->> 8)::numeric AS rp_no
        FROM
            ROWS
        WHERE
            @crud = ''del''
            AND @dumpResult = ''1''
    )
    UNION ALL
    (
        SELECT
            rp_no
        FROM
            select_seq
        WHERE
            @crud = ''del''
            AND @dumpResult <> ''1''
    )
)
SELECT
    ''01'' AS detail_id,
    rp_no AS rp_no,
    (SELECT MAX(rp_no) FROM rp_no_switch) AS max_rp_no
FROM
    rp_no_switch
WHERE(
    SELECT value FROM inject_cancel_file_output_flg
)
ORDER BY
    rp_no::int
-- SQL: -1103013 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 注射中止ファイル', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1103016, "field_name": "content_json", "replace_var": "@contentJson"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103012, '-- SQL: -1103012 begin
select  
''01'' as detail_id,
@fileName AS file_name,
@folderName AS folder_name
-- SQL: -1103012 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 注射実績ファイル_ファイル作成終了', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1103024, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103011, '-- SQL: -1103011 begin
select  
CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
@fileName AS file_name,
@folderName AS folder_name,
@rpNo AS rp_no,
@time AS time
-- SQL: -1103011 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 注射実績ファイル_処置項目', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1103024, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103010, '-- SQL: -1103010 begin
select  
CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
@fileName AS file_name,
@folderName AS folder_name,
@rpNo AS rp_no,
@time AS time
-- SQL: -1103010 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'セコム連携 透析実績連携 注射実績ファイル_オーダーインデックス', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1103024, "field_name": "filename", "replace_var": "@fileName"}, {"sql_cd": -1100013, "field_name": "folder_name", "replace_var": "@folderName"}, {"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]'::jsonb);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103004, '-- SQL:-1103004
WITH RECURSIVE coop_ini_info AS (
--連携設定から取得
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
  info ->> ''key1'' AS key1,
  info ->> ''key2'' AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
WHERE
  ini.facility_cd = @facilityCd
  AND ini.is_del = ''0''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' IN(
            ''SCM_CONV_UNIT_MEDI'',
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_COMMON''
        )
)
, ini_unit AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
)

, ini_value AS(
--連携設定取得値
SELECT
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_mst_medicine,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_get_mst_procedure
  )
, mst_medi_mix AS (
--調整薬剤マスタ
SELECT
  t1.idx AS idx,
  medicine_mix_cd AS mix_cd,
  t1.info ->> ''solvent'' AS solvent,
  t1.info ->> ''cd'' AS medi_cd,
  t1.info ->> ''amount'' AS amount,
  mst.unit AS unit,
  mst.is_shot AS is_shot,
  mst.in_hospital_cd_1 AS in_hospital_cd_1,
  mst.in_hospital_cd_2 AS in_hospital_cd_2,
  mst.in_hospital_cd_3 AS in_hospital_cd_3,
  mst.in_hospital_cd_4 AS in_hospital_cd_4,
  mst.is_disp as is_disp,
  mst.is_del as is_del  
FROM
  mst_medicine_mix mix
CROSS JOIN LATERAL json_array_elements(mix.mix_info ::json) WITH ORDINALITY AS t1(info, idx)
INNER JOIN mst_medicine AS mst ON mst.medicine_cd::text = info ->> ''cd''
  AND mst.is_shot = ''1''
  AND mst.is_del = ''0''
  AND mst.is_disp = ''1''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
  AND mst.facility_cd = @facilityCd
)
, do_ord_main AS (
(SELECT
  res.del_date as up_date_switch,
  res.rst_medi_info AS rst_medi_info,
  res.treat_date::TIMESTAMP AS treat_date
FROM ord_main_restore as res
JOIN sys_coop_journal AS journal ON res.ord_no = journal.ord_no
WHERE res.ord_no = @ordNo
  AND res.facility_cd = @facilityCd
  AND journal.facility_cd = @facilityCd
  AND journal.ctl_no = @ctlNo
  AND journal.reg_date >= res.del_date
ORDER BY res.del_date DESC LIMIT 1
)
UNION
(SELECT
  main.rst_edition_date as up_date_switch,
  main.rst_medi_info AS rst_medi_info,
  main.treat_date::TIMESTAMP AS treat_date
FROM ord_main AS main
  WHERE main.ord_no = @ordNo
  AND main.facility_cd = @facilityCd
)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  t1.idx as idx,
  t1.medi_info ->> ''cd'' AS mst_cd,
  CASE
    WHEN (om.treat_date >= mst_pro.in_hosp_a_startdate) 
      AND (om.treat_date >= mst_pro.in_hosp_b_startdate) THEN
      CASE
        WHEN mst_pro.in_hosp_a_startdate >= mst_pro.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_procedure
            WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
            WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
          END
        WHEN mst_pro.in_hosp_a_startdate < mst_pro.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_procedure
            WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
            WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
          END
      END
    WHEN om.treat_date >= mst_pro.in_hosp_a_startdate THEN
      CASE ini_value.hosp_get_mst_procedure
        WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
        WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
      END
    WHEN om.treat_date >= mst_pro.in_hosp_b_startdate THEN
      CASE ini_value.hosp_get_mst_procedure
        WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
        WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
      END
    ELSE NULL
  END AS pro_hosp_cd,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN (medi_info ->> ''amount'')::numeric
        WHEN ''2'' THEN
          CASE mst_mix.solvent
            WHEN ''0'' THEN
              (medi_info ->> ''amount'')::numeric * mst_mix.amount::numeric
            WHEN ''1'' THEN
              mst_mix.amount::numeric
          END
        ELSE 0
      END
  END AS amount,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
          CASE t1.medi_info ->> ''medicine_type''
            WHEN ''1'' THEN mst_medi.unit
            WHEN ''2'' THEN mst_mix.unit
          END
  END AS unit,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot,
  CASE t1.medi_info ->> ''medicine_type''
    WHEN ''1'' THEN mst_medi.is_disp 
    WHEN ''2'' THEN mst_mix.is_disp 
  END AS is_disp
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''1'' AND mst_medi.facility_cd = @facilityCd
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''2''
LEFT JOIN mst_procedure AS mst_pro ON mst_pro.procedure_cd::text = t1.medi_info ->> ''procedure_cd'' AND mst_pro.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  medi_info ->> ''effect_flg'' = ''1''

  AND (
    (medi_info ->> ''medicine_type''::text = ''1'' AND  mst_medi.is_del = ''0'')
    OR
    (medi_info ->> ''medicine_type''::text = ''2'' AND  mst_mix.is_del = ''0'')
  )
  
)
-- 送信履歴メモ.memoから取得
, memo_text AS (
SELECT
  save_2->>''memo'' AS memo
FROM
  pat_coop_detail
WHERE
  pat_id = @patId
  AND save_2->>''coop_cd'' = ''ind_dial''
  AND pat_coop_detail.facility_cd = @facilityCd
  AND save_2->>''ord_no'' = @ordNo::text
ORDER BY
  up_date DESC
LIMIT 1
)
, bounds AS (
SELECT
  memo,
  POSITION(''#I|'' IN memo) AS i_pos,
  POSITION(''#K'' IN memo) AS k_pos
FROM
  memo_text
)
, extracted AS (
SELECT
  substring(memo FROM i_pos + 3 FOR k_pos - (i_pos + 3)) AS i_segment
FROM
  bounds
)
, split_parts AS (
SELECT
  string_to_array(i_segment, ''|'') AS parts
FROM
  extracted
)
, item_info AS (
SELECT
  parts[i] AS item_value,
  i - 4 AS item_index
FROM
  split_parts,
  generate_series(5, CARDINALITY(parts)) AS i
)
, get_items AS (
SELECT
  item_index,
  item_value,
  substring(item_value FROM 1 FOR 2) AS rp_no,
  substring(item_value FROM 3 FOR 2) AS technique,
  substring(item_value FROM 5 FOR 2) AS med_no,
  substring(item_value FROM 7 FOR 6) AS med_code
FROM
  item_info
)
-- 同手技同薬剤コードは一つだけ出力
, get_items_total AS (
  SELECT DISTINCT ON (technique, med_code) *
    FROM get_items
    ORDER BY technique, med_code, item_index
)
-- コード桁数処理
, medi_indo_mi_cut AS (
  SELECT
    *,
    CASE
      WHEN octet_length(hosp_cd) <= 4 THEN hosp_cd
      ELSE (
        SELECT substring(hosp_cd FROM MIN(i))
        FROM generate_series(1, char_length(hosp_cd)) AS i
        WHERE octet_length(substring(hosp_cd FROM i)) <= 6
      )
    END AS hosp_cd_trimmed,
    RIGHT(pro_hosp_cd, 2) as pro_hosp_cd_trimmed
  FROM medi_indo
),
 unit_choice AS (
  SELECT DISTINCT ON (hosp_cd_trimmed, pro_hosp_cd_trimmed)
    hosp_cd_trimmed,
    pro_hosp_cd,
    unit
  FROM medi_indo_mi_cut
  WHERE is_shot = ''1'' AND is_disp = ''1''
  ORDER BY hosp_cd_trimmed, pro_hosp_cd_trimmed, idx
)

,select_seq AS (
select
  gi.rp_no::numeric AS rp_no,
  gi.med_no::numeric AS medi_no,
  mi.hosp_cd_trimmed AS medi_cd,
  LEAST(SUM(TRUNC(mi.amount, 2)::FLOAT8), 9999999.99)::text AS amount,
  MIN(ini_unit.value) AS unit
FROM
  get_items_total gi
INNER JOIN medi_indo_mi_cut AS mi ON gi.med_code = LPAD(mi.hosp_cd_trimmed, 6,'' '')
  AND gi.technique = LPAD(pro_hosp_cd_trimmed, 2,'' '')
LEFT JOIN unit_choice uc
  ON mi.hosp_cd_trimmed = uc.hosp_cd_trimmed
  AND mi.pro_hosp_cd = uc.pro_hosp_cd
LEFT JOIN ini_unit
  ON uc.unit = ini_unit.key2
WHERE
  mi.is_shot = ''1'' and 
  mi.is_disp = ''1''
  
GROUP BY gi.rp_no, gi.med_no, mi.hosp_cd_trimmed

ORDER BY rp_no, medi_no
)
SELECT DISTINCT
  ''01'' AS detail_id,
  rp_no,
  (SELECT MAX(rp_no) FROM select_seq) AS max_rp_no
FROM
  select_seq
WHERE EXISTS (
  SELECT 1 FROM select_seq
)
ORDER BY
  rp_no', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析実績連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1103002, '-- SQL:-1103002
WITH RECURSIVE coop_ini_info AS (
--連携設定から取得
SELECT
  COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value,
  info ->> ''key1'' AS key1,
  info ->> ''key2'' AS key2
FROM
  mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
WHERE
  ini.facility_cd = @facilityCd
  AND ini.is_del = ''0''
  AND COALESCE(info ->> ''key0'', '''') = @key0
  AND info ->> ''key1'' IN(
            ''SCM_CONV_UNIT_MEDI'',
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_COMMON''
        )
)
, ini_unit AS (
    SELECT
        key2,
        value
    FROM
        coop_ini_info
    WHERE
        key1 = ''SCM_CONV_UNIT_MEDI''
)

, ini_value AS(
--連携設定取得値
SELECT
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'') AS hosp_get_mst_medicine,
  (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_get_mst_procedure
  )
, mst_medi_mix AS (
--調整薬剤マスタ
SELECT
  t1.idx AS idx,
  medicine_mix_cd AS mix_cd,
  t1.info ->> ''solvent'' AS solvent,
  t1.info ->> ''cd'' AS medi_cd,
  t1.info ->> ''amount'' AS amount,
  mst.unit AS unit,
  mst.is_shot AS is_shot,
  mst.in_hospital_cd_1 AS in_hospital_cd_1,
  mst.in_hospital_cd_2 AS in_hospital_cd_2,
  mst.in_hospital_cd_3 AS in_hospital_cd_3,
  mst.in_hospital_cd_4 AS in_hospital_cd_4,
  mst.is_disp as is_disp,
  mst.is_del as is_del  
FROM
  mst_medicine_mix mix
CROSS JOIN LATERAL json_array_elements(mix.mix_info ::json) WITH ORDINALITY AS t1(info, idx)
INNER JOIN mst_medicine AS mst ON mst.medicine_cd::text = info ->> ''cd''
  AND mst.is_shot = ''1''
  AND mst.is_del = ''0''
  AND mst.is_disp = ''1''
WHERE
  mix.is_del = ''0''
  AND mix.facility_cd = @facilityCd
  AND mst.facility_cd = @facilityCd
)
, do_ord_main AS (
(SELECT
  res.del_date as up_date_switch,
  res.rst_medi_info AS rst_medi_info,
  res.treat_date::TIMESTAMP AS treat_date
FROM ord_main_restore as res
JOIN sys_coop_journal AS journal ON res.ord_no = journal.ord_no
WHERE res.ord_no = @ordNo
  AND res.facility_cd = @facilityCd
  AND journal.facility_cd = @facilityCd
  AND journal.ctl_no = @ctlNo
  AND journal.reg_date >= res.del_date
ORDER BY res.del_date DESC LIMIT 1
)
UNION
(SELECT
  main.rst_edition_date as up_date_switch,
  main.rst_medi_info AS rst_medi_info,
  main.treat_date::TIMESTAMP AS treat_date
FROM ord_main AS main
  WHERE main.ord_no = @ordNo
  AND main.facility_cd = @facilityCd
)
ORDER BY
  up_date_switch DESC NULLS LAST
LIMIT 1
)
, medi_indo AS (
-- 投与薬剤情報
SELECT
  t1.idx as idx,
  t1.medi_info ->> ''cd'' AS mst_cd,
  CASE
    WHEN (om.treat_date >= mst_pro.in_hosp_a_startdate) 
      AND (om.treat_date >= mst_pro.in_hosp_b_startdate) THEN
      CASE
        WHEN mst_pro.in_hosp_a_startdate >= mst_pro.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_procedure
            WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
            WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
          END
        WHEN mst_pro.in_hosp_a_startdate < mst_pro.in_hosp_b_startdate THEN
          CASE ini_value.hosp_get_mst_procedure
            WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
            WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
          END
      END
    WHEN om.treat_date >= mst_pro.in_hosp_a_startdate THEN
      CASE ini_value.hosp_get_mst_procedure
        WHEN ''1'' THEN mst_pro.in_hospital_cd_a1
        WHEN ''2'' THEN mst_pro.in_hospital_cd_a2
      END
    WHEN om.treat_date >= mst_pro.in_hosp_b_startdate THEN
      CASE ini_value.hosp_get_mst_procedure
        WHEN ''1'' THEN mst_pro.in_hospital_cd_b1
        WHEN ''2'' THEN mst_pro.in_hospital_cd_b2
      END
    ELSE NULL
  END AS pro_hosp_cd,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_medi.in_hospital_cd_1
            WHEN ''2'' THEN mst_medi.in_hospital_cd_2
            WHEN ''3'' THEN mst_medi.in_hospital_cd_3
            WHEN ''4'' THEN mst_medi.in_hospital_cd_4
            ELSE NULL
          END
        WHEN ''2'' THEN 
          CASE ini_value.hosp_get_mst_medicine
            WHEN ''1'' THEN mst_mix.in_hospital_cd_1
            WHEN ''2'' THEN mst_mix.in_hospital_cd_2
            WHEN ''3'' THEN mst_mix.in_hospital_cd_3
            WHEN ''4'' THEN mst_mix.in_hospital_cd_4
            ELSE NULL
          END
      END
  END AS hosp_cd,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN (medi_info ->> ''amount'')::numeric
        WHEN ''2'' THEN
          CASE mst_mix.solvent
            WHEN ''0'' THEN
              (medi_info ->> ''amount'')::numeric * mst_mix.amount::numeric
            WHEN ''1'' THEN
              mst_mix.amount::numeric
          END
        ELSE 0
      END
  END AS amount,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
          CASE t1.medi_info ->> ''medicine_type''
            WHEN ''1'' THEN mst_medi.unit
            WHEN ''2'' THEN mst_mix.unit
          END
  END AS unit,
  CASE
    WHEN json_array_length(om.rst_medi_info::json) = 0 THEN NULL
    ELSE
      CASE t1.medi_info ->> ''medicine_type''
        WHEN ''1'' THEN mst_medi.is_shot
        WHEN ''2'' THEN mst_mix.is_shot
      END
  END AS is_shot,
  CASE t1.medi_info ->> ''medicine_type''
    WHEN ''1'' THEN mst_medi.is_disp 
    WHEN ''2'' THEN mst_mix.is_disp 
  END AS is_disp
FROM
  do_ord_main om
CROSS JOIN LATERAL json_array_elements(om.rst_medi_info::json) WITH ORDINALITY AS t1(medi_info, idx)
LEFT JOIN mst_medicine AS mst_medi ON mst_medi.medicine_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''1'' AND mst_medi.facility_cd = @facilityCd
LEFT JOIN mst_medi_mix AS mst_mix ON mst_mix.mix_cd::text = medi_info ->> ''cd''
  AND medi_info ->> ''medicine_type''::text = ''2''
LEFT JOIN mst_procedure AS mst_pro ON mst_pro.procedure_cd::text = t1.medi_info ->> ''procedure_cd'' AND mst_pro.facility_cd = @facilityCd
CROSS JOIN ini_value
WHERE
  medi_info ->> ''effect_flg'' = ''1''

  AND (
    (medi_info ->> ''medicine_type''::text = ''1'' AND  mst_medi.is_del = ''0'')
    OR
    (medi_info ->> ''medicine_type''::text = ''2'' AND  mst_mix.is_del = ''0'')
  )
  
)
-- 送信履歴メモ.memoから取得
, memo_text AS (
SELECT
  save_2->>''memo'' AS memo
FROM
  pat_coop_detail
WHERE
  pat_id = @patId
  AND save_2->>''coop_cd'' = ''ind_dial''
  AND pat_coop_detail.facility_cd = @facilityCd
  AND save_2->>''ord_no'' = @ordNo::text
ORDER BY
  up_date DESC
LIMIT 1
)
, bounds AS (
SELECT
  memo,
  POSITION(''#I|'' IN memo) AS i_pos,
  POSITION(''#K'' IN memo) AS k_pos
FROM
  memo_text
)
, extracted AS (
SELECT
  substring(memo FROM i_pos + 3 FOR k_pos - (i_pos + 3)) AS i_segment
FROM
  bounds
)
, split_parts AS (
SELECT
  string_to_array(i_segment, ''|'') AS parts
FROM
  extracted
)
, item_info AS (
SELECT
  parts[i] AS item_value,
  i - 4 AS item_index
FROM
  split_parts,
  generate_series(5, CARDINALITY(parts)) AS i
)
, get_items AS (
SELECT
  item_index,
  item_value,
  substring(item_value FROM 1 FOR 2) AS rp_no,
  substring(item_value FROM 3 FOR 2) AS technique,
  substring(item_value FROM 5 FOR 2) AS med_no,
  substring(item_value FROM 7 FOR 6) AS med_code
FROM
  item_info
)
-- 同手技同薬剤コードは一つだけ出力
, get_items_total AS (
  SELECT DISTINCT ON (technique, med_code) *
    FROM get_items
    ORDER BY technique, med_code, item_index
)
-- コード桁数処理
, medi_indo_mi_cut AS (
  SELECT
    *,
    CASE
      WHEN octet_length(hosp_cd) <= 4 THEN hosp_cd
      ELSE (
        SELECT substring(hosp_cd FROM MIN(i))
        FROM generate_series(1, char_length(hosp_cd)) AS i
        WHERE octet_length(substring(hosp_cd FROM i)) <= 6
      )
    END AS hosp_cd_trimmed,
    RIGHT(pro_hosp_cd, 2) as pro_hosp_cd_trimmed
  FROM medi_indo
),
 unit_choice AS (
  SELECT DISTINCT ON (hosp_cd_trimmed, pro_hosp_cd_trimmed)
    hosp_cd_trimmed,
    pro_hosp_cd,
    unit
  FROM medi_indo_mi_cut
  WHERE is_shot = ''1'' AND is_disp = ''1''
  ORDER BY hosp_cd_trimmed, pro_hosp_cd_trimmed, idx
)

select
  CASE @crud
    when ''del'' then
  		CASE @dumpResult
  			WHEN ''1'' THEN ''01''
  			ELSE ''02''
  		END 
  	ELSE ''01''
  END AS detail_id,
  gi.rp_no::numeric AS rp_no,
  gi.med_no::numeric AS medi_no,
  mi.hosp_cd_trimmed AS medi_cd,
  LEAST(SUM(TRUNC(mi.amount, 2)::FLOAT8), 9999999.99)::text AS amount,
  MIN(ini_unit.value) AS unit,
  @time AS time
FROM
  get_items_total gi
INNER JOIN medi_indo_mi_cut AS mi ON gi.med_code = LPAD(mi.hosp_cd_trimmed, 6,'' '')
  AND gi.technique = LPAD(pro_hosp_cd_trimmed, 2,'' '')
LEFT JOIN unit_choice uc
  ON mi.hosp_cd_trimmed = uc.hosp_cd_trimmed
  AND mi.pro_hosp_cd = uc.pro_hosp_cd
LEFT JOIN ini_unit
  ON uc.unit = ini_unit.key2
WHERE
  mi.is_shot = ''1'' and 
  mi.is_disp = ''1'' and
  gi.rp_no::numeric = @rpNo
  
GROUP BY gi.rp_no, gi.med_no, mi.hosp_cd_trimmed

ORDER BY rp_no, medi_no', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析実績連携', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -1100016, "field_name": "dump_result", "replace_var": "@dumpResult"}]'::jsonb);