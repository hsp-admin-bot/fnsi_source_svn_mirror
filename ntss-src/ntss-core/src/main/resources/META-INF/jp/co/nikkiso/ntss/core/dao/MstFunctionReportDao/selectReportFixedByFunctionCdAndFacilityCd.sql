select
  A.*
from
  mst_function_report A,
  (
    SELECT * FROM(
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
  ) B
where
  A.function_cd = /*functionCd*/null
and
  A.facility_cd = /*facilityCd*/null
and
  A.is_disp = '1'
and
  A.is_del = '0'
and
  A.report_cd = B.report_cd
;
