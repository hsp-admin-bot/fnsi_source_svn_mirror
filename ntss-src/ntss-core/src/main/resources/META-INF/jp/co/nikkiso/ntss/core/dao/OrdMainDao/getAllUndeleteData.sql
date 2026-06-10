--mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx start
-- select om.ord_no
--      , om.pat_id
--      , om.treat_date
--      , om.treat_week
--      , om.facility_cd
--      , coalesce(om.ind_treat_start_time || '00', mk.kur_standard_start_time) as ind_treat_start_time
--      , om.ind_cond_info
--      , om.ind_kur_cd
-- from ord_main om
--        inner join mst_kur mk on om.ind_kur_cd = mk.kur_cd and om.facility_cd = mk.facility_cd
-- where om.facility_cd = /*facilityCd*/null
--   and om.ind_treat_start_time is not null
--   and om.rst_dialysis_state = '0'
--   and om.treat_date >= to_char(now(), 'YYYYMMDD')
--   and om.ind_treat_start_time || '00' >= mk.kur_start_time and om.ind_treat_start_time || '00' <= mk.kur_end_time
--   and om.ind_bed_cd = /*bedCd*/null;
WITH base AS (
         SELECT
             om.ord_no,
             om.pat_id,
             om.treat_date,
             om.treat_week,
             om.facility_cd,
             om.ind_cond_info,
             om.ind_kur_cd,
             (om.ind_treat_start_time || '00') AS ind_treat_start_time_00
         FROM ord_main om
         WHERE om.facility_cd = /*facilityCd*/null
           and om.rst_dialysis_state = '0'
           and om.treat_date >= to_char(now(), 'YYYYMMDD')
           and om.ind_bed_cd = /*bedCd*/null
     )
SELECT
    b.ord_no,
    b.pat_id,
    b.treat_date,
    b.treat_week,
    b.facility_cd,
    coalesce(b.ind_treat_start_time_00, mk.kur_standard_start_time) AS ind_treat_start_time,
    b.ind_cond_info,
    b.ind_kur_cd
FROM base b
         INNER JOIN mst_kur mk
                    ON b.ind_kur_cd = mk.kur_cd
                        AND b.facility_cd = mk.facility_cd
WHERE
        coalesce(b.ind_treat_start_time_00, mk.kur_standard_start_time) >= mk.kur_start_time
  AND
        coalesce(b.ind_treat_start_time_00,  mk.kur_standard_start_time) <= mk.kur_end_time;
--mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx end
