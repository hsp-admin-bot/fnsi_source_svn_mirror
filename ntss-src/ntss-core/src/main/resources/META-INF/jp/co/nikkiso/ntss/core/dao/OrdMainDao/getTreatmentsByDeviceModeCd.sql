-- modify by chamaojia 2023-11-07 [9717] device_modeを範囲検索に変更し、グループ化する   --start
SELECT
    CAST(coalesce(nullif(rst.treat_date, NULL), ind.treat_date) AS character varying) AS date,
  -- mod 11702 施設カレンダーで過去の集計件数が変わってしまう zkm start
--     ind.device_mode AS device_mode,
    COALESCE ( rst.device_mode, ind.device_mode ) AS device_mode,
  -- mod 11702 施設カレンダーで過去の集計件数が変わってしまう zkm end
    coalesce(nullif(rst.rst_count, NULL), 0) AS rst_count,
    coalesce(nullif(ind.ind_count, NULL), 0)  AS ind_count
FROM (
  -- mod 11702 施設カレンダーで過去の集計件数が変わってしまう zkm start
--     SELECT o.treat_date, t.device_mode, count(o.rst_treatment_cd) AS rst_count
--     FROM
--         ord_main AS o, mst_treatment AS t
--     WHERE
--      o.treat_date >= /*startDate*/NULL AND o.treat_date <= /*endDate*/NULL
--        AND o.facility_cd = /*facilityCd*/NULL AND o.is_del = '0' AND o.rst_treatment_cd = t.treatment_cd AND t.is_del = '0'
--        AND t.device_mode in /*deviceModeCdList*/(NULL)
--        AND t.facility_cd = /*facilityCd*/NULL
--     group by o.treat_date, t.device_mode) AS rst
    SELECT treat_date, rst_device_mode as device_mode, count(rst_treatment_cd) AS rst_count
    FROM
        ord_main
    WHERE
     treat_date >= /*startDate*/NULL AND treat_date <= /*endDate*/NULL
       AND facility_cd = /*facilityCd*/NULL AND is_del = '0'
       AND rst_device_mode in /*deviceModeCdList*/(NULL)
    group by treat_date, rst_device_mode) AS rst
  -- mod 11702 施設カレンダーで過去の集計件数が変わってしまう zkm end
    FULL JOIN (
    SELECT o.treat_date, t.device_mode, count(o.ind_treatment_cd) AS ind_count
    FROM
        ord_main AS o, mst_treatment AS t
    WHERE
     o.treat_date >= /*startDate*/NULL AND o.treat_date <= /*endDate*/NULL
  -- add 11702 施設カレンダーで過去の集計件数が変わってしまう zkm start
        AND o.rst_dialysis_state = '0'
  -- add 11702 施設カレンダーで過去の集計件数が変わってしまう zkm end
        AND o.facility_cd = /*facilityCd*/NULL AND o.is_del = '0' AND o.ind_treatment_cd = t.treatment_cd AND t.is_del = '0'
        AND t.device_mode in /*deviceModeCdList*/(NULL)
        AND t.facility_cd = /*facilityCd*/NULL
    group by o.treat_date, t.device_mode
) AS ind
    ON ind.treat_date = rst.treat_date
    AND ind.device_mode = rst.device_mode
-- modify by chamaojia 2023-11-07 [9717] device_modeを範囲検索に変更し、グループ化する   --end