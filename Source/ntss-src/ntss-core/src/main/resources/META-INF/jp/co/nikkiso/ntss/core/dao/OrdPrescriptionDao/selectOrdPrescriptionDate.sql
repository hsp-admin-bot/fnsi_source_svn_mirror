SELECT Distinct
    '' AS pat_name,
    B.pat_id,
    B.ord_no,
    -- mod 9989 種別単位の検索条件が正しくない　sunsy start
--     expiration_date AS treat_date
    issue_date AS treat_date
    -- mod 9989 種別単位の検索条件が正しくない　sunsy end
    -- add #9989 種別単位の検索条件が正しくない 高 start
   ,B.is_same
-- add #9989 種別単位の検索条件が正しくない 高 end
FROM   ord_prescription C,

       (SELECT
            A.pat_id,
            -- mod 9989 種別単位の検索条件が正しくない　donghao start
            --MAX(A.ord_prescription_no) AS ord_no
            A.ord_prescription_no AS ord_no
            -- mod 9989 種別単位の検索条件が正しくない　donghao end
            -- add #9989 種別単位の検索条件が正しくない 高 start
          ,pm.is_same
            -- add #9989 種別単位の検索条件が正しくない 高 end
        FROM
            ord_prescription A
              -- add #9989 種別単位の検索条件が正しくない 高 start
         left join pat_main pm on pm.pat_id = A.pat_id
            -- add #9989 種別単位の検索条件が正しくない 高 end
        WHERE
                -- mod 9989 種別単位の検索条件が正しくない　sunsy start
--                 A.expiration_date >=  /*dialysis_date_from*/'20100220'
                A.issue_date >=  /*dialysis_date_from*/'20100220'
                -- mod 9989 種別単位の検索条件が正しくない　sunsy end
          AND
                -- mod 9989 種別単位の検索条件が正しくない　sunsy start
--                 A.expiration_date <= /*dialysis_date_to*/'20300226'
                A.issue_date <= /*dialysis_date_to*/'20300226'
                -- mod 9989 種別単位の検索条件が正しくない　sunsy end
          AND
                A.is_del = '0'

          AND
                A.facility_cd =/*facility_cd*/'996996'
            -- del 9989 種別単位の検索条件が正しくない　donghao start
            --GROUP BY
            --A.pat_id
            -- del 9989 種別単位の検索条件が正しくない　donghao end
        ORDER BY
            A.pat_id) B
WHERE B.ord_no = C.ord_prescription_no

ORDER BY
    B.pat_id


