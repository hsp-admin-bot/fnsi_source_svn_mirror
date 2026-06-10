SELECT Distinct
    '' AS pat_name,
    B.pat_id,
    B.ord_no,
    base_date AS treat_date,
    C.user_id AS ind_user_id
FROM   sys_coop_journal C,

       (SELECT
            A.pat_id,
            -- mod 9035 1人の患者が複数データを持っていて、そのうちの1件が失敗した場合、次のデータの送信を行う処理で、　吉 start
            -- MAX(A.ord_no) AS ord_no
            A.ord_no
            -- mod 9035 1人の患者が複数データを持っていて、そのうちの1件が失敗した場合、次のデータの送信を行う処理で、　吉 end
        FROM
            sys_coop_journal A
        WHERE
                A.base_date >= /*dialysis_date_from*/'20100220'
          AND
                A.base_date <= /*dialysis_date_to*/'20300226'
          AND
                A.is_del = '0'
          AND
                A.coop_result='9'
          AND
                A.coop_cd=/*strSyubetu*/'ind_dial'
          AND
                A.facility_cd = /*facility_cd*/'996996'
         -- del 9035 1人の患者が複数データを持っていて、そのうちの1件が失敗した場合、次のデータの送信を行う処理で、　吉 start
        --  GROUP BY
        --    A.pat_id
        -- del 9035 1人の患者が複数データを持っていて、そのうちの1件が失敗した場合、次のデータの送信を行う処理で、　吉 end
        ORDER BY
            A.pat_id) B
WHERE B.ord_no = C.ord_no

ORDER BY
    B.pat_id


