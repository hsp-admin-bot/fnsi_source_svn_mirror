-- 保持 add 10389 患者リストのソートが遅い gjn start
select
  ms.master_physical_name,
  item.code
from
  mst_selector ms
    CROSS JOIN LATERAL jsonb_to_recordset ( ms.order_settings -> 'items' ) AS item ( code BIGINT, NAME TEXT )
where
  ms.facility_cd = /*facilityCd*/'1'
  and ms.master_physical_name in /* masterPhysicalNameList */(null)
;
-- 保持 add 10389 患者リストのソートが遅い gjn end
