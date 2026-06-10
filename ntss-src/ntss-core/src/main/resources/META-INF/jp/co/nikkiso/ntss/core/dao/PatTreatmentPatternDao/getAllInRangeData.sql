select pat_id,
       ctl_no,
       ptp.facility_cd as facility_cd,
       treat_type,
       ind_treat_start_date,
       ind_treatment_cd,
       ind_kur_cd,
       treat_week,
       ind_sch_info,
       ind_cond_info,
       ind_medi_info,
       ind_equip_info,
       ind_ind_comment_info,
       ind_tare_info,
       ind_off_water_info,
       ind_device_set_info,
       ptp.reg_date,
       ptp.up_date,
       cast(ind_sch_info ->> 'ind_bed_cd' as int) as ind_bed_cd,
       coalesce(ind_sch_info ->> 'ind_treat_start_time' || '00', mk.kur_standard_start_time) as ind_treat_start_time,
       mk.kur_standard_start_time,
       mk.kur_start_time,
       mk.kur_end_time
from pat_treatment_pattern ptp
       inner join mst_kur mk on ptp.ind_kur_cd = mk.kur_cd and ptp.facility_cd = mk.facility_cd
where ptp.ind_kur_cd <> '0'
  and ptp.facility_cd = /*facilityCd*/null
  and ptp.ind_treat_start_date >= to_char(now(), 'YYYYMMDD')
--mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx start
--   and ind_sch_info ->> 'ind_treat_start_time' || '00' >= mk.kur_start_time
--   and ind_sch_info ->> 'ind_treat_start_time' || '00' <= mk.kur_end_time
  and coalesce(ind_sch_info ->> 'ind_treat_start_time' || '00', mk.kur_standard_start_time) >= mk.kur_start_time
  and coalesce(ind_sch_info ->> 'ind_treat_start_time' || '00', mk.kur_standard_start_time) <= mk.kur_end_time
--mod #10634 クールマスタで標準治療開始時刻を変更した際のダミー予定・連携イベント作成処理不正 zrx end
