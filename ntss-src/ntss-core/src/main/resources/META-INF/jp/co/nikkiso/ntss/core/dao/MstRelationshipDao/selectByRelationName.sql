SELECT
  relationship_cd
  ,relationship_name
FROM
  mst_relationship A  --テーブル名
         ,(
                 select
                         mss.facility_cd, ms.*, row_number() over() as index
                 from
                         mst_selector mss
                 cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
                 (
                         code bigint,
                         name text
                 )
                 where
    /*%if facilityCd != null */
                         facility_cd = /*facilityCd*/'0'
                 and
    /*%end */
                         master_physical_name = 'mst_relationship' --テーブル名
         ) ms
WHERE
  A.facility_cd = /*facilityCd*/'0'
AND
  relationship_name = /*relation_name*/null
AND
  is_disp = '1'
AND
  is_del = '0'
ORDER BY relationship_cd
LIMIT 1
