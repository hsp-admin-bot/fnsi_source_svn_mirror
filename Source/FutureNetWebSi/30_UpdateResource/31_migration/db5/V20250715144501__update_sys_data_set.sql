DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-1105001,-1105002,-1105003,-1105011);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1105001, 'WITH in_hosp_code AS (
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
, in_hosp_code_set AS (
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
		AND info ->> ''key2'' = ''IN_HOSP_CODE_SET''
)
, exam_data AS (
    SELECT
        t.set_info ->> ''set_cd'' AS set_cd
        , t.idx AS set_idx
    FROM
        pat_exam_main pem
        CROSS JOIN jsonb_array_elements(pem.order_exam_set_info) WITH ordinality AS t(set_info, idx)
    WHERE
        pem.facility_cd = @facilityCd
        AND pem.pat_id = @patId
        AND pem.exam_main_cd = @ordNo
        AND pem.is_del = ''0''
)
, item_count AS (
    --検査セットの院内コードがS始まりの場合取得
    SELECT
        1 AS item_sort_no,
        set_idx,
        CASE (SELECT value::numeric FROM in_hosp_code_set)
            WHEN 1 THEN mes.in_hospital_cd1
            WHEN 2 THEN mes.in_hospital_cd2
            WHEN 3 THEN mes.in_hospital_cd3
        END item_in_hospital_cd
    FROM
        exam_data
        LEFT JOIN mst_exam_set mes ON set_cd = mes.exam_set_cd::text
    WHERE
        LEFT(CASE (SELECT value::numeric FROM in_hosp_code_set)
            WHEN 1 THEN mes.in_hospital_cd1
            WHEN 2 THEN mes.in_hospital_cd2
            WHEN 3 THEN mes.in_hospital_cd3
        END, 1) = ''S''
    UNION ALL
    --検査項目数を取得
    SELECT
        2 AS item_sort_no,
        set_idx,
        CASE (SELECT value::numeric FROM in_hosp_code)
            WHEN 1 THEN mei.in_hospital_cd1
            WHEN 2 THEN mei.in_hospital_cd2
            WHEN 3 THEN mei.in_hospital_cd3
        END item_in_hospital_cd
    FROM
        exam_data
        LEFT JOIN mst_exam_set mes ON set_cd = mes.exam_set_cd::text
        CROSS JOIN jsonb_array_elements(mes.exam_item_info) AS item_info
        LEFT JOIN mst_exam_item mei ON item_info ->> ''exam_item_cd'' = mei.exam_item_cd::text
    WHERE
        NULLIF((CASE (SELECT value FROM in_hosp_code_set)
            WHEN ''1'' THEN mes.in_hospital_cd1
            WHEN ''2'' THEN mes.in_hospital_cd2
            WHEN ''3'' THEN mes.in_hospital_cd3
            ELSE mes.in_hospital_cd1
            END), '''') IS NOT NULL
        AND NULLIF((CASE (SELECT value FROM in_hosp_code)
            WHEN ''1'' THEN mei.in_hospital_cd1
            WHEN ''2'' THEN mei.in_hospital_cd2
            WHEN ''3'' THEN mei.in_hospital_cd3
            ELSE mei.in_hospital_cd1
            END), '''') IS NOT NULL
)
, limit_item AS (
    SELECT
        item_in_hospital_cd AS item_in_hospital_cd
    FROM
        item_count
    ORDER BY
        set_idx,
        item_sort_no,
        item_in_hospital_cd
    LIMIT 250
)
SELECT string_agg(RPAD(LEFT(item_in_hospital_cd, 8), 8, '' ''), '''') AS item_in_hospital_cd
FROM limit_item', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'Secom連携_検体検査オーダー連携', '2025-06-19 11:08:16.281', CURRENT_TIMESTAMP, NULL);
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
        ''coop_cd'', ''exam_main'',
        ''ord_no'', @ordNo ::int,
        ''memo'', (SELECT memo FROM add_memo)
        ),
    ''1'',
    ''0'',
    - 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    ''Secom''
', 2, '[]'::jsonb, '0', '{"applications": [6]}'::jsonb, NULL, 'Secom連携_検体検査オーダー連携_送信履歴メモ(登録・更新)', '2025-07-11 11:29:46.355', CURRENT_TIMESTAMP, NULL);
