SELECT
    ms.code
FROM
    mst_selector mss
        CROSS JOIN LATERAL jsonb_to_recordset ( mss.order_settings -> 'items' ) AS ms ( code BIGINT, NAME TEXT )
WHERE
    master_physical_name = 'mst_disease' --テーブル名

  AND mss.facility_cd = /*facilityCd*/'0'
