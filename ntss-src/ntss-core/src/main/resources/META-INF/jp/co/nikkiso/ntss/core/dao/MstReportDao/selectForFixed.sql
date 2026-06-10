SELECT * FROM(
    SELECT
        CAST(
            CASE
                WHEN A.facility_setting_no IS NULL THEN B.default_value::JSONB ->> 'report_cd'
                ELSE A.value::JSONB ->> 'report_cd'
            END
        AS NUMERIC) AS report_cd,
        CASE
            WHEN A.facility_cd IS NULL THEN /*facilityCd*/null
            ELSE A.facility_cd
        END AS facility_cd,
        CASE
            WHEN A.facility_setting_no IS NULL THEN B.default_value::JSONB ->> 'report_name'
            ELSE A.value::JSONB ->> 'report_name'
        END AS report_name,
        NULL AS report_path,
        CAST(
            CASE
                WHEN A.facility_setting_no IS NULL THEN B.default_value::JSONB ->> 'report_class'
                ELSE A.value::JSONB ->> 'report_class'
            END
        AS NUMERIC) AS report_class,
        CASE
            WHEN A.facility_setting_no IS NULL THEN B.default_value::JSONB ->> 'is_disp'
            ELSE A.value::JSONB ->> 'is_disp'
        END AS is_disp,
        '0' AS is_del,
        CASE
            WHEN A.reg_date IS NULL THEN B.reg_date
            ELSE A.reg_date
        END As reg_date,
        CASE
            WHEN A.up_date IS NULL THEN B.up_date
            ELSE A.up_date
        END As up_date,
        0 AS report_type,
        NULL AS extraction_condition,
        CAST(
            CASE
                WHEN A.facility_setting_no IS NULL THEN B.default_value::JSONB ->> 'default_printer'
                ELSE A.value::JSONB ->> 'default_printer'
            END
        AS NUMERIC) AS default_printer,
        NULL AS additional_info,
        CAST(
        CASE
            WHEN A.facility_setting_no IS NULL THEN B.default_value::JSONB ->> 'disp_order'
            ELSE A.value::JSONB ->> 'disp_order'
        END
        AS NUMERIC) AS disp_order,
        NULL AS report_hst_info
    FROM ntss.mst_facility_setting A
    RIGHT OUTER JOIN ntss.sys_facility_setting B ON A.facility_setting_no = B.facility_setting_no
    AND
        A.facility_cd = /*facilityCd*/null
    WHERE
        B.facility_setting_no = /*facilitySettingNo*/'0'
) a
WHERE report_cd IS NOT NULL
/*%if is_disp != null*/
AND
  is_disp = /*is_disp*/null
/*%end*/
/*%if is_del != null*/
AND
  is_del = /*is_del*/null
/*%end*/
;
