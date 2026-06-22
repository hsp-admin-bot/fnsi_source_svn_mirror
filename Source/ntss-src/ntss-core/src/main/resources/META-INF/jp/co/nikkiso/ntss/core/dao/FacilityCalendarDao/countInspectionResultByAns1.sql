 --  mod 6295 日常点検 趙 start
    -- mod FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou start
-- SELECT date(d.mainte_date) AS mainte_date,
--        d.mainte_ans_1 AS mainte_ans,
--        count(*) AS number_of_mainte_ans
-- FROM mnt_mainte_main AS d,
--      mst_mainte_layout AS l
-- WHERE l.layout_class = '1'
--   AND d.mainte_layout_cd = l.mainte_layout_cd
--   AND date(d.mainte_date) >= /*startDate*/NULL
--   AND date(d.mainte_date) <= /*endDate*/NULL
--   AND d.facility_cd = /*facilityCd*/NULL
--   AND d.is_del = '0'
--   AND d.is_disp = '1'
-- GROUP BY date(d.mainte_date),
--          d.mainte_ans_1

-- WITH data1 AS (
--     SELECT DATE(d.mainte_date) AS mainte_date
--          , d.mainte_ans_1      AS mainte_ans
--          , l.layout_name
--          , l.up_date
--          , COUNT(*)            AS number_of_mainte_ans
--       FROM mnt_mainte_main     AS d
--      INNER JOIN mst_mainte_layout   AS l
--         ON d.mainte_layout_cd  = l.mainte_layout_cd
--      WHERE l.layout_class      = '1'
--        AND DATE(d.mainte_date) >= /*startDate*/NULL
--        AND DATE(d.mainte_date) <= /*endDate*/NULL
--        AND d.facility_cd       = /*facilityCd*/NULL
--        AND d.is_del            = '0'
--        AND d.is_disp           = '1'
--        AND d.mainte_ans_1 BETWEEN '1' AND '3'
--      GROUP BY DATE(d.mainte_date)
--          , d.mainte_ans_1
--          , l.layout_name
--          , l.up_date
--     )
--    , data2 AS ( SELECT * FROM data1 WHERE mainte_ans IN ('1', '3') )
--    , data3 AS (
--     SELECT mainte_date
--          , '4' ::TEXT AS mainte_ans
--          , layout_name
--          , MAX(up_date) AS up_date
--          , SUM(number_of_mainte_ans) AS number_of_mainte_ans
--       FROM data2
--      GROUP BY mainte_date
--          , layout_name
--     )
--    , data4 AS (
--     SELECT COUNT(*) AS sum_count
--       FROM mst_machine AS mst
--      CROSS JOIN  mst_machine_type AS mt
--      WHERE mst.facility_cd = /*facilityCd*/NULL
--        AND mst.is_disp     = '1'
--        AND mst.is_del      = '0'
--        AND mst.machine_type_cd = mt.machine_type_cd
--     )
--    , data5 AS (
--     SELECT data3.mainte_date
--          , '4' ::TEXT AS mainte_ans
--          , data3.layout_name
--          , data3.up_date
--          , data4.sum_count - SUM(data3.number_of_mainte_ans) AS number_of_mainte_ans
--       FROM data3
--      CROSS JOIN data4
--      GROUP BY data3.mainte_date
--          , data3.layout_name
--          , data3.up_date
--          , data4.sum_count
--     )
--    , data6 AS ( SELECT * FROM data1 WHERE mainte_ans = '2' )
--    , data7 AS (
--     SELECT mainte_date
--          , layout_name
--       FROM data1
--      GROUP BY mainte_date
--          , layout_name
--     HAVING COUNT(*) = 1
--     )
--    , data8 AS (
--     SELECT data6.mainte_date
--          , '4' ::TEXT AS mainte_ans
--          , data6.layout_name
--          , data6.up_date
--          , data4.sum_count AS number_of_mainte_ans
--       FROM data6
--      INNER JOIN data7
--         ON data6.mainte_date = data7.mainte_date
--        AND data6.layout_name = data7.layout_name
--      CROSS JOIN data4
--     )
--     SELECT * FROM data2
--      UNION ALL
--     SELECT * FROM data5
--      UNION ALL
--     SELECT * FROM DATA8
--      ORDER BY mainte_date
--          , mainte_ans
--          , mainte_date
    -- mod FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou end

