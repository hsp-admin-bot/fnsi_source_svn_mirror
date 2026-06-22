DELETE FROM ntss.sys_data_set WHERE sql_cd=-1102001;
DELETE FROM ntss.sys_data_set WHERE sql_cd=-1102012;

INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1102001, 'WITH personal_user AS (
    SELECT
        user_id,
        in_hospital_cd_1,
        in_hospital_cd_2
    FROM
        mst_personal_user mpu
    WHERE
        facility_cd = @facilityCd
        And is_del = ''0''
)
SELECT
    jsonb_agg(personal_user)::text AS personal_list
FROM
    personal_user', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示連携', '2025-06-23 15:08:41.412', current_timestamp, NULL);
INSERT INTO ntss.sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) VALUES(-1102012, '-- SQL: -1102012 begin
WITH coop_ini_info AS (
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
        AND info ->> ''key1'' in(
            ''SCM_COMMON'',
            ''SCM_IN_HOSPITAL_CD'',
            ''SCM_CONV_UNIT_MEDI''
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
, facility_medicine_order as (
    -- 施設設定マスタ(No.107)
    select 
		row_number () over () as setting_order, -- 適用順 
        TO_NUMBER(datt.setting_value::text, ''999999999999'') as setting_value -- 設定値
    from (
            select TO_NUMBER(
                    (
                        unnest(
                            string_to_array(
                                (
                                    select mst_f.value as rtt
                                    from mst_facility_setting as mst_f
                                    where mst_f.facility_setting_no = ''3007''
                                        and mst_f.facility_cd = @facilityCd
                                ),
                                '',''
                            )
                        )
                    ),
                    ''999999999999''
                ) as setting_value
        ) as datt
)
, medi_order as (
    -- 薬剤マスタの並び順
    select index_no::int as medi_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_code,
        order_cd->>''name'' as name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine''
)
, medi_class_order as (
    -- 薬剤分類マスタの並び順
    select index_no::int as medi_class_code_order,
        TO_NUMBER(order_cd->>''code'', ''999999999999'') as medi_class_code,
        order_cd->>''name'' as class_name
    from mst_selector
        cross join lateral jsonb_array_elements(order_settings->''items'') with ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicine_class''
)
, timing_order as (
    -- 投与タイミングマスタの並び順
    select
        index_no ::int as timing_code_order
        , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') as timing_code
    from mst_selector
    cross join LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
        and master_physical_name = ''mst_medicate_timing''
)
, procedure_order as (
    -- 手技マスタの並び順
    select
        index_no ::int as procedure_code_order
        , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') as procedure_code
    from mst_selector
    cross join LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality as tmp(order_cd, index_no)
    where facility_cd = @facilityCd
    and master_physical_name = ''mst_procedure''
)
, mst_medi as (
    select
        medicine_cd,
        class_cd,
        medi_order.medi_code_order,
        medi_class_order.medi_class_code_order
    from mst_medicine mmd
        left join medi_order on mmd.medicine_cd = medi_order.medi_code
        left join medi_class_order on mmd.class_cd = medi_class_order.medi_class_code
    where facility_cd = @facilityCd
)
, ord_main_max AS (
    (
        SELECT
            ord.ord_no,
            ord.del_date AS up_date,
            ord.treat_date,
            ord.ind_medi_info
        FROM
            ord_main_restore AS ord,
            sys_coop_journal AS journal
        WHERE
            ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
            AND journal.facility_cd = @facilityCd
            AND journal.ctl_no = @ctlNo
            AND ord.ord_no = journal.ord_no
            AND journal.reg_date >= ord.del_date
        ORDER BY
            del_date DESC
        LIMIT 1
    )
    UNION
    (
        SELECT
            ord.ord_no,
            ord.rst_edition_date AS up_date,
            ord.treat_date,
            ord.ind_medi_info
        FROM
            ord_main AS ord
        WHERE
            ord.ord_no = @ordNo
            AND ord.facility_cd = @facilityCd
    )
    ORDER BY
        up_date DESC NULLS LAST
    LIMIT 1
)
, ord_medi_infos AS (
    --通常薬剤
    SELECT
        100 + t.idx as registration_order,
        ord_medi_info ->> ''cd'' AS medicine_cd,
        mm.class_cd AS class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        mp.procedure_cd,
        ord.treat_date,
        ord_medi_info->>''date_interval'' as date_interval,
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'')
            WHEN ''1'' THEN mm.in_hospital_cd_1
            WHEN ''2'' THEN mm.in_hospital_cd_2
            WHEN ''3'' THEN mm.in_hospital_cd_3
            WHEN ''4'' THEN mm.in_hospital_cd_4
        END AS medi_cd,
        TRUNC((ord_medi_info ->> ''amount'') :: NUMERIC, 2) AS medi_amount,
        ini_unit.value AS unit_convert
    FROM
        ord_main_max ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
    INNER JOIN mst_procedure mp ON 
        ord_medi_info ->> ''procedure_cd'' = mp.procedure_cd :: text AND mp.facility_cd = @facilityCd
    LEFT JOIN mst_medicine mm ON 
        ord_medi_info ->> ''cd'' = mm.medicine_cd :: text AND mm.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_class mmc on mm.class_cd = mmc.class_cd AND mmc.facility_cd = @facilityCd
    LEFT JOIN ini_unit ON mm.unit = ini_unit.key2
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''1''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
        AND mm.is_disp = ''1''
    UNION ALL
    --調整薬剤
    SELECT
        100 + t.idx as registration_order,
        medi_mix_info ->> ''cd'' AS medicine_cd,
        mm.class_cd AS class_cd,
        ord_medi_info->>''medicine_type'' as medicine_type,
        ord_medi_info->>''timing_cd'' as timing_cd,
        mp.procedure_cd,
        ord.treat_date,
        ord_medi_info->>''date_interval'' as date_interval,
        CASE
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_MEDICINE'')
            WHEN ''1'' THEN mm.in_hospital_cd_1
            WHEN ''2'' THEN mm.in_hospital_cd_2
            WHEN ''3'' THEN mm.in_hospital_cd_3
            WHEN ''4'' THEN mm.in_hospital_cd_4
        END AS medi_cd,
        CASE
            medi_mix_info ->> ''solvent''
            WHEN ''0'' THEN TRUNC(
                (ord_medi_info ->> ''amount'') :: NUMERIC * (medi_mix_info ->> ''amount'') :: NUMERIC,
                2
            )
            WHEN ''1'' THEN TRUNC((medi_mix_info ->> ''amount'') :: NUMERIC, 2)
        END AS medi_amount,
        ini_unit.value AS unit_convert
    FROM
        ord_main_max ord
    CROSS JOIN LATERAL json_array_elements(ord.ind_medi_info :: json) WITH ORDINALITY as t(ord_medi_info, idx)
    INNER JOIN mst_procedure mp ON
        ord_medi_info ->> ''procedure_cd'' = mp.procedure_cd :: text AND mp.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_mix mmm ON
        ord_medi_info ->> ''cd'' = mmm.medicine_mix_cd :: text AND mmm.facility_cd = @facilityCd
    LEFT JOIN json_array_elements(mmm.mix_info :: json) medi_mix_info ON TRUE
    LEFT JOIN mst_medicine mm ON
        medi_mix_info ->> ''cd'' = mm.medicine_cd :: text AND mm.facility_cd = @facilityCd
    LEFT JOIN mst_medicine_class mmc ON mm.class_cd = mmc.class_cd AND mmc.facility_cd = @facilityCd
    LEFT JOIN ini_unit ON mm.unit = ini_unit.key2
    WHERE
        ord_medi_info ->> ''medicine_type'' = ''2''
        AND mm.is_shot = ''1''
        AND mm.is_del = ''0''
        AND mm.is_disp = ''1''
)
, procedure_code AS (
    --手技の院内コード
    SELECT
        MIN(CASE
        -- 両方とも利用開始日以降の場合
            WHEN ((omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate)
                AND (omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate)) THEN
                CASE
                    WHEN mp.in_hosp_a_startdate >= mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_cd
                            WHEN ''1'' THEN mp.in_hospital_cd_a1
                            WHEN ''2'' THEN mp.in_hospital_cd_a2
                        END
                    WHEN mp.in_hosp_a_startdate < mp.in_hosp_b_startdate THEN
                        CASE ini_value.hosp_cd
                            WHEN ''1'' THEN mp.in_hospital_cd_b1
                            WHEN ''2'' THEN mp.in_hospital_cd_b2
                        END
                END
            -- 治療日がAの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_a_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_b_startdate 
                OR mp.in_hosp_b_startdate IS NULL) THEN
                CASE ini_value.hosp_cd
                    WHEN ''1'' THEN mp.in_hospital_cd_a1
                    WHEN ''2'' THEN mp.in_hospital_cd_a2
                END
            -- 治療日がBの利用開始日以降の場合
            WHEN omi.treat_date::TIMESTAMP >= mp.in_hosp_b_startdate 
                AND (omi.treat_date::TIMESTAMP < mp.in_hosp_a_startdate 
                OR mp.in_hosp_a_startdate IS NULL) THEN
                CASE ini_value.hosp_cd
                    WHEN ''1'' THEN mp.in_hospital_cd_b1
                    WHEN ''2'' THEN mp.in_hospital_cd_b2
                END
            ELSE NULL
	    END) AS procedure_hosp_cd,
        omi.procedure_cd
    FROM
        ord_medi_infos omi
        LEFT JOIN mst_procedure mp ON
            omi.procedure_cd = mp.procedure_cd AND mp.facility_cd = @facilityCd
        CROSS JOIN (
            SELECT 
            (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_IN_HOSPITAL_CD'' AND key2 = ''MST_PROCEDURE'') AS hosp_cd
            ) AS ini_value
    GROUP BY
        omi.procedure_cd
)
, final_ord_medi_infos AS (
    --薬剤の出力タイプが薬剤単位
    SELECT
        omi.registration_order AS registration_order,
        mst_medi.medi_code_order AS medi_code_order,
        mst_medi.medi_class_code_order AS class_code_order,
        omi.medicine_type::numeric AS medicine_type_order,
        t.timing_code_order AS timing_code_order,
        p.procedure_code_order AS procedure_code_order,
        omi.date_interval::numeric AS date_interval,
        medi_cd,
        pc.procedure_hosp_cd,
        medi_amount,
        unit_convert
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    LEFT JOIN mst_medicine mm ON omi.medicine_cd = mm.medicine_cd :: text
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = omi.timing_cd::numeric
    LEFT JOIN procedure_order p ON p.procedure_code = omi.procedure_cd::numeric
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
        AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''0''
    UNION ALL
    --薬剤の出力タイプが手技単位
    SELECT
        MIN(omi.registration_order) AS registration_order,
        MIN(mst_medi.medi_code_order) AS medi_code_order,
        MIN(mst_medi.medi_class_code_order) AS class_code_order,
        MIN(omi.medicine_type::numeric) AS medicine_type_order,
        MIN(t.timing_code_order) AS timing_code_order,
        MIN(p.procedure_code_order) AS procedure_code_order,
        MIN(omi.date_interval::numeric) AS date_interval,
        medi_cd,
        pc.procedure_hosp_cd,
        SUM(medi_amount),
        MIN(unit_convert)
    FROM
        ord_medi_infos omi
    LEFT JOIN procedure_code pc ON omi.procedure_cd = pc.procedure_cd
    LEFT JOIN mst_medicine mm ON omi.medicine_cd = mm.medicine_cd :: text
    LEFT JOIN mst_medi ON mm.class_cd = mst_medi.class_cd AND mm.medicine_cd = mst_medi.medicine_cd
    LEFT JOIN timing_order t ON t.timing_code = omi.timing_cd::numeric
    LEFT JOIN procedure_order p ON p.procedure_code = omi.procedure_cd::numeric
    WHERE
        medi_cd IS NOT NULL
        AND pc.procedure_hosp_cd IS NOT NULL
        AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''1''
    GROUP BY
        medi_cd,
        pc.procedure_hosp_cd
)
, sort_order AS (
    --薬剤の表示順
    SELECT
        ROW_NUMBER() OVER(
            order by 
            case  
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 1 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 2 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 3 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 4 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 5 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 6 ) = 6 then f.date_interval end,
            case  
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 0 then f.registration_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 1 then f.class_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 2 then f.medicine_type_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 3 then f.medi_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 4 then f.timing_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 5 then f.procedure_code_order
                when (select setting_value from facility_medicine_order where setting_order = 7 ) = 6 then f.date_interval end,
                f.medi_code_order
        ) as sort_key,
        medi_cd,
        procedure_hosp_cd,
        f.medi_amount,
        f.unit_convert
    FROM
        final_ord_medi_infos f
)
, procedure_hosp_order AS (
    SELECT
        procedure_hosp_cd,
        MIN(sort_key) AS min_sort_key
    FROM sort_order
    GROUP BY procedure_hosp_cd
)
, numbered_base AS (
    SELECT
        s.*,
        (ROW_NUMBER() OVER (PARTITION BY s.procedure_hosp_cd ORDER BY s.sort_key) - 1) / 10 + 1 AS rp_chunk,
        p.min_sort_key
    FROM sort_order s
    JOIN procedure_hosp_order p ON s.procedure_hosp_cd = p.procedure_hosp_cd
)
, rp_num_assigned AS (
    --RP番号の採番
    SELECT
        *,
        DENSE_RANK() OVER (ORDER BY min_sort_key, rp_chunk) AS rp_num
    FROM numbered_base
)
, medi_numbering AS (
	--薬品番号の採番
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY rp_num,sort_key) AS new_sort_key,
        ROW_NUMBER() OVER (PARTITION BY rp_num ORDER BY sort_key) AS medi_num
    FROM rp_num_assigned
)
,select_seq AS(
    SELECT
        sort_key,
        ROW_NUMBER() OVER (ORDER BY sort_key) AS rp_num,
        1 AS medi_num,
        LPAD(RIGHT(medi_cd,6),6,'' '') AS medi_cd,
        TRUNC(medi_amount, 2)::FLOAT8::TEXT AS medi_amount,
        unit_convert
    FROM
        sort_order
    WHERE
        sort_key <= 10
        AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''0''
    UNION ALL
    SELECT
        new_sort_key AS sort_key,
        rp_num,
        medi_num,
        LPAD(RIGHT(medi_cd,6),6,'' '') AS medi_cd,
        TRUNC(medi_amount, 2)::FLOAT8::TEXT AS medi_amount,
        unit_convert
    FROM
        medi_numbering
    WHERE
        rp_num <= 10
        AND new_sort_key <= 20
        AND (SELECT value FROM coop_ini_info WHERE key1 = ''SCM_COMMON'' AND key2 = ''MEDICINE_SEND_TYPE'') = ''1''
)
SELECT 
   *
FROM
   select_seq
WHERE
   sort_key = @sortKey
-- SQL: -1102012 end', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(送信用)セコムの透析指示連携', '2025-06-24 17:02:31.955', current_timestamp, NULL);