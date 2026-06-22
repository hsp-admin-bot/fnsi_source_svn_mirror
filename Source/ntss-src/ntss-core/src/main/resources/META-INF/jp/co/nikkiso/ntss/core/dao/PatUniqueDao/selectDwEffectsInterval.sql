select
  ord_no,
  treat_date,
-- #9929 add 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-24 start
  ind_kur_cd
-- #9929 add 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-24 end
from
  ord_main om
where
    om.facility_cd = /*facilityCd*/'NKKSBR'
  and om.pat_id = /*patId*/11782
  and om.rst_dialysis_state = '0'
  and om.is_del = '0'
  and (
-- #9929 mod 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-21 start
-- /*%for dw : dwEffects */
--     (om.treat_date >= /*dw.startDate*/'20240508'
--       /*%if dw.endDate != null*/
--       and om.treat_date <= /*dw.endDate*/'99991231'
--       /*%end */
--     )
  /*%for dw : dwEffects */
    /*%if dw.endDate != null*/
  ((to_date(om.treat_date, 'YYYYMMDD'), INTERVAL '1 day') overlaps(/*dw.startDate*/'20240508' ::TIMESTAMP,date(/*dw.endDate*/'99991231' ::TIMESTAMP))) and
    /*%else*/
  ((to_date(om.treat_date, 'YYYYMMDD'), INTERVAL '1 day') overlaps(/*dw.startDate*/'20240508' ::TIMESTAMP,date('99991231' ::TIMESTAMP))) and
    /*%end */
  1 = 1
    /*%if dw_has_next */
    /*# "or" */
    /*%end */
  /*%end*/
-- #9929 mod 身体情報でDWを登録しても連携イベントが発生しない 荘 2024-06-21 end
  )
