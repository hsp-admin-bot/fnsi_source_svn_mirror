-- mod #5415 dou start
-- SELECT
--     CAST(coalesce(nullif(rst.treat_date, NULL), ind.treat_date) AS character varying) AS date,
--     coalesce(nullif(rst.rst_count, NULL), 0) AS rst_count,
--     coalesce(nullif(ind.ind_count, NULL), 0)  AS ind_count
-- FROM (
-- 		SELECT m.treat_date, count(rst_treatment_cd) AS rst_count
--     FROM
--         ord_main AS m, mst_treatment AS t
--     Where
-- 		 m.treat_date  >= /*startDate*/NULL AND m.treat_date <=  /*endDate*/NULL
--         AND m.facility_cd = /*facilityCd*/NULL AND m.is_del = '0' AND m.rst_treatment_cd = t.treatment_cd AND t.is_del = '0'
--         AND coalesce(nullif(t.device_mode, NULL), 0) = /*deviceModeCd*/99999 AND t.facility_cd = /*facilityCd*/NULL
--     group by treat_date) AS rst
--     FULL JOIN (
-- 		SELECT m.treat_date, count(m.ind_treatment_cd) AS ind_count
--     FROM
--         ord_main AS m, mst_treatment AS t
--     Where
-- 		m.treat_date  >= /*startDate*/NULL AND m.treat_date <= /*endDate*/NULL
--         AND m.facility_cd = /*facilityCd*/NULL AND m.is_del = '0' AND m.ind_treatment_cd = t.treatment_cd AND t.is_del = '0'
--         AND coalesce(nullif(t.device_mode, NULL), 0) = /*deviceModeCd*/99999 AND t.facility_cd = /*facilityCd*/NULL
--     group by m.treat_date
-- 	) AS ind
--     ON ind.treat_date = rst.treat_date
WITH treatment AS (
    SELECT treatment_cd
      FROM mst_treatment
     WHERE facility_cd = /*facilityCd*/NULL
       AND is_del = '0'
       AND COALESCE ( NULLIF ( device_mode, NULL ), 0 ) = /*deviceModeCd*/99999 )
, ord AS (
    SELECT m.treat_date
         , m.ind_treatment_cd
         , m.rst_treatment_cd
         , t1.treatment_cd ind_cd
         , t2.treatment_cd rst_cd
      FROM ord_main AS m
      LEFT JOIN treatment t1
        ON m.ind_treatment_cd = t1.treatment_cd
      LEFT JOIN treatment t2
        ON m.rst_treatment_cd = t2.treatment_cd
     WHERE m.treat_date BETWEEN /*startDate*/NULL AND /*endDate*/NULL
       AND m.facility_cd = /*facilityCd*/NULL
       AND m.is_del = '0'
    )
, ind AS ( SELECT treat_date, COUNT ( ind_treatment_cd ) AS ind_count FROM ord WHERE ind_cd IS NOT NULL GROUP BY treat_date )
, rst AS ( SELECT treat_date, COUNT ( rst_treatment_cd ) AS rst_count FROM ord WHERE rst_cd IS NOT NULL GROUP BY treat_date )
SELECT CAST ( COALESCE ( NULLIF ( rst.treat_date, NULL ), ind.treat_date ) AS CHARACTER VARYING ) AS DATE
     , COALESCE ( NULLIF ( rst.rst_count, NULL ), 0 ) AS rst_count
     , COALESCE ( NULLIF ( ind.ind_count, NULL ), 0 ) AS ind_count
  FROM ind
  FULL JOIN rst
    ON ind.treat_date = rst.treat_date
-- mod #5415 dou end
