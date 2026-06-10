select
    base_date,
    ctl_no,
    facility_cd,
    coop_cd,
    coop_cd_index,
    crud,
    direction,
    ord_no,
    coop_ord_no,
    hosp_pat_id,
    pat_id,
    ana_result,
    in_ana_date,
    out_ana_date,
    message,
    coop_result,
    in_reg_date,
    out_reg_date,
    dump_path,
    dump,
    is_editable,
    is_del,
    ope_cd,
-- add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    accept_no,
    key0,
    coop_version,
-- add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    retry_cnt,
    reg_date,
    user_id
from
    sys_coop_journal A
where
    facility_cd = /*facilityCd*/'999999'
/*%if payload.coopCd != null*/
and
    A.coop_cd in /*payload.coopCd*/('')
/*%end*/
/*%if payload.direction != null*/
and
    A.direction in /*payload.direction*/('')
/*%end*/

and (
    1 =1
    -- mod FutreNetWeb+SI課題管理No4352 趙 start
    -- /*%if payload.anaResult != null*/
    -- and
    -- A.ana_result in /*payload.anaResult*/('0')
    -- /*%end*/
    -- /*%if payload.coopResult != null*/
    -- or A.coop_result in /*payload.coopResult*/('0')
    -- /*%end*/
    /*%if payload.anaResult != null && payload.coopResult != null*/
            and
    A.ana_result in /*payload.anaResult*/('0')
    or A.coop_result in /*payload.coopResult*/('0')
    /*%end*/
    /*%if payload.anaResult == null && payload.coopResult != null*/
    and
    A.coop_result in /*payload.coopResult*/('0')
    /*%end*/
    /*%if payload.anaResult != null && payload.coopResult == null*/
    and
    A.ana_result in /*payload.anaResult*/('0')
    /*%end*/
    -- mod FutreNetWeb+SI課題管理No4352 趙 end
    )
/*%if payload.fromDate != null && payload.fromDate != "" */
and
    -- mod FutreNetWeb+SI課題管理No4352 趙 start
    -- A.in_ana_date::TIMESTAMP >= /*payload.fromDate*/NULL
    to_char(A.in_ana_date, 'YYYY/MM/DD HH24:MI') >= /*payload.fromDate*/NULL
    -- mod FutreNetWeb+SI課題管理No4352 趙 end
/*%end*/
-- mod FutreNetWeb+SI課題管理No6631 趙 start
/*%if payload.toDate != null && payload.toDate != "" */
and
    -- mod FutreNetWeb+SI課題管理No4352 趙 start
    -- A.out_ana_date::TIMESTAMP <= /*payload.toDate*/NULL
    ((A.out_ana_date is not null and to_char(A.out_ana_date, 'YYYY/MM/DD HH24:MI') <= /*payload.toDate*/NULL) or
     (A.out_ana_date is null and to_char(A.in_ana_date, 'YYYY/MM/DD HH24:MI') <= /*payload.toDate*/NULL))
    -- mod FutreNetWeb+SI課題管理No4352 趙 end
/*%end*/
-- mod FutreNetWeb+SI課題管理No6631 趙 end
/*%if payload.fromRegDate != null && payload.fromRegDate != "" */
and
    -- mod FutreNetWeb+SI課題管理No4352 趙 start
    -- A.in_reg_date::TIMESTAMP >= /*payload.fromRegDate*/NULL
    to_char(A.in_reg_date, 'YYYY/MM/DD HH24:MI') >= /*payload.fromRegDate*/NULL
    -- mod FutreNetWeb+SI課題管理No4352 趙 end
