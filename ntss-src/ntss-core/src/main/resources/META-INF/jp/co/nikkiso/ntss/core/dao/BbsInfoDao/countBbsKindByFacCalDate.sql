SELECT m.kind_no,
       m.kind_name,
-- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
--     date_trunc('day', b.notice_fac_cal_start_date) AS start_date,
--     date_trunc('day', b.notice_fac_cal_end_date) AS end_date,
       date_trunc('day', to_date(b.notice_fac_cal_start_date, 'YYYYMMDD')) AS start_date,
       date_trunc('day', to_date(b.notice_fac_cal_end_date, 'YYYYMMDD')) AS end_date,
-- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 end
       count(m.kind_no) AS number_of_bbs
FROM bbs_info AS b,
     mst_bbs_kind AS m
WHERE b.facility_cd = /*facilityCd*/NULL
  AND b.is_del = '0'
  AND b.is_disp = '1'
  AND m.is_del = '0'
  AND m.is_disp = '1'
  AND m.facility_cd = /*facilityCd*/NULL
  -- modify by chamaojia 2023-11-07 [9717] 範囲検索に変更   --start
  AND m.kind_no in /*kindNoList*/(NULL)
  -- modify by chamaojia 2023-11-07 [9717] 範囲検索に変更   --end
  AND b.kind_no = m.kind_no
  -- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
--   AND ((/*startDate*/NULL<= date_trunc('day', b.notice_fac_cal_start_date)
--         AND date_trunc('day', b.notice_fac_cal_start_date) <= /*endDate*/NULL)
--        OR (/*startDate*/NULL <= date_trunc('day', b.notice_fac_cal_end_date)
--            AND date_trunc('day', b.notice_fac_cal_end_date) <= /*endDate*/NULL)
--        OR (date_trunc('day', b.notice_fac_cal_start_date) <= /*startDate*/NULL
--            AND /*endDate*/NULL <= date_trunc('day', b.notice_fac_cal_end_date))
--        OR (date_trunc('day', b.notice_fac_cal_start_date) <= /*startDate*/NULL
--            AND date_trunc('day', b.notice_fac_cal_end_date) IS NULL))
-- GROUP BY m.kind_no,
--          date_trunc('day', b.notice_fac_cal_start_date),
--        date_trunc('day', b.notice_fac_cal_end_date)
  AND ((/*startDate*/NULL<= date_trunc('day', to_date(b.notice_fac_cal_start_date, 'YYYYMMDD'))
        AND date_trunc('day', to_date(b.notice_fac_cal_start_date, 'YYYYMMDD')) <= /*endDate*/NULL)
       OR (/*startDate*/NULL <= date_trunc('day', to_date(b.notice_fac_cal_end_date, 'YYYYMMDD'))
           AND date_trunc('day', to_date(b.notice_fac_cal_end_date, 'YYYYMMDD')) <= /*endDate*/NULL)
       OR (date_trunc('day', to_date(b.notice_fac_cal_start_date, 'YYYYMMDD')) <= /*startDate*/NULL
           AND /*endDate*/NULL <= date_trunc('day', to_date(b.notice_fac_cal_end_date, 'YYYYMMDD')))
       OR (date_trunc('day', to_date(b.notice_fac_cal_start_date, 'YYYYMMDD')) <= /*startDate*/NULL
           AND date_trunc('day', to_date(b.notice_fac_cal_end_date, 'YYYYMMDD')) IS NULL))
GROUP BY m.kind_no,
         date_trunc('day', to_date(b.notice_fac_cal_start_date, 'YYYYMMDD')),
         date_trunc('day', to_date(b.notice_fac_cal_end_date, 'YYYYMMDD'))
-- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 end
