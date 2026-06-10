select
  A.*
from
  mst_function_report A,
  (
    SELECT * FROM(
      SELECT
        report_cd,
        report_class
      FROM
        mst_report
      UNION ALL
      SELECT
        CAST(sfs.default_value::JSONB ->> 'report_cd' AS NUMERIC) AS report_cd,
        CAST(sfs.default_value::JSONB ->> 'report_class' AS NUMERIC) AS report_class
      FROM ntss.sys_facility_setting sfs
      WHERE
        sfs.facility_setting_no in /*facilitySettingNos*/(0)
    ) rep,
    (
      SELECT
        C.setting ->> 'report_class' AS class
      FROM
        ( SELECT json_array_elements ( ( print_report_class :: json ) :: json ) AS setting FROM sys_report_setting WHERE function_cd = /*functionCd*/null ) C
      WHERE
        C.setting ->> 'disp_status' = /*printFlag*/'0'
    ) D
    WHERE
      POSITION(','||rep.report_class||',' IN ','||D.class||',') >0
  ) B,
  (
    SELECT
      ms.*, row_number() over() AS index
    FROM
      mst_selector mss
    CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings->'items') AS ms
    (
      code bigint,
      name text
    )
    WHERE
      facility_cd = /*facilityCd*/null
    AND master_physical_name = 'mst_function_report'
  ) ms
WHERE
  A.function_cd = /*functionCd*/null
AND
  A.facility_cd = /*facilityCd*/null
AND
  A.report_cd = B.report_cd
AND
  A.function_report_cd = ms.code
/*%if is_disp != null*/
AND
  A.is_disp = /*is_disp*/null
/*%end*/
/*%if is_del != null*/
AND
  A.is_del = /*is_del*/null
/*%end*/
ORDER BY ms.index
;
