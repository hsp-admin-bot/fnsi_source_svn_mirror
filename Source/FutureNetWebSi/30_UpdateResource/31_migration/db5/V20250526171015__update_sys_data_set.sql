DELETE FROM ntss.sys_data_set WHERE sql_cd IN (-301,-501103);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-301, 'WITH ord_main_max AS (
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
    AND COALESCE(mmd.in_hospital_cd_2, '''') <> ''''
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
    AND COALESCE(mmd.in_hospital_cd_1, '''') <> ''''
    AND COALESCE(mmd.in_hospital_cd_2, '''') <> ''''
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
    AND COALESCE(mmx.in_hospital_cd_2, '''') <> ''''
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
    AND COALESCE(mmd.in_hospital_cd_1, '''') <> ''''
    AND COALESCE(mmx.in_hospital_cd_2, '''') <> ''''
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
    AND COALESCE(mmd.in_hospital_cd_2, '''') <> ''''
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
    AND COALESCE(mmd.in_hospital_cd_2, '''') <> ''''
    AND COALESCE(mmd.in_hospital_cd_1, '''') <> ''''
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
    AND COALESCE(mmx.in_hospital_cd_2, '''') <> ''''
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
    AND COALESCE(mmd.in_hospital_cd_1, '''') <> ''''
    AND COALESCE(mmx.in_hospital_cd_2, '''') <> ''''
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
  )', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'SSI)実績処置繰り返し部', '2020-05-20 19:57:15.246', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501103, 'WITH  ord_main_max AS (
    (
      SELECT
        ord.ord_no,
        ord.del_date as up_date,
        ord.rst_medi_info,
        ord.rst_treatment_info
      FROM
        ord_main_restore AS ord,
        sys_coop_journal as journal
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
        ord.rst_edition_date as up_date,
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
  )
,coop_ini as (
  SELECT COALESCE
      ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS value
  FROM
      mst_coop_ini AS ini
      CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
  WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND COALESCE(info->>''key0'','''') = @key0
    AND info ->> ''key1'' = ''SSI_DIALYSIS_SEND''
    AND info ->> ''key2'' = ''MEDICINE_RESOLVE_MODE''
),medi_order_data AS (
  SELECT
    ROW_NUMBER () OVER () AS no2
    , TO_NUMBER(datt.a1  :: text, ''999999999999'') AS ora
  FROM (
    SELECT TO_NUMBER((unnest(string_to_array((
      SELECT mst_f.value AS rtt
      FROM mst_facility_setting AS mst_f
      WHERE mst_f.facility_setting_no = ''3007'' AND mst_f.facility_cd = @facilityCd
    ),'',''))), ''999999999999'') AS a1) AS datt
)
select
    cost_fin.*,
    to_char(row_number() over( ORDER BY
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 6 THEN cost_fin.interval_no END,
    CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 0 THEN cost_fin.medi_reg_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 1 THEN cost_fin.medi_class_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 2 THEN cost_fin.medicine_type
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 3 THEN cost_fin.medi_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 4 THEN cost_fin.timing_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 5 THEN cost_fin.procedure_code_order
        WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 6 THEN cost_fin.interval_no END, cost_fin.medi_code_order
  ),''FM9999'') as cost_no
from
(
select
    all_cost.*,
    ROW_NUMBER() OVER(ORDER BY all_cost.medi_reg_order_text) AS medi_reg_order
from
(
WITH medi_order AS (
  SELECT
    index_no AS medi_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicine''
)
, medi_mix_order AS (
  SELECT
    index_no AS medi_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicine_mix''
)
, medi_class_order AS (
  SELECT
    index_no AS medi_class_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS medi_class_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicine_class''
)
, timing_order AS (
  SELECT
    index_no AS timing_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS timing_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_medicate_timing''
)
, procedure_order AS (
  SELECT
    index_no AS procedure_code_order
    , TO_NUMBER(order_cd ->> ''code'', ''999999999999'') AS procedure_code
  FROM mst_selector
  CROSS JOIN LATERAL jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(order_cd, index_no)
  WHERE facility_cd = @facilityCd
    AND master_physical_name = ''mst_procedure''
)
, mst_medi AS (
  SELECT
    medicine_cd
    , medicine_name
    , class_cd
    , unit
    , in_hospital_cd_1
    , in_hospital_cd_2
    , medi_order.medi_code_order
    , medi_class_order.medi_class_code_order
  FROM mst_medicine mmd
  LEFT JOIN medi_order ON mmd.medicine_cd = medi_order.medi_code
  LEFT JOIN medi_class_order ON mmd.class_cd = medi_class_order.medi_class_code
  WHERE facility_cd = @facilityCd
)
select --投与薬剤情報(通常)
    ''投与薬剤'' as detail_id,
    mmd.in_hospital_cd_1 as e01,
    t.medi ->> ''name'' as e02,
    t.medi ->> ''class_name'' as e03,
    to_char(to_number(t.medi ->>''amount'',''99999.99'') ,''FM99990.00'')  as e04,
    t.medi ->> ''unit''as e05,
    mp.in_hospital_cd_a1 as e06,
    mp.pricedure_name as e07,
    ''1'' || TO_CHAR(t.idx,''FM0000'') AS medi_reg_order_text,
    mmd.medi_code_order AS medi_code_order,
    mmd.medi_class_code_order AS medi_class_code_order,
    1 AS medicine_type,
    tio.timing_code_order AS timing_code_order,
    pro.procedure_code_order AS procedure_code_order,
    (t.medi ->> ''date_interval'') ::int AS interval_no
    from
      ord_main_max as ord
    cross join lateral
      json_array_elements (ord.rst_medi_info :: json) WITH ORDINALITY AS t(medi, idx)
    left outer join
      mst_medi as mmd
    on
      mmd.medicine_cd = TO_NUMBER (t.medi ->> ''cd'',''999999999999'')
    left outer join
      mst_procedure as mp
    on
      mp.procedure_cd = TO_NUMBER (t.medi ->> ''procedure_cd'',''999999999999'')
  and
      COALESCE(mp.in_hospital_cd_a1, '''') <> ''''
    left outer join
      timing_order as tio
    on
      tio.timing_code = TO_NUMBER(t.medi ->> ''timing_cd'', ''FM999999999999'') 
    left outer join
      procedure_order as pro 
    on
      pro.procedure_code = TO_NUMBER(t.medi ->> ''procedure_cd'', ''FM999999999999'') 
    where
      t.medi ->> ''effect_flg'' = ''1'' and
      t.medi ->> ''medicine_type'' = ''1'' and
      COALESCE(mmd.in_hospital_cd_1, '''') <> '''' and
      COALESCE(mmd.in_hospital_cd_2, '''') = '''' and
      ord.ord_no = @ordNo
    --order by medi ->> ''effect_date'',medi ->> ''cd''

union

select --投与薬剤情報(調製)分解
     ''投与薬剤'' as detail_id,
    mmd.in_hospital_cd_1 as e01,
    mmd.medicine_name as e02,
    mmdc.class_name as e03 ,
    COALESCE((case mmxd->>''solvent'' when ''1'' then to_char(to_number(mmxd->>''amount'',''99999.99''),''FM99990.00'') else to_char(TRUNC(to_number(t.medi ->> ''amount'',''99999.99'') * to_number(mmxd->>''amount'',''99999.99''),2),''FM99990.00'') end),''0.00'') as e04,
    mmd.unit as e05,
    mp.in_hospital_cd_a1 as e06,
    mp.pricedure_name as e07,
  ''1'' || TO_CHAR(t.idx,''FM0000'') AS medi_reg_order_text,
  mmd.medi_code_order AS medi_code_order,
  mmd.medi_class_code_order AS medi_class_code_order,
  2 AS medicine_type,
  tio.timing_code_order AS timing_code_order,
  pro.procedure_code_order AS procedure_code_order,
  (t.medi ->> ''date_interval'') ::int AS interval_no
  from
    ord_main_max as ord
  cross join lateral
    json_array_elements (ord.rst_medi_info :: json) WITH ORDINALITY AS t(medi, idx)
    left outer join
      mst_procedure as mp
    on
      mp.procedure_cd = TO_NUMBER (t.medi ->> ''procedure_cd'',''999999999999'')
  and
      COALESCE(mp.in_hospital_cd_a1, '''') <> ''''
    left outer join
      mst_medicine_mix as mmx
    on
      mmx.medicine_mix_cd = TO_NUMBER (t.medi ->> ''cd'',''999999999999'')
    left outer join
    timing_order as tio
  on
    tio.timing_code = TO_NUMBER(t.medi ->> ''timing_cd'', ''FM999999999999'') 
  left outer join
    procedure_order as pro 
  on
    pro.procedure_code = TO_NUMBER(t.medi ->> ''procedure_cd'', ''FM999999999999'')

    cross join lateral
      json_array_elements (mmx.mix_info :: json) mmxd
    left outer join
      mst_medi as mmd
    on
      mmd.medicine_cd = TO_NUMBER (mmxd ->> ''cd'',''999999999999'')
    left outer join
      mst_medicine_class as mmdc
    on
      mmdc.class_cd = mmd.class_cd
    where
      medi ->> ''effect_flg'' = ''1'' and
      medi ->> ''medicine_type'' = ''2'' and
      COALESCE(mmd.in_hospital_cd_1, '''') <> '''' and
    ord.ord_no = @ordNo and
    (select value from coop_ini) = ''1''

union

select --投与薬剤情報(調製)セット
     ''投与薬剤'' as detail_id,
    mmx.in_hospital_cd_1 as e01,
    mmx.medicine_mix_name as e02,
    mmdc.class_name as e03 ,
    COALESCE((to_char(to_number(t.medi ->> ''amount'',''99999.99''),''FM99990.00'')),''0.00'') as e04,
    mmx.unit as e05,
    mp.in_hospital_cd_a1 as e06,
    mp.pricedure_name as e07,
  ''1'' || TO_CHAR(t.idx,''FM0000'') AS medi_reg_order_text,
  medi_order.medi_code_order AS medi_code_order,
  medi_class_order.medi_class_code_order AS medi_class_code_order,
  2 AS medicine_type,
  tio.timing_code_order AS timing_code_order,
  pro.procedure_code_order AS procedure_code_order,
  (t.medi ->> ''date_interval'') ::int AS interval_no
  from
    ord_main_max as ord
  cross join lateral
    json_array_elements (ord.rst_medi_info :: json) WITH ORDINALITY AS t(medi, idx)
    left outer join
      mst_procedure as mp
    on
      mp.procedure_cd = TO_NUMBER (t.medi ->> ''procedure_cd'',''999999999999'')
  and
      COALESCE(mp.in_hospital_cd_a1, '''') <> ''''
    left outer join
      mst_medicine_mix as mmx
    on
      mmx.medicine_mix_cd = TO_NUMBER (t.medi ->> ''cd'',''999999999999'')
    left outer join
      timing_order as tio
  on
    tio.timing_code = TO_NUMBER(t.medi ->> ''timing_cd'', ''FM999999999999'') 
  left outer join
    procedure_order as pro 
  on
    pro.procedure_code = TO_NUMBER(t.medi ->> ''procedure_cd'', ''FM999999999999'')
  left outer join
    mst_medicine_class as mmdc
  on
    mmdc.class_cd = mmx.class_cd
  LEFT JOIN medi_order ON mmx.medicine_mix_cd = medi_order.medi_code
  LEFT JOIN medi_class_order ON mmx.class_cd = medi_class_order.medi_class_code
  where
    medi ->> ''effect_flg'' = ''1'' and
    medi ->> ''medicine_type'' = ''2'' and
    COALESCE(mmx.in_hospital_cd_2, '''') = '''' and
    ord.ord_no = @ordNo and
    (select value from coop_ini) = ''0''

union

select --処置薬剤情報
    ''処置薬剤'' as detail_id,
    mmd.in_hospital_cd_1 as e01,
    t.tmedi ->> ''treat_medicine_name'' as e02,
    mmdc.class_name as e03 ,
    to_char(to_number(t.tmedi ->> ''amount'',''99999.99'') ,''FM99990.00'') as e04,
    t.tmedi ->> ''unit'' as e05,
    mp.in_hospital_cd_a1 as e06,
  t.tmedi ->> ''procedure_name'' as e07,
    ''2'' || TO_CHAR(t.idx,''FM0000'') AS medi_reg_order_text,
    mmd.medi_code_order AS medi_code_order,
    mmd.medi_class_code_order AS medi_class_code_order,
    TO_NUMBER(t.tmedi ->> ''medicine_type'' , ''FM9999'') AS medicine_type,
    tio.timing_code_order AS timing_code_order,
    pro.procedure_code_order AS procedure_code_order,
    (t.tmedi ->> ''date_interval'') ::int AS interval_no
    from
      ord_main_max as ord
    cross join lateral
      json_array_elements (ord.rst_treatment_info :: json) WITH ORDINALITY AS t(tmedi, idx)
    left outer join
      mst_medi as mmd
    on
      mmd.medicine_cd = TO_NUMBER (t.tmedi ->> ''treat_medicine_cd'',''999999999999'')
    left outer join
      mst_medicine_class as mmdc
    on
      mmdc.class_cd = mmd.class_cd
    left outer join
      mst_procedure as mp
    on
      mp.procedure_cd = TO_NUMBER (t.tmedi ->> ''procedure_cd'',''999999999999'')
  and
      COALESCE(mp.in_hospital_cd_a1, '''') <> ''''
    left outer join
      timing_order as tio
    on
      tio.timing_code = TO_NUMBER(t.tmedi ->> ''timing_cd'', ''FM999999999999'') 
    left outer join
      procedure_order as pro 
    on
      pro.procedure_code = TO_NUMBER(t.tmedi ->> ''procedure_cd'', ''FM999999999999'')
    where
      COALESCE(mmd.in_hospital_cd_2, '''') = '''' and
      ord.ord_no = @ordNo
) all_cost

where
 all_cost.e01 is not null
) cost_fin
ORDER BY
CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 0 THEN cost_fin.medi_reg_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 1 THEN cost_fin.medi_class_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 2 THEN cost_fin.medicine_type
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 3 THEN cost_fin.medi_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 4 THEN cost_fin.timing_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 5 THEN cost_fin.procedure_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 1) = 6 THEN cost_fin.interval_no END,
CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 0 THEN cost_fin.medi_reg_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 1 THEN cost_fin.medi_class_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 2 THEN cost_fin.medicine_type
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 3 THEN cost_fin.medi_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 4 THEN cost_fin.timing_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 5 THEN cost_fin.procedure_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 2) = 6 THEN cost_fin.interval_no END,
CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 0 THEN cost_fin.medi_reg_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 1 THEN cost_fin.medi_class_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 2 THEN cost_fin.medicine_type
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 3 THEN cost_fin.medi_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 4 THEN cost_fin.timing_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 5 THEN cost_fin.procedure_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 3) = 6 THEN cost_fin.interval_no END,
CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 0 THEN cost_fin.medi_reg_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 1 THEN cost_fin.medi_class_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 2 THEN cost_fin.medicine_type
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 3 THEN cost_fin.medi_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 4 THEN cost_fin.timing_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 5 THEN cost_fin.procedure_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 4) = 6 THEN cost_fin.interval_no END,
CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 0 THEN cost_fin.medi_reg_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 1 THEN cost_fin.medi_class_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 2 THEN cost_fin.medicine_type
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 3 THEN cost_fin.medi_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 4 THEN cost_fin.timing_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 5 THEN cost_fin.procedure_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 5) = 6 THEN cost_fin.interval_no END,
CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 0 THEN cost_fin.medi_reg_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 1 THEN cost_fin.medi_class_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 2 THEN cost_fin.medicine_type
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 3 THEN cost_fin.medi_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 4 THEN cost_fin.timing_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 5 THEN cost_fin.procedure_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 6) = 6 THEN cost_fin.interval_no END,
CASE WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 0 THEN cost_fin.medi_reg_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 1 THEN cost_fin.medi_class_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 2 THEN cost_fin.medicine_type
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 3 THEN cost_fin.medi_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 4 THEN cost_fin.timing_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 5 THEN cost_fin.procedure_code_order
    WHEN (SELECT ora FROM medi_order_data WHERE no2 = 7) = 6 THEN cost_fin.interval_no END, cost_fin.medi_code_order', 2, '[{}]'::jsonb, '1', '{"applications": [4]}'::jsonb, NULL, 'SSI)実績）薬剤繰り返し部', '2025-03-17 09:41:58.788', CURRENT_TIMESTAMP, NULL);