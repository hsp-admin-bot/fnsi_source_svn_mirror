-- sys_monitor_item の 血圧の data_type 修正に伴い、既存データの更新が必要
UPDATE
  mst_treatment_status_layout
SET
  dcs_view_items = tbe.dcs_view_items,
  up_date = now()
FROM (
  SELECT
    tbd.layout_no,
    json_agg(tbd.dcsa) AS dcs_view_items
  FROM (
    SELECT
      tbc.layout_no,
      tbc.dcsa
    FROM (
      SELECT
        tba.layout_no,
        tba.dcsa
      FROM (
        SELECT
          layout_no,
          jsonb_array_elements(dcs_view_items) AS dcsa
        FROM
          mst_treatment_status_layout
      ) AS tba
      WHERE
        ( tba.dcsa->>'key_name' IS NULL OR tba.dcsa->>'key_name' NOT IN ('110', '111', '112', '113', '114', '115', '116', '117'))
      AND
        layout_no IN (
          SELECT
            tb1.layout_no
          FROM (
            SELECT
              layout_no,
              jsonb_array_elements(dcs_view_items) AS dcs1
            FROM
              mst_treatment_status_layout
          ) AS tb1
          WHERE
            tb1.dcs1->>'key_name' IN ('110', '111', '112', '113', '114', '115', '116', '117')
          GROUP BY
            tb1.layout_no
        )
      UNION
      SELECT
        tbb.layout_no,
        tbb.dcsb || json_build_object('data_type', '1')::jsonb
      FROM (
        SELECT
          layout_no,
          jsonb_array_elements(dcs_view_items) AS dcsb
        FROM
          mst_treatment_status_layout
      ) AS tbb
      WHERE
        tbb.dcsb->>'key_name' IN ('110', '111', '112', '113', '114', '115', '116', '117')
      AND
        layout_no IN (
          SELECT
            layout_no
          FROM (
            SELECT
              layout_no,
              jsonb_array_elements(dcs_view_items) AS dcs1
            FROM
              mst_treatment_status_layout
          ) AS tb1
          WHERE
            tb1.dcs1->>'key_name' IN ('110', '111', '112', '113', '114', '115', '116', '117')
          GROUP BY
            tb1.layout_no
        )
    ) AS tbc
    ORDER BY
      tbc.layout_no,
      (tbc.dcsa->>'order_no')::integer
  ) AS tbd
  GROUP BY
    tbd.layout_no
) AS tbe
WHERE
  mst_treatment_status_layout.layout_no = tbe.layout_no
;
