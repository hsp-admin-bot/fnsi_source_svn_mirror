delete
from ord_schedule
where
    is_dummy = '1'
  and(
  --mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx start
/*%for osl : needToDelOsList */
--   (facility_cd = /* facilityCd */null and ord_no = /* osl.ordNo */null and treat_date = /* osl.treatDate */null and kur_cd = /* osl.kurCd */null and bed_cd = /* osl.bedCd */null)
    (facility_cd = /* facilityCd */null and ord_no = /* osl.ordNo */null and treat_date = /* osl.treatDate */null and bed_cd = /* osl.bedCd */null)
/*%if osl_has_next */
/*# " or " */
/*%end */
/*%end*/
    )
--mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx end
