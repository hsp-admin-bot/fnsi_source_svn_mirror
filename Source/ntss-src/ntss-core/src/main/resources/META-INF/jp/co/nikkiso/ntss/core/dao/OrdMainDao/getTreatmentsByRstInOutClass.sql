SELECT o.treat_date AS date, count(o.rst_in_out_class) AS rst_count
FROM
    ord_main AS o
WHERE
		 o.treat_date >= /*startDate*/NULL AND o.treat_date <= /*endDate*/NULL
    -- mod 障害票一覧_施設カレンダー 修正 chen start
    -- mod FNSi5872-外来患者治療件数、入院患者治療件数が一部の日付で表示されない 周 start
    --AND o.facility_cd = /*facilityCd*/NULL AND o.is_del = '0' AND o.pat_id in /*patIdList*/(0) AND o.rst_dialysis_state = '6'
-- mod 11702 施設カレンダーで過去の集計件数が変わってしまう zkm start
--     AND o.facility_cd = /*facilityCd*/NULL AND o.is_del = '0' AND o.pat_id in /*patIdList*/(0)
  AND o.facility_cd = /*facilityCd*/NULL AND o.is_del = '0' AND o.pat_id in /*patIdList*/(0) AND o.rst_dialysis_state = '0'
-- mod 11702 施設カレンダーで過去の集計件数が変わってしまう zkm end
    -- mod FNSi5872-外来患者治療件数、入院患者治療件数が一部の日付で表示されない 周 end
    --AND o.facility_cd = /*facilityCd*/NULL AND o.is_del = '0' AND o.rst_in_out_class = /*rstInOutClass*/999999
    -- mod 障害票一覧_施設カレンダー 修正 chen end
GROUP By o.treat_date
