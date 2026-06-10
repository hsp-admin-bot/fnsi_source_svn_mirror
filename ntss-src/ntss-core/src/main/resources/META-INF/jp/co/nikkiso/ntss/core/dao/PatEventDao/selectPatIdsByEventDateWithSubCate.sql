SELECT DISTINCT e.pat_id
FROM pat_event AS e,
     mst_pat_event_sub_category AS s
WHERE replace(e.event_start_date, '-', '') = /*date*/NULL
  AND e.is_del = '0'
  AND s.is_del = '0'
  AND s.is_disp = '1'
  AND s.sub_category_cd = e.sub_category_cd
  AND s.is_del = '0'
  AND e.facility_cd = /*facilityCd*/NULL
  AND s.facility_cd = /*facilityCd*/NULL
  AND e.sub_category_cd = /*cd*/0