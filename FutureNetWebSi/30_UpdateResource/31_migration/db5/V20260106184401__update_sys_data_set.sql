DELETE FROM sys_data_set
WHERE sql_cd IN (-604180,-604181);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604180, '-- 【SQL_CD=-604180】
WITH idx AS (
    SELECT
          ms.code,
        ROW_NUMBER() OVER () AS idx
    FROM
          mst_selector mss
    CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT)
    WHERE
          facility_cd = @facilityCd
        AND master_physical_name = ''mst_addition''
)
    SELECT
        m_add.in_hospital_cd_1 AS ad_in_hospital_cd
FROM
        ord_main
CROSS JOIN LATERAL json_array_elements(ord_main.addition_info :: json) ord_addition_info
JOIN idx ON
    ord_addition_info ->> ''cd'' = idx.code::text
JOIN mst_addition m_add ON
    ord_addition_info ->> ''cd'' = m_add.addition_cd::text
    AND m_add.is_disp = ''1''
    AND m_add.is_del = ''0''
WHERE
        ord_main.facility_cd = @facilityCd
    AND ord_main.ord_no = @ordNo
    AND ord_main.is_del = ''0''
    AND m_add.in_hospital_cd_1 IS NOT NULL
ORDER BY
    idx.idx ASC', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析条件_加算)', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-604181, '-- 【SQL_CD=-604181】
WITH ord_main_max AS (
    (
      SELECT
        ord.addition_info,
        ord.del_date as up_date
      FROM
        ord_main_restore AS ord,
        sys_coop_journal as journal
      WHERE
        ord.facility_cd = @facilityCd
        AND ord.ord_no = @ordNo
        AND ord.is_del = ''0''
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
        ord.addition_info,
        ord.rst_edition_date as up_date
      FROM
        ord_main AS ord
      WHERE
        ord.facility_cd = @facilityCd
        AND ord.ord_no = @ordNo
        AND ord.is_del = ''0''
    )
    ORDER BY
      up_date DESC NULLS LAST
    LIMIT
      1
  )
,idx AS (
    SELECT
          ms.code,
        ROW_NUMBER() OVER () AS idx
    FROM
          mst_selector mss
    CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT)
    WHERE
          facility_cd = @facilityCd
        AND master_physical_name = ''mst_addition''
)
    SELECT
        m_add.in_hospital_cd_1 AS ad_in_hospital_cd
FROM
        ord_main_max
CROSS JOIN LATERAL json_array_elements(ord_main_max.addition_info :: json) ord_addition_info
JOIN idx ON
    ord_addition_info ->> ''cd'' = idx.code::text
JOIN mst_addition m_add ON
    ord_addition_info ->> ''cd'' = m_add.addition_cd::text
    AND m_add.is_disp = ''1''
    AND m_add.is_del = ''0''
WHERE
        m_add.in_hospital_cd_1 IS NOT NULL
ORDER BY
    idx.idx ASC', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'CSI透析実績(透析条件_加算)削除用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);