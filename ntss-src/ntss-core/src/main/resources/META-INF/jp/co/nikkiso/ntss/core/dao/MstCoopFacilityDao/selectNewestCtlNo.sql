SELECT
    a.ctl_no
FROM
    mst_coop_facility a
    , (
        SELECT
            facility_cd
            , max(up_date) AS up_date
        FROM
            mst_coop_facility
        GROUP BY
            facility_cd
    ) AS b
WHERE
    b.facility_cd = a.facility_cd
    AND b.up_date = a.up_date
    AND a.is_del = '0'
    AND a.is_disp = '1';