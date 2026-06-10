-- mod 障害票一覧_施設カレンダー 修正 chen start
--SELECT
--    CAST(coalesce(nullif(rst.treat_date, NULL), ind.treat_date) AS character varying) AS date,
--    coalesce(nullif(rst.rst_count, NULL), 0) AS rst_count,
--    coalesce(nullif(ind.ind_count, NULL), 0)  AS ind_count
--FROM (
--SELECT
--        treat_date , count(rst_dialysis_state) AS rst_count
--    FROM
--        ord_main
--    WHERE
--                treat_date >= /*startDate*/NULL AND treat_date <= /*endDate*/NULL
--        AND facility_cd = /*facilityCd*/NULL AND is_del = '0' AND rst_dialysis_state = '6'
--    GROUP BY treat_date
--    ) AS rst
--    FULL JOIN (
--	SELECT
--        treat_date , count(rst_dialysis_state) AS ind_count
--    FROM
--        ord_main
--    WHERE
--                treat_date >= /*startDate*/NULL AND treat_date <= /*endDate*/NULL
--        AND facility_cd = /*facilityCd*/NULL AND is_del = '0'
--    GROUP BY treat_date
--) AS ind
--    ON rst.treat_date = ind.treat_date

SELECT
    CAST(coalesce(nullif(rst.treat_date, NULL), ind.treat_date) AS character varying) AS date,
    coalesce(nullif(rst.rst_count, NULL), 0) AS rst_count,
    coalesce(nullif(ind.ind_count, NULL), 0)  AS ind_count
FROM (
    SELECT m.treat_date, count(m.rst_treatment_cd) AS rst_count
    FROM
    ord_main AS m, mst_treatment AS t
    Where
    m.treat_date  >= /*startDate*/NULL AND m.treat_date <=  /*endDate*/NULL
    AND m.facility_cd = /*facilityCd*/NULL AND m.is_del = '0' AND m.rst_treatment_cd = t.treatment_cd AND t.is_del = '0'
    AND t.facility_cd = /*facilityCd*/NULL
    group by treat_date) AS rst
    FULL JOIN (
    SELECT m.treat_date, count(m.ind_treatment_cd) AS ind_count
    FROM
    ord_main AS m, mst_treatment AS t
    Where
    m.treat_date  >= /*startDate*/NULL
    AND m.treat_date <= /*endDate*/NULL
    AND m.facility_cd = /*facilityCd*/NULL
    AND m.is_del = '0'
    AND m.ind_treatment_cd = t.treatment_cd
--     del 5415 関 start
--     AND t.is_del = '0'
--     AND t.facility_cd = /*facilityCd*/NULL
--     del 5415 関 end
    group by m.treat_date
    ) AS ind
ON ind.treat_date = rst.treat_date
-- mod 障害票一覧_施設カレンダー 修正 chen end

