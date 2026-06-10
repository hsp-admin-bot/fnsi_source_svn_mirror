SELECT DISTINCT
    facility_cd
FROM
    mnt_facility_cancel_manage
WHERE
        st_date <= now( )
  AND proc_class <> '3'
  AND proc_class <> '4'