--mod #9552 日常点検の個別選択ができない 20240125 zhaoqi start
-- modify by chamaojia 2023-11-07 [9717] mainte_layout_cdを範囲検索に変更し、グループ化する   --start
 with detail_data as (select DATE(mainte_date) AS mainte_date
                           , mainte_ans
                           , mainte_layout_cd
                           , layout_name
                           , up_date
                           , COUNT(1)          AS number_of_mainte_ans
                      from (SELECT d.mainte_date                 AS mainte_date
                                 , (case d.mainte_ans_1
                                      when '' then '4'
                                      when '2' then '4'
                                      else d.mainte_ans_1 end) AS mainte_ans
                                 , l.layout_name
                                 , date(l.up_date)               as up_date
                                 , l.mainte_layout_cd
                            FROM mnt_mainte_main AS d
                                   INNER JOIN mst_mainte_layout AS l
                                              ON d.mainte_layout_cd = l.mainte_layout_cd
                            WHERE l.layout_class = '1'
                              AND DATE(d.mainte_date) >= /*startDate*/NULL
                              AND DATE(d.mainte_date) <= /*endDate*/NULL
                              AND d.facility_cd = /*facilityCd*/NULL
                              AND d.is_del = '0'
                              AND d.is_disp = '1'
                              AND (d.mainte_ans_1 BETWEEN '1' AND '3' or d.mainte_ans_1 = '')
                              AND l.mainte_layout_cd in /*mainteLayoutCdList*/(NULL)) t
                      GROUP BY DATE(mainte_date)
                             , mainte_ans
                             , layout_name
                             , up_date
                             , mainte_layout_cd)
    , other_data as (select mainte_date, mainte_layout_cd, layout_name, up_date from detail_data)
    , type_data as (select '1' as mainte_ans
                    union
                    select '2' as mainte_ans
                    union
                    select '3' as mainte_ans
                    union
                    select '4' as mainte_ans)
    , exist_layout_data as (select mainte_layout_cd, layout_name, date(up_date) as up_date
                            from mst_mainte_layout
                            where mainte_layout_cd in /*mainteLayoutCdList*/(NULL))
    , montage_data as (select od.mainte_date, eld.mainte_layout_cd, eld.layout_name, eld.up_date, td.mainte_ans
                       from other_data od,
                            type_data td,
                            exist_layout_data eld
                       group by od.mainte_date, eld.mainte_layout_cd, eld.layout_name, eld.up_date, td.mainte_ans)
    , mix_data as (select md.mainte_date,
                          md.mainte_ans,
                          md.mainte_layout_cd,
                          md.layout_name,
                          md.up_date,
                          (case
                             when number_of_mainte_ans is null then 0
                             else number_of_mainte_ans end) as number_of_mainte_ans
                   from montage_data md
                          left join detail_data dd on md.mainte_layout_cd = dd.mainte_layout_cd
                     and md.mainte_date = dd.mainte_date and md.mainte_ans = dd.mainte_ans and md.up_date = dd.up_date
                   order by mainte_date, md.mainte_layout_cd)
    , total_data as (select t.mainte_layout_cd, t.layout_name, count(t.machine_no) as total_count
                     from (select mainte_layout_cd,
                                  layout_name,
                                  jsonb_array_elements(mml.type_info) ->> 'machineNo' as machine_no
                           from mst_mainte_layout mml
                              , (select mss.facility_cd,
                                        ms.*,
                                        row_number() over () as index
                                 from mst_selector mss
                                        cross join lateral jsonb_to_recordset(mss.order_settings -> 'items') as ms
                                   (code bigint, name text)
                                 where master_physical_name = 'mst_mainte_layout'
                                   and facility_cd = /*facilityCd*/NULL) ms
                           where mml.facility_cd = ms.facility_cd
                             and mml.mainte_layout_cd = ms.code
                             and mml.layout_class = '1'
                             and mml.is_del = '0'
                             and mml.is_disp = '1'
                             and mml.mainte_layout_cd in /*mainteLayoutCdList*/(NULL)) t
                     group by t.mainte_layout_cd, t.layout_name)
    , data_1_3 as (select mainte_date,
                          mainte_ans,
                          mainte_layout_cd,
                          layout_name,
                          up_date,
                          sum(number_of_mainte_ans) as number_of_mainte_ans
                   from mix_data
                   where mainte_ans in ('1', '3')
                   group by mainte_date, mainte_ans,
                            mainte_layout_cd,
                            layout_name,
                            up_date)
    , total_data_1_3 as (select mainte_date,
                                mainte_layout_cd,
                                layout_name,
                                up_date,
                                sum(number_of_mainte_ans) as number_of_mainte_ans
                         from mix_data
                         where mainte_ans in ('1', '3')
                         group by mainte_date,
                                  mainte_layout_cd,
                                  layout_name,
                                  up_date)
    , data_4 as (select mainte_date,
                        '4'                                        as mainte_ans,
                        md.mainte_layout_cd,
                        md.layout_name,
                        up_date,
                        (td.total_count - md.number_of_mainte_ans) as number_of_mainte_ans
                 from total_data_1_3 md
                        inner join total_data td on md.mainte_layout_cd = td.mainte_layout_cd)
 SELECT mainte_date, mainte_ans, mainte_layout_cd as layout_cd, layout_name, up_date, number_of_mainte_ans
 FROM data_1_3
 UNION ALL
 SELECT mainte_date, mainte_ans, mainte_layout_cd, layout_name, up_date, number_of_mainte_ans
 FROM data_4
 order by mainte_ans;
 --  mod 6295 日常点検 趙 end
 -- modify by chamaojia 2023-11-07 [9717] mainte_layout_cdを範囲検索に変更し、グループ化する   --end
--mod #9552 日常点検の個別選択ができない 20240125 zhaoqi end
