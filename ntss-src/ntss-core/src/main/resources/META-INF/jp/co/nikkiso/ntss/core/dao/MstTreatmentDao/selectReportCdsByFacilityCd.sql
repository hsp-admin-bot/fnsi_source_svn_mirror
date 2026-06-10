SELECT
  DISTINCT report_cd
FROM
  (
    SELECT
      report_id AS report_cd
    FROM
      mst_treatment
    WHERE
      facility_cd = /*facilityCd*/null
    AND
      is_disp = '1'
    AND
      is_del = '0'

    UNION ALL

    SELECT
      report_id_hw AS report_cd
    FROM
      mst_treatment
    WHERE
      facility_cd = /*facilityCd*/null
    AND
      is_disp = '1'
    AND
      is_del = '0'

    UNION ALL

    SELECT
      report_id_bw AS report_cd
    FROM
      mst_treatment
    WHERE
      facility_cd = /*facilityCd*/null
    AND
      is_disp = '1'
    AND
      is_del = '0'

    UNION ALL

    SELECT
      report_id_aw AS report_cd
    FROM
      mst_treatment
    WHERE
      facility_cd = /*facilityCd*/null
    AND
      is_disp = '1'
    AND
      is_del = '0'

    UNION ALL

    SELECT
      report_id_dev AS report_cd
    FROM
      mst_treatment
    WHERE
      facility_cd = /*facilityCd*/null
    AND
      is_disp = '1'
    AND
      is_del = '0'

    UNION ALL

    SELECT
      report_id_act AS report_cd
    FROM
      mst_treatment
    WHERE
      facility_cd = /*facilityCd*/null
    AND
      is_disp = '1'
    AND
      is_del = '0'
  ) T
WHERE
  report_cd IS NOT NULL
;
