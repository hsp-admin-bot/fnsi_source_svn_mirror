DELETE FROM  ntss.sys_data_set WHERE sql_cd = -301;
INSERT INTO ntss.sys_data_set (sql_cd, "sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
	 (-301, 'WITH ord_main_max AS (
  (
    SELECT
      ord.ord_no,
      ord.del_date AS up_date,
      ord.rst_medi_info,
      ord.rst_treatment_info
    FROM
      ord_main_restore AS ord,
      sys_coop_journal AS journal
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
  UNION
    (
      SELECT
        ord.ord_no,
        ord.rst_edition_date AS up_date,
        ord.rst_medi_info,
        ord.rst_treatment_info
      FROM
        ord_main AS ord
      WHERE
        ord.ord_no = @ordNo
    )
  ORDER BY
    up_date DESC NULLS LAST
  LIMIT
    1
), oxygen_inhalation AS (
  SELECT
    COALESCE(
      NULLIF(info ->> ''value'', ''''),
      info ->> ''default_v''
    ) AS value,
    info ->> ''key2'' AS key2
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''SSI_DIALYSIS_SEND''
    AND (
      info ->> ''key2'' = ''OXYGEN_ACTION_CD''
      OR info ->> ''key2'' = ''OXYGEN_INHALATION''
    )
),
grouping_dispose_activity AS (
  SELECT
    COALESCE(
      NULLIF(info ->> ''value'', ''''),
      info ->> ''default_v''
    ) AS value
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) info
  WHERE
    facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''SSI_DIALYSIS_SEND''
    AND info ->> ''key2'' = ''GROUPING_DISPOSE_ACTIVITY''
),
action_medi_information_normal AS (
  --投与薬剤情報(通常)
  SELECT
    ''処置行為'' AS detail_id,
    mmd.in_hospital_cd_2 AS e01,
    mmd.medicine_name AS e02,
    ''1'' AS e03,
    NULL AS e04,
    1 AS table_no,
    medi.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_medi_info :: json) WITH ORDINALITY AS medi(val, idx)
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER (medi.val ->> ''cd'', ''999999999999'')
  WHERE
    medi.val ->> ''effect_flg'' = ''1''
    AND medi.val ->> ''medicine_type'' = ''1''
    AND COALESCE(mmd.in_hospital_cd_2, ''ZERO'') <> ''ZERO''
    AND ord.ord_no = @ordNo
),
material_medi_information_normal AS (
  --投与薬剤情報(通常)
  SELECT
    ''処置材料'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    mmd.medicine_name AS e02,
    TRIM(
      to_char(
        to_number(medi.val ->> ''amount'', ''99999.99''),
        ''99990.99''
      )
    ) AS e03,
    COALESCE(mmd.unit_second, mmd.unit) AS e04,
    2 AS table_no,
    medi.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_medi_info :: json) WITH ORDINALITY AS medi(val, idx)
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER (medi.val ->> ''cd'', ''999999999999'')
  WHERE
    medi.val ->> ''effect_flg'' = ''1''
    AND medi.val ->> ''medicine_type'' = ''1''
    AND COALESCE(mmd.in_hospital_cd_1, ''ZERO'') <> ''ZERO''
    AND COALESCE(mmd.in_hospital_cd_2, ''ZERO'') <> ''ZERO''
    AND ord.ord_no = @ordNo
),
action_medi_information_adjusted AS (
  --投与薬剤情報(調製)
  SELECT
    ''処置行為'' AS detail_id,
    mmx.in_hospital_cd_2 AS e01,
    mmx.medicine_mix_name AS e02,
    ''1'' AS e03,
    NULL AS e04,
    4 AS table_no,
    medi.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_medi_info :: json) WITH ORDINALITY AS medi(val, idx)
    LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER (medi.val ->> ''cd'', ''999999999999'')
  WHERE
    medi.val ->> ''effect_flg'' = ''1''
    AND medi.val ->> ''medicine_type'' = ''2''
    AND COALESCE(mmx.in_hospital_cd_2, ''ZERO'') <> ''ZERO''
    AND ord.ord_no = @ordNo
),
material_medi_information_adjusted AS (
  SELECT
    --投与薬剤情報(調製)
    ''処置材料'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    mmd.medicine_name AS e02,
    TRIM(
      to_char(
        sum(
          to_number(
            (
              case
                mmxd.val ->> ''solvent''
                WHEN ''1'' THEN to_char(
                  to_number(mmxd.val ->> ''amount'', ''99999.99''),
                  ''99999.99''
                )
                ELSE to_char(
                  to_number(medi.val ->> ''amount'', ''99999.99'') * to_number(COALESCE(mmxd.val ->> ''amount'', ''0''), ''99999.99''),
                  ''99999.99''
                )
              end
            ),
            ''99999.99''
          )
        ),
        ''9990.99''
      )
    ) AS e03,
    COALESCE(mmd.unit_second, mmd.unit) AS e04,
    5 AS table_no,
    medi.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_medi_info :: json) WITH ORDINALITY AS medi(val, idx)
    LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER (medi.val ->> ''cd'', ''999999999999'')
    CROSS JOIN lateral json_array_elements (mmx.mix_info :: json) WITH ORDINALITY AS mmxd(val, idx)
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER (mmxd.val ->> ''cd'', ''999999999999'')
  WHERE
    medi.val ->> ''effect_flg'' = ''1''
    AND medi.val ->> ''medicine_type'' = ''2''
    AND COALESCE(mmd.in_hospital_cd_1, ''ZERO'') <> ''ZERO''
    AND COALESCE(mmx.in_hospital_cd_2, ''ZERO'') <> ''ZERO''
    AND ord.ord_no = @ordNo
  GROUP BY
    detail_id,
    e01,
    e02,
    e04,
    table_no,
    mmxd.idx,
    medi.idx
  ORDER BY
    row_no,
    mmxd.idx
),
action_treatment_medi_info AS (
  --処置薬剤情報
  SELECT
    ''処置行為'' AS detail_id,
    mmd.in_hospital_cd_2 AS e01,
    mmd.medicine_name AS e02,
    ''1'' AS e03,
    NULL AS e04,
    7 AS table_no,
    tmedi.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_treatment_info :: json) WITH ORDINALITY AS tmedi(val, idx)
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER (
      tmedi.val ->> ''treat_medicine_cd'',
      ''999999999999''
    )
  WHERE
    ord.ord_no = @ordNo
    AND COALESCE(mmd.in_hospital_cd_2, ''ZERO'') <> ''ZERO''
),
material_treatment_medi_info AS (
  --処置薬剤情報
  SELECT
    ''処置材料'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    mmd.medicine_name AS e02,
    TRIM(
      to_char(
        to_number(tmedi.val ->> ''amount'', ''99990.99''),
        ''99990.99''
      )
    ) AS e03,
    COALESCE(mmd.unit_second, mmd.unit) AS e04,
    8 AS table_no,
    tmedi.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_treatment_info :: json) WITH ORDINALITY AS tmedi(val, idx)
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER (
      tmedi.val ->> ''treat_medicine_cd'',
      ''999999999999''
    )
  WHERE
    ord.ord_no = @ordNo
    AND COALESCE(mmd.in_hospital_cd_2, ''ZERO'') <> ''ZERO''
    AND COALESCE(mmd.in_hospital_cd_1, ''ZERO'') <> ''ZERO''
),
action_treatment_medi_mix_info AS (
  --愁訴処置情報
  SELECT
    ''処置行為'' AS detail_id,
    mmx.in_hospital_cd_2 AS e01,
    mmx.medicine_mix_name AS e02,
    ''1'' AS e03,
    NULL AS e04,
    10 AS table_no,
    tmedi.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_treatment_info :: json) WITH ORDINALITY AS tmedi(val, idx)
    LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER (
      tmedi.val ->> ''treat_medicine_cd'',
      ''999999999999''
    )
  WHERE
    ord.ord_no = @ordNo
    AND COALESCE(mmx.in_hospital_cd_2, ''ZERO'') <> ''ZERO''
),
material_treatment_medi_mix_info AS (
  --愁訴処置情報
  SELECT
    ''処置材料'' AS detail_id,
    mmd.in_hospital_cd_1 AS e01,
    mmd.medicine_name AS e02,
    TRIM(
      to_char(
        sum(
          to_number(
            (
              case
                mmxd.val ->> ''solvent''
                WHEN ''1'' THEN to_char(
                  to_number(mmxd.val ->> ''amount'', ''99999.99''),
                  ''99999.99''
                )
                ELSE to_char(
                  to_number(tmedi.val ->> ''amount'', ''99999.99'') * to_number(COALESCE(mmxd.val ->> ''amount'', ''0''), ''99999.99''),
                  ''99999.99''
                )
              end
            ),
            ''99999.99''
          )
        ),
        ''9990.99''
      )
    ) AS e03,
    COALESCE(mmd.unit_second, mmd.unit) AS e04,
    11 AS table_no,
    tmedi.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_treatment_info :: json) WITH ORDINALITY AS tmedi(val, idx)
    LEFT OUTER JOIN mst_medicine_mix AS mmx ON mmx.medicine_mix_cd = TO_NUMBER (
      tmedi.val ->> ''treat_medicine_cd'',
      ''999999999999''
    )
    CROSS JOIN lateral json_array_elements (mmx.mix_info :: json) WITH ORDINALITY AS mmxd(val, idx)
    LEFT OUTER JOIN mst_medicine AS mmd ON mmd.medicine_cd = TO_NUMBER (mmxd.val ->> ''cd'', ''999999999999'')
  WHERE
    tmedi.val ->> ''medicine_type'' = ''2''
    AND COALESCE(mmd.in_hospital_cd_1, ''ZERO'') <> ''ZERO''
    AND COALESCE(mmx.in_hospital_cd_2, ''ZERO'') <> ''ZERO''
    AND ord.ord_no = @ordNo
  GROUP BY
    detail_id,
    e01,
    e02,
    e04,
    table_no,
    mmxd.idx,
    tmedi.idx
  ORDER BY
    row_no,
    mmxd.idx
),
agg_actions_materuals_all AS (
  SELECT
    a_detail_id,
    a_e01,
    MODE() WITHIN GROUP (
      ORDER BY
        a_e02
    ) AS a_e02,
    a_e03,
    a_e04,
    min(a_table_no) AS a_table_no,
    min(a_row_no) AS a_row_no,
    m_detail_id,
    m_e01,
    m_e02,
    SUM(m_e03) AS m_e03,
    m_e04,
    min(m_table_no) AS m_table_no,
    min(m_row_no) AS m_row_no
  FROM
    (
      (
        SELECT
          a.detail_id AS a_detail_id,
          a.e01 AS a_e01,
          a.e02 AS a_e02,
          a.e03 AS a_e03,
          a.e04 AS a_e04,
          a.table_no AS a_table_no,
          a.row_no AS a_row_no,
          m.detail_id AS m_detail_id,
          m.e01 AS m_e01,
          m.e02 AS m_e02,
          to_number(m.e03, ''99999.99'') AS m_e03,
          m.e04 AS m_e04,
          m.table_no AS m_table_no,
          m.row_no AS m_row_no
        FROM
          action_medi_information_normal a
          LEFT JOIN material_medi_information_normal m ON a.row_no = m.row_no
        ORDER BY
          a.row_no,
          m.row_no
      )
      UNION ALL
        (
          SELECT
            a.detail_id AS a_detail_id,
            a.e01 AS a_e01,
            a.e02 AS a_e02,
            a.e03 AS a_e03,
            a.e04 AS a_e04,
            a.table_no AS a_table_no,
            a.row_no AS a_row_no,
            m.detail_id AS m_detail_id,
            m.e01 AS m_e01,
            m.e02 AS m_e02,
            to_number(m.e03, ''99999.99'') AS m_e03,
            m.e04 AS m_e04,
            m.table_no AS m_table_no,
            m.row_no AS m_row_no
          FROM
            action_medi_information_adjusted a
            LEFT JOIN material_medi_information_adjusted m ON a.row_no = m.row_no
          ORDER BY
            a.row_no,
            m.row_no
        )
      UNION ALL
        (
          SELECT
            a.detail_id AS a_detail_id,
            a.e01 AS a_e01,
            a.e02 AS a_e02,
            a.e03 AS a_e03,
            a.e04 AS a_e04,
            a.table_no AS a_table_no,
            a.row_no AS a_row_no,
            m.detail_id AS m_detail_id,
            m.e01 AS m_e01,
            m.e02 AS m_e02,
            to_number(m.e03, ''99999.99'') AS m_e03,
            m.e04 AS m_e04,
            m.table_no AS m_table_no,
            m.row_no AS m_row_no
          FROM
            action_treatment_medi_info a
            LEFT JOIN material_treatment_medi_info m ON a.row_no = m.row_no
          ORDER BY
            a.row_no,
            m.row_no
        )
      UNION ALL
        (
          SELECT
            a.detail_id AS a_detail_id,
            a.e01 AS a_e01,
            a.e02 AS a_e02,
            a.e03 AS a_e03,
            a.e04 AS a_e04,
            a.table_no AS a_table_no,
            a.row_no AS a_row_no,
            m.detail_id AS m_detail_id,
            m.e01 AS m_e01,
            m.e02 AS m_e02,
            to_number(m.e03, ''99999.99'') AS m_e03,
            m.e04 AS m_e04,
            m.table_no AS m_table_no,
            m.row_no AS m_row_no
          FROM
            action_treatment_medi_mix_info a
            LEFT JOIN material_treatment_medi_mix_info m ON a.row_no = m.row_no
          ORDER BY
            a.row_no,
            m.row_no
        )
    ) AS action_material
  GROUP BY
    a_detail_id,
    a_e01,
    a_e03,
    a_e04,
    m_detail_id,
    m_e01,
    m_e02,
    m_e04
  ORDER BY
    a_row_no,
    m_row_no
),
actions_all_min_row_no AS (
  SELECT
    a_e01 AS e01,
    MIN(a_row_no) AS min_row_no
  FROM
    agg_actions_materuals_all
  GROUP BY
    a_e01
),
actions_all AS (
  SELECT
    detail_id,
    e01,
    e02,
    e03,
    e04,
    table_no,
    table_no * 100 + row_no AS row_no
  FROM(
      SELECT
        *
      FROM
        action_medi_information_normal
      UNION ALL
      SELECT
        *
      FROM
        action_medi_information_adjusted
      UNION ALL
      SELECT
        *
      FROM
        action_treatment_medi_info
      UNION ALL
      SELECT
        *
      FROM
        action_treatment_medi_mix_info
    ) AS actions
  ORDER BY
    table_no,
    row_no
),
agg_actions_all AS (
  SELECT
    t.a_detail_id AS detail_id,
    t.a_e01 AS e01,
    t.a_e02 AS e02,
    t.a_e03 AS e03,
    t.a_e04 AS e04,
    t.a_table_no AS table_no,
    t.a_row_no AS row_no
  FROM
    (
      SELECT
        a_detail_id,
        a_e01,
        a_e02,
        a_e03,
        a_e04,
        a_table_no,
        a_row_no
      FROM
        agg_actions_materuals_all
      GROUP BY
        a_detail_id,
        a_e01,
        a_e02,
        a_e03,
        a_e04,
        a_table_no,
        a_row_no
    ) t
    JOIN actions_all_min_row_no m ON t.a_e01 = m.e01
    AND t.a_row_no = m.min_row_no
  ORDER BY
    t.a_row_no
),
materials_all AS (
  SELECT
    detail_id,
    e01,
    e02,
    e03,
    e04,
    table_no,
    (table_no - 1) * 100 + row_no AS row_no
  FROM(
      SELECT
        *
      FROM
        material_medi_information_normal
      UNION ALL
      SELECT
        *
      FROM
        material_medi_information_adjusted
      UNION ALL
      SELECT
        *
      FROM
        material_treatment_medi_info
      UNION ALL
      SELECT
        *
      FROM
        material_treatment_medi_mix_info
    ) AS materials
  ORDER BY
    table_no,
    row_no
),
agg_materials_all AS (
  SELECT
    agg_a_m.m_detail_id AS detail_id,
    agg_a_m.m_e01 AS e01,
    agg_a_m.m_e02 AS e02,
    TRIM(to_char(agg_a_m.m_e03, ''99990.99'')) AS e03,
    agg_a_m.m_e04 AS e04,
    agg_a_m.m_table_no AS table_no,
    agg_a.row_no AS row_no
  FROM
    agg_actions_all agg_a
    RIGHT JOIN agg_actions_materuals_all agg_a_m ON agg_a.e01 = agg_a_m.a_e01
  WHERE
    agg_a_m.m_detail_id IS NOT NULL
  ORDER BY
    agg_a.row_no,
    agg_a_m.m_row_no
),
delimiter_actions AS (
  SELECT
    ''区切り'' AS detail_id,
    ''000000'' AS e01,
    ''区切り'' AS e02,
    ''1'' AS e03,
    NULL AS e04,
    12 AS table_no,
    row_no -1 AS row_no
  FROM
    (
      SELECT
        *,
        ''0'' AS grouping_type
      FROM
        actions_all
      UNION ALL
      SELECT
        *,
        ''1'' AS grouping_type
      FROM
        agg_actions_all
    ) AS act
  WHERE
    act.grouping_type = (
      SELECT
        value
      FROM
        grouping_dispose_activity
      LIMIT
        1
    )
  ORDER BY
    row_no OFFSET 1
),
actions_materials_all AS (
  SELECT
    detail_id,
    e01,
    e02,
    e03,
    e04,
    ''01'' || to_char(row_no, ''-0000'') || to_char(table_no, ''-0000'') AS row_id
  FROM
    (
      SELECT
        detail_id,
        e01,
        e02,
        e03,
        e04,
        table_no,
        row_no
      FROM
        (
          SELECT
            *,
            ''0'' AS grouping_type
          FROM
            actions_all
          UNION ALL
          SELECT
            *,
            ''1'' AS grouping_type
          FROM
            agg_actions_all
        ) AS act
      WHERE
        act.grouping_type = (
          SELECT
            value
          FROM
            grouping_dispose_activity
          LIMIT
            1
        )
      UNION ALL
      SELECT
        detail_id,
        e01,
        e02,
        e03,
        e04,
        table_no,
        row_no
      FROM
        (
          SELECT
            *,
            ''0'' AS grouping_type
          FROM
            materials_all
          UNION ALL
          SELECT
            *,
            ''1'' AS grouping_type
          FROM
            agg_materials_all
        ) AS mat
      WHERE
        mat.grouping_type = (
          SELECT
            value
          FROM
            grouping_dispose_activity
          LIMIT
            1
        )
      UNION ALL
      SELECT
        *
      FROM
        delimiter_actions
    ) AS medi_information_normal_all
  ORDER BY
    row_no,
    table_no
),
oxygen_technique AS (
  --　酸素手技
  SELECT
    ''酸素手技'' AS detail_id,
    (
      SELECT
        value
      FROM
        oxygen_inhalation
      WHERE
        key2 = ''OXYGEN_ACTION_CD''
      LIMIT
        1
    ) AS e01,
    ''酸素吸入'' AS e02,
    ''1'' AS e03,
    NULL AS e04,
    13 AS table_no,
    oxy.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_treatment_info :: json) WITH ORDINALITY AS oxy(val, idx)
  WHERE
    COALESCE(oxy.val ->> ''oxygen_amount'', ''end'') = ''end''
    AND oxy.val ->> ''treat_class'' = ''3''
    AND ord.ord_no = @ordNo
    AND EXISTS (
      SELECT
        value
      FROM
        oxygen_inhalation
      WHERE
        key2 = ''OXYGEN_INHALATION''
        AND value IS NOT NULL
        AND value != ''''
      LIMIT
        1
    )
), oxygen_volume AS (
  --　酸素吸入量
  SELECT
    ''酸素吸入量'' AS detail_id,
    (
      SELECT
        value
      FROM
        oxygen_inhalation
      WHERE
        key2 = ''OXYGEN_INHALATION''
      LIMIT
        1
    ) AS e01,
    ''酸素吸入'' AS e02,
    TRIM(
      to_char(
        to_number(oxy.val ->> ''oxygen_amount'', ''999999.99''),
        ''999990.99''
      )
    ) AS e03,
    ''L'' AS e04,
    14 AS table_no,
    oxy.idx AS row_no
  FROM
    ord_main_max AS ord
    CROSS JOIN lateral json_array_elements (ord.rst_treatment_info :: json) WITH ORDINALITY AS oxy(val, idx)
  WHERE
    COALESCE(oxy.val ->> ''oxygen_amount'', ''end'') <> ''end''
    AND oxy.val ->> ''treat_class'' = ''3''
    AND ord.ord_no = @ordNo
    AND EXISTS (
      SELECT
        value
      FROM
        oxygen_inhalation
      WHERE
        key2 = ''OXYGEN_INHALATION''
        AND value IS NOT NULL
        AND value != ''''
      LIMIT
        1
    )
), 
agg_oxygen_technique AS (
  SELECT
	detail_id,
	e01,
	e02,
	e03,
	e04,
	table_no,
	min(row_no)
  FROM
	oxygen_technique
  GROUP BY
	detail_id,
	e01,
	e02,
	e03,
	e04,
	table_no
),
agg_oxygen_volume AS (
  SELECT
	detail_id,
	e01,
	e02,
	TRIM(to_char(sum(to_number(e03, ''99999.99'')), ''999990.99'')) as e03,
	e04,
	table_no,
	min(row_no)
  FROM
	oxygen_volume
  GROUP BY
	detail_id,
	e01,
	e02,
	e04,
	table_no
),
delimiter_oxygen AS (
  -- 酸素情報_区切り
  SELECT
    ''区切り'' AS detail_id,
    ''000000'' AS e01,
    ''区切り'' AS e02,
    ''1'' AS e03,
    NULL AS e04,
    15 AS table_no,
    row_no -1 AS row_no
  FROM
    (
      SELECT
        *,
        ''0'' AS grouping_type
      FROM
        oxygen_technique
      UNION ALL
      SELECT
        *,
        ''1'' AS grouping_type
      FROM
        agg_oxygen_technique
    ) AS oxy_tec
  WHERE
    oxy_tec.grouping_type = (
      SELECT
        value
      FROM
        grouping_dispose_activity
      LIMIT
        1
    )
  ORDER BY
    row_no OFFSET 1
),
oxygen_info AS (
  -- 酸素手技、酸素吸入量、区切りを連結
  SELECT
    detail_id,
    e01,
    e02,
    e03,
    e04,
    ''05'' || to_char(row_no, ''-0000'') || to_char(table_no, ''-0000'') AS row_id
  FROM
    (
    SELECT
        detail_id,
        e01,
        e02,
        e03,
        e04,
        table_no,
        row_no
      FROM
      (
      	SELECT
          *,
          ''0'' AS grouping_type
        FROM
          oxygen_technique
      	union all
      	SELECT
          *,
          ''1'' AS grouping_type
        FROM
          agg_oxygen_technique
      ) AS oxy_tec
       WHERE
        oxy_tec.grouping_type = (
          SELECT
            value
          FROM
            grouping_dispose_activity
          LIMIT
            1
        )
      UNION ALL
      SELECT
        detail_id,
        e01,
        e02,
        e03,
        e04,
        table_no,
        row_no
      FROM
        (
      SELECT
        *,
        ''0'' AS grouping_type
      FROM
        oxygen_volume
      UNION ALL
      SELECT
            *,
            ''1'' AS grouping_type
          FROM
            agg_oxygen_volume
        ) AS oxy_vol
       WHERE
        oxy_vol.grouping_type = (
          SELECT
            value
          FROM
            grouping_dispose_activity
          LIMIT
            1
        )
      UNION ALL
      SELECT
        *
      FROM
        delimiter_oxygen
    ) AS oxygen_all
  ORDER BY
    row_no,
    table_no
),
delimiter_all AS (
  SELECT
    ''区切り'' AS detail_id,
    ''000000'' AS e01,
    ''区切り'' AS e02,
    ''1'' AS e03,
    NULL AS e04
),
union_all_tables AS (
  SELECT
    *
  FROM
    actions_materials_all
  UNION ALL
  SELECT
    *,
    ''04'' || to_char(
      (
        SELECT
          count(row_id) + 1
        FROM
          actions_materials_all
      ),
      ''-0000''
    ) AS row_id
  FROM
    delimiter_all
  WHERE
    EXISTS (
      SELECT
        1
      FROM
        actions_materials_all
    )
  UNION ALL
    -- 酸素情報
  SELECT
    *
  FROM
    oxygen_info
),
with_cost_no AS (
  SELECT
    *,
    ROW_NUMBER() OVER(
      ORDER BY
        row_id
    ) AS cost_no
  FROM
    union_all_tables
  ORDER BY
    row_id
),
total AS (
  SELECT
    COUNT(*) AS total_rows
  FROM
    with_cost_no
),
last_divider AS (
  SELECT
    MAX(cost_no) AS max_row
  FROM
    with_cost_no
  WHERE
    e02 = ''区切り''
) -- 最後の行が区切りの場合は除外する
SELECT
  *
FROM
  with_cost_no
WHERE
  cost_no != (
    CASE
      WHEN (
        SELECT
          total_rows
        FROM
          total
      ) = (
        SELECT
          max_row
        FROM
          last_divider
      ) THEN (
        SELECT
          max_row
        FROM
          last_divider
      )
      ELSE 0
    end
  )',2,'[{}]','1','{"applications": [4]}',NULL,'SSI)実績処置繰り返し部','2020-05-20 19:57:15.246',CURRENT_TIMESTAMP,NULL);
