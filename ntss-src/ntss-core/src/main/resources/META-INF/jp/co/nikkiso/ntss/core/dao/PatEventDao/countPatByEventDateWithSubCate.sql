-- modify by chamaojia 2023-11-07 [9717] sub_category_cdを範囲検索に変更し、グループ化する   --start
SELECT to_date(e.event_start_date, 'YYYYMMDD') AS date,
       e.sub_category_cd as bus_no,
       count(DISTINCT e.pat_id) AS number_of_pat
FROM pat_event AS e,
     mst_pat_event_sub_category AS s
WHERE to_date(e.event_start_date, 'YYYYMMDD') >= /*startDate*/NULL
  AND to_date(e.event_start_date, 'YYYYMMDD') <= /*endDate*/NULL
  AND e.is_del = '0'
  AND s.sub_category_cd = e.sub_category_cd
  AND s.is_del = '0'
  AND e.facility_cd = /*facilityCd*/NULL
  AND s.facility_cd = /*facilityCd*/NULL
  AND e.sub_category_cd IN /* subCategoryCdList */(NULL)
GROUP BY to_date(e.event_start_date, 'YYYYMMDD')
        , e.sub_category_cd
-- modify by chamaojia 2023-11-07 [9717] sub_category_cdを範囲検索に変更し、グループ化する   --end