/*%end*/
-- mod FutreNetWeb+SI課題管理No6631 趙 start
/*%if payload.toRegDate != null && payload.toRegDate != "" */
and
    -- mod FutreNetWeb+SI課題管理No4352 趙 start
    --  A.out_reg_date::TIMESTAMP <= /*payload.toRegDate*/NULL
    ((A.out_reg_date is not null and to_char(A.out_reg_date, 'YYYY/MM/DD HH24:MI') <= /*payload.toRegDate*/NULL) or
    (A.out_reg_date is null and to_char(A.in_reg_date, 'YYYY/MM/DD HH24:MI') <= /*payload.toRegDate*/NULL))
    -- mod FutreNetWeb+SI課題管理No4352 趙 end
/*%end*/
-- mod FutreNetWeb+SI課題管理No6631 趙 end
/*%if payload.fromBaseDate != null && payload.fromBaseDate != "" */
-- add 6727 検索条件が正しく動作しない 関 start
and A.base_date ~ '^\d{1,4}\d{2}\d{2}$'
-- add 6727 検索条件が正しく動作しない 関 end
and A.base_date::TIMESTAMP >= /*payload.fromBaseDate*/NULL
/*%end*/
/*%if payload.toBaseDate != null && payload.toBaseDate != "" */
-- add 6727 検索条件が正しく動作しない 関 start
and A.base_date ~ '^\d{1,4}\d{2}\d{2}$'
-- add 6727 検索条件が正しく動作しない 関 end
and A.base_date::TIMESTAMP <= /*payload.toBaseDate*/NULL


/*%end*/
and
(
	encode(A.dump, 'escape') like concat('%', COALESCE(/*payload.content*/'', ''), '%')
	or A.coop_ord_no like concat('%', COALESCE(/*payload.content*/'', ''), '%')
    /*%if payload.content == "" || payload.content == null */
    or A.coop_ord_no ISNULL or encode(A.dump, 'escape') ISNULL
    /*%end*/
    -- #9509 検索条件のフリーワードの検索範囲について 2023-08-30 卓 start
    /*%if payload.patIdList != null  */
    or A.pat_id in /*payload.patIdList*/('0')
    /*%end*/
    -- add 9583 by kangjie 20240411 start
    /*%if payload.content != null && payload.content != "" */
        or to_char(A.ctl_no, 'FM9999999999999999999') like concat('%', COALESCE(/*payload.content*/'', ''), '%')
    /*%end*/
    -- add 9583 by kangjie 20240411 end
    /*%if payload.content != null && payload.content != "" */
    or to_char(A.ord_no, 'FM9999999999999999999') like concat('%', COALESCE(/*payload.content*/'', ''), '%')
    /*%end*/

    /*%if payload.content != null && payload.content != "" */
	or A.message like concat('%', COALESCE(/*payload.content*/'', ''), '%')
    /*%end*/

    /*%if payload.content != null && payload.content != "" */
    or A.ope_cd like concat('%', COALESCE(/*payload.content*/'', ''), '%')
    /*%end*/
    -- #7304  add 異なる連携の機能を組み合わせて使用する方法 2024-07-24 卓 start
    /*%if payload.content != null && payload.content != "" */
    or A.coop_version like concat('%', COALESCE(/*payload.content*/'', ''), '%')
    /*%end*/
    -- #7304  add 異なる連携の機能を組み合わせて使用する方法 2024-07-24 卓 end
    -- #9509 検索条件のフリーワードの検索範囲について 2023-08-30 卓 end
    -- add 9583 by kangjie 20240403 start 通知一覧の連携エラー通知の遷移不正
    /*%if (payload.ctlNo == null || payload.ctlNo=="") && payload.ordNo !=null && payload.content != null && payload.content != "" */
        or A.ord_no =/*payload.content*/''
        /*%end*/
        /*%if payload.ctlNo != null && payload.ctlNo != "" */
        or A.ctl_no = /*payload.content*/''
    /*%end*/
    -- add 9583 by kangjie 20240403 end 通知一覧の連携エラー通知の遷移不正
)
order by
  A.ctl_no desc
/*%if payload.limit != null */
limit /*payload.limit*/1000
/*%end */
;
