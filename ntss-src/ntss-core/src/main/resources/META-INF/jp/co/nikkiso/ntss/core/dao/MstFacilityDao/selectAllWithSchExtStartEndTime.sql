SELECT
  facility_cd,
  sch_ext_start_time,
  sch_ext_end_time
FROM
  (
    SELECT
      A.facility_cd,
      CASE
        WHEN B.value IS NOT NULL THEN B.value
        ELSE D.default_value
      END sch_ext_start_time,
      CASE
        WHEN C.value IS NOT NULL THEN C.value
        ELSE E.default_value
      END sch_ext_end_time
    FROM
      mst_facility A
      LEFT JOIN
        mst_facility_setting B ON
        A.facility_cd = B.facility_cd AND
        B.facility_setting_no = '1031'
      LEFT JOIN
        mst_facility_setting C ON
        A.facility_cd = C.facility_cd AND
        C.facility_setting_no = '1032'
      LEFT JOIN
        sys_facility_setting D ON
        D.facility_setting_no = '1031'
      LEFT JOIN
        sys_facility_setting E ON
        E.facility_setting_no = '1032'
    ORDER BY
      A.facility_cd
  ) F
WHERE
  F.sch_ext_start_time <= to_char(CURRENT_TIMESTAMP, 'HH24MI') AND
  F.sch_ext_end_time > to_char(CURRENT_TIMESTAMP, 'HH24MI')
;
