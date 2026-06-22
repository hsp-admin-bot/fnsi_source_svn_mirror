SELECT
    a.ctl_no
FROM
    mst_coop_layout_detail a
    , (
        SELECT
            facility_cd
            , coop_cd
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
            , coop_version
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            , direction
            , coop_cd_detail
            , coop_cd_detail_sub
            , coop_name
            , description
            , max(up_date) AS up_date
        FROM
            mst_coop_layout_detail
        WHERE
            facility_cd = /*facilityCd*/null
        GROUP BY
            facility_cd
            , coop_cd
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
            , coop_version
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            , direction
            , coop_cd_detail
            , coop_cd_detail_sub
            , coop_name
            , description
    ) AS b
WHERE
    a.facility_cd = /*facilityCd*/null
    AND b.facility_cd = a.facility_cd
    AND b.coop_cd = a.coop_cd
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    AND b.coop_version = a.coop_version
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    AND b.direction = a.direction
    AND b.coop_cd_detail = a.coop_cd_detail
    AND b.coop_cd_detail_sub = a.coop_cd_detail_sub
    AND b.coop_name = a.coop_name
    AND b.description = a.description
    AND b.up_date = a.up_date;
