SELECT
    '' AS pat_name,
    B.pat_id,
    C.exam_main_cd AS ord_no,
    reg_exam_date AS treat_date
    -- add #9989 種別単位の検索条件が正しくない 高 start
  ,B.is_same
-- add #9989 種別単位の検索条件が正しくない 高 end
  ,C.ind_user_id 
FROM
    pat_exam_main C,
    (SELECT
         A.pat_id,
      -- mod 9989 種別単位の検索条件が正しくない　donghao start
      --MAX(A.exam_main_cd) AS exam_main_cd
         A.exam_main_cd
      -- mod 9989 種別単位の検索条件が正しくない　donghao end
         -- add #9989 種別単位の検索条件が正しくない 高 start
       ,pm.is_same
         -- add #9989 種別単位の検索条件が正しくない 高 end
     FROM
         pat_exam_main A
           -- add #9989 種別単位の検索条件が正しくない 高 start
           left join pat_main pm on pm.pat_id = A.pat_id
         -- add #9989 種別単位の検索条件が正しくない 高 end
     WHERE
             A.reg_exam_date >= /*dialysis_date_from*/'20210101'
       AND
             A.reg_exam_date <= /*dialysis_date_to*/'20210819'
       AND
             A.is_del = '0'
-- mod 9989 種別単位の検索条件が正しくない　donghao start
       --AND
       --    A.exam_status='0'
       -- del 9989 種別単位の検索条件が正しくない　sunsy start
-- /*%if phyFlg != true*/
--        AND
--              A.exam_status='0'
-- /*%else*/
--        AND
--              A.exam_status='1'
-- /*%end*/
        -- del 9989 種別単位の検索条件が正しくない　sunsy end
-- mod 9989 種別単位の検索条件が正しくない　donghao end
        -- add 9989 種別単位の検索条件が正しくない　sunsy start
       AND
            A.exam_status='0'
/*%if phyFlg != true*/
       AND
            A.phy_ord_class IS NULL
/*%else*/
       AND
            A.phy_ord_class  = '1'
/*%end*/
         -- add 9989 種別単位の検索条件が正しくない　sunsy end
       AND
             A.facility_cd = /*facility_cd*/'996996'
       AND
         A.pat_id IS NOT NULL
       -- del 9989 種別単位の検索条件が正しくない　donghao start
       --GROUP BY
         -- A.pat_id
       -- del 9989 種別単位の検索条件が正しくない　donghao end
     ORDER BY
         A.pat_id) B
WHERE B.exam_main_cd = C.exam_main_cd
ORDER BY
    B.pat_id
