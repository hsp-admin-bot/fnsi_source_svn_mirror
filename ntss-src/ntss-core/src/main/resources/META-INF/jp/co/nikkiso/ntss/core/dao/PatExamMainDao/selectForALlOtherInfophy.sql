select t.ord_no as ord_no, t.base_date as base_date from (
                select exam_main_cd as ord_no, to_char(reg_exam_date, 'yyyymmdd') as base_date
                from pat_exam_main
                where pat_id = /* patId */null
                  --and reg_exam_date >= now() - interval '1 d'
                  -- add 8393 exam_ord連携 検査依頼一覧画面でその他区分の検査をオーダすると登録検査依頼数以上の連携イベント数が登録される zhaoqi 20230221 start
                  and reg_exam_date = /* baseDate */null
                  -- add 8393 exam_ord連携 検査依頼一覧画面でその他区分の検査をオーダすると登録検査依頼数以上の連携イベント数が登録される zhaoqi 20230221 end
                  and facility_cd = /* facilityCd */null
                  and reg_order_class = '0'
                  and phy_ord_class = '1'
                except
                select ord_no as ord_no, base_date as base_date
                from sys_coop_journal
                where pat_id = /* patId */null
                  --and to_date(base_date, 'yyyymmdd') >= now() - interval '1 d'
                  -- add 8393 exam_ord連携 検査依頼一覧画面でその他区分の検査をオーダすると登録検査依頼数以上の連携イベント数が登録される zhaoqi 20230221 start
                  and to_date(base_date, 'yyyymmdd') = /* baseDate */null
                  -- add 8393 exam_ord連携 検査依頼一覧画面でその他区分の検査をオーダすると登録検査依頼数以上の連携イベント数が登録される zhaoqi 20230221 end
                  and facility_cd = /* facilityCd */null
                  and coop_cd = 'exam_ord'
                  and crud <> 'D'
                ) as t order by t.base_date;
