-- 指定施設コード、指定時間範囲の患者イベント実績情報を取得
SELECT
  '' AS pat_name,
  B.pat_id,
  B.ord_no,
  C.treat_date
  -- add 9409 検出された患者が全て同姓同名表示がされてしまっている　吉 start
  ,B.is_same
  -- add 9409 検出された患者が全て同姓同名表示がされてしまっている　吉 end
  ,C.up_ind_user_id AS ind_user_id
FROM
  ord_main C,
  (SELECT
    A.pat_id,
    -- mod 9035 1人の患者が複数データを持っていて、そのうちの1件が失敗した場合、次のデータの送信を行う処理で、　吉 start
    -- MAX(A.ord_no) AS ord_no
    A.ord_no
    -- mod 9035 1人の患者が複数データを持っていて、そのうちの1件が失敗した場合、次のデータの送信を行う処理で、　吉 end
    -- add 9409 検出された患者が全て同姓同名表示がされてしまっている　吉 start
    ,pm.is_same
     -- add 9409 検出された患者が全て同姓同名表示がされてしまっている　吉 end
  FROM
    ord_main A
    -- add 9409 検出された患者が全て同姓同名表示がされてしまっている　吉 start
    left join pat_main pm on pm.pat_id = A.pat_id
    -- add 9409 検出された患者が全て同姓同名表示がされてしまっている　吉 end
  WHERE
    A.treat_date >= /*dialysis_date_from*/'20100220'
  AND
    A.treat_date <= /*dialysis_date_to*/'20300226'
  AND
    A.is_del = '0'
   -- mod 9989 種別単位の検索条件が正しくない　donghao start
   --((/*strkbn*/'C'::text = '' OR /*strkbn*/'C'::text is null) OR (/*strkbn*/'C'::text = 'C') OR (/*strkbn*/'C'::text = 'R' AND A.rst_dialysis_state <> '0') )
 /*%if strkbn != ""*/
  AND
   A.rst_dialysis_state = '6'
/*%end */
  -- mod 9989 種別単位の検索条件が正しくない　donghao end
  AND
    A.facility_cd = /*facilityCd*/'996996'
  AND
    A.pat_id IS NOT NULL
    -- del 9035 1人の患者が複数データを持っていて、そのうちの1件が失敗した場合、次のデータの送信を行う処理で、　吉 start
    --  GROUP BY
    --    A.pat_id
    -- del 9035 1人の患者が複数データを持っていて、そのうちの1件が失敗した場合、次のデータの送信を行う処理で、　吉 end
  ORDER BY
    A.pat_id) B
WHERE B.ord_no = C.ord_no
ORDER BY
    B.pat_id
;
