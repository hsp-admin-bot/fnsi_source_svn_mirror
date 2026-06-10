SELECT
    a.ctl_no
FROM
    mst_coop_distribute a
    , (
        SELECT
            facility_cd
            , coop_cd
            , coop_cd_index
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
            , coop_version
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            , direction
            , coop_vender
            , description
            , max(up_date) AS up_date
        FROM
            mst_coop_distribute
        WHERE
            facility_cd = /*facilityCd*/null
        GROUP BY
            facility_cd
            , coop_cd
            , coop_cd_index
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
            , coop_version
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            , direction
            , coop_vender
            , description
    ) AS b
WHERE
    a.facility_cd = /*facilityCd*/null
    AND b.facility_cd = a.facility_cd
    AND b.coop_cd = a.coop_cd
    AND b.coop_cd_index = a.coop_cd_index
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    AND b.coop_version = a.coop_version
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    AND b.direction = a.direction
    AND b.coop_vender = a.coop_vender
    AND b.description = a.description
    AND b.up_date = a.up_date;
