--mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx start
-- select om.ind_bed_cd
-- from ord_main om
--          inner join mst_kur mk on om.ind_kur_cd = mk.kur_cd and om.facility_cd = mk.facility_cd
-- where om.facility_cd = /*facilityCd*/null
--   and om.ind_treat_start_time is not null
--   and om.rst_dialysis_state = '0'
--   and om.treat_date >= to_char(now(), 'YYYYMMDD')
--   and om.ind_treat_start_time || '00' >= mk.kur_start_time
--   and om.ind_treat_start_time || '00' <= mk.kur_end_time
--   and om.ind_bed_cd != 0
-- GROUP BY om.ind_bed_cd;
WITH old AS (
    SELECT kur_cd, kur_standard_start_time
    FROM
        (
            VALUES (0, '')
                /*%for old : oldMstKurList */
                 ,(
                /*old.kurCd*/0,
                /*old.kurStandardStartTime*/''
            )
            /*%end */
        )as t(kur_cd, kur_standard_start_time)
)
select om.ind_bed_cd
from ord_main om
         inner join mst_kur mk
                    on om.ind_kur_cd = mk.kur_cd
                        and om.facility_cd = mk.facility_cd
         left join old
                   on old.kur_cd = om.ind_kur_cd
where om.facility_cd = /*facilityCd*/null
  and om.rst_dialysis_state = '0'
  and om.treat_date >= to_char(now(), 'YYYYMMDD')
  and coalesce(
                  om.ind_treat_start_time || '00',
                  old.kur_standard_start_time
          ) >= mk.kur_start_time
  and coalesce(
                  om.ind_treat_start_time || '00',
                  old.kur_standard_start_time
          ) <= mk.kur_end_time
  and om.ind_bed_cd != 0
group by om.ind_bed_cd;
--mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx end
