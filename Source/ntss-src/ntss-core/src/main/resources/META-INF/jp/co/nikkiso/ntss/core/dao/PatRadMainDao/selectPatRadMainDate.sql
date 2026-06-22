SELECT
    '' AS pat_name,
    B.pat_id,
    C.rad_result_cd  AS ord_no,
    reg_rad_date AS treat_date
    -- add #9989 種別単位の検索条件が正しくない 高 start
   ,B.is_same
    -- add #9989 種別単位の検索条件が正しくない 高 end
   ,C.ind_user_id 
FROM
    pat_rad_main C,
    (SELECT
         A.pat_id,
         MAX(A.rad_result_cd) AS rad_result_cd
         -- add #9989 種別単位の検索条件が正しくない 高 start
        ,MAX(pm.is_same) AS is_same
         -- add #9989 種別単位の検索条件が正しくない 高 end
     FROM
         pat_rad_main A
           -- add #9989 種別単位の検索条件が正しくない 高 start
           left join pat_main pm on pm.pat_id = A.pat_id
         -- add #9989 種別単位の検索条件が正しくない 高 end
     WHERE
             A.reg_rad_date >=  /*dialysis_date_from*/'20210101'
       AND
             A.reg_rad_date <= /*dialysis_date_to*/'20210819'
       AND
             A.is_del = '0'
       AND
             A.rad_status='0'
       AND
             A.facility_cd = /*facility_cd*/'996996'
       AND
         A.pat_id IS NOT NULL
     GROUP BY
         A.pat_id
     ORDER BY
         A.pat_id) B
WHERE B.rad_result_cd = C.rad_result_cd
ORDER BY
    B.pat_id
