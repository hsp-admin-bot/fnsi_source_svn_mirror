-- modify by chamaojia 2023-11-07 [9717] category_cdを範囲検索に変更し、グループ化する   --start
SELECT to_date(event_start_date, 'YYYYMMDD') AS date,
       category_cd as bus_no,
       count(DISTINCT pat_id) AS number_of_pat
FROM pat_event
WHERE to_date(event_start_date, 'YYYYMMDD') >= /*startDate*/NULL
  AND to_date(event_start_date, 'YYYYMMDD') <= /*endDate*/NULL
  AND is_del = '0'
  AND facility_cd = /*facilityCd*/NULL
  AND category_cd in /*categoryCdList*/(null)
GROUP BY to_date(event_start_date, 'YYYYMMDD')
        , category_cd
-- modify by chamaojia 2023-11-07 [9717] category_cdを範囲検索に変更し、グループ化する   --end