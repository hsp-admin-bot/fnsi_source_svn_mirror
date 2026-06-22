SELECT
    a.ctl_no
FROM
    mst_coop_filename a
    , (
        SELECT
            facility_cd
            , coop_cd
            , coop_cd_index
            , coop_version
            , max(up_date) AS up_date
        FROM
            mst_coop_filename
        WHERE
            facility_cd = /*facilityCd*/null
        GROUP BY
            facility_cd
            , coop_cd
            , coop_cd_index
            , coop_version
    ) AS b
WHERE
    a.facility_cd = /*facilityCd*/null
    AND b.facility_cd = a.facility_cd
    AND b.coop_cd = a.coop_cd
    AND b.coop_cd_index = a.coop_cd_index
    AND b.coop_version = a.coop_version
    AND b.up_date = a.up_date;
