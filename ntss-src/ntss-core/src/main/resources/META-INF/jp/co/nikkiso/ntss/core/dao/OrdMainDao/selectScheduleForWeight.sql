WITH mss_bed AS (
  select
    mss.facility_cd, ms.*, row_number() over() as ord_index
  from
    mst_selector mss
    cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
    (
      code bigint,
      name text
    )
  where
    master_physical_name = 'mst_bed'
    AND facility_cd = /*facilityCd*/'nkknkk'
),
mss_treatment AS (
  select
    mss.facility_cd, ms.*, row_number() over() as ord_index
  from
    mst_selector mss
    cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
    (
      code bigint,
      name text
    )
  where
    master_physical_name = 'mst_treatment'
    AND facility_cd = /*facilityCd*/'nkknkk'
)

select
  O.ord_no, O.pat_id, O.facility_cd, P.is_same, O.treat_date,
  O.ind_treatment_cd,
  T_IND.treatment_name as ind_treatment_name,
  MST_IND.ord_index as ind_treatment_order_index,
  T_IND.device_mode as ind_device_mode,
  O.ind_kur_cd,
  K_IND.kur_name as ind_kur_name,
  K_IND.kur_start_time as ind_kur_start_time,
  O.ind_treat_start_time,
  O.ind_bed_cd,
  CASE WHEN B_IND.is_disp = '0' or B_IND.is_del = '1' THEN '【削除済み】' || B_IND.bed_name ELSE B_IND.bed_name END as ind_bed_name,
  MSB_IND.ord_index as ind_bed_order_index,
  T_RST.device_mode as rst_device_mode,
  O.rst_treatment_cd,
  O.rst_treatment_name,
  MST_RST.ord_index as rst_treatment_order_index,
  O.rst_kur_cd,
  O.rst_kur_name,
  K_RST.kur_start_time as rst_kur_start_time,
  O.rst_bed_cd,
  CASE WHEN B_RST.is_disp = '0' or B_RST.is_del = '1' THEN '【削除済み】' || B_RST.bed_name ELSE B_RST.bed_name END as rst_bed_name,
  MSB_RST.ord_index as rst_bed_order_index,
  O.rst_edition,
  O.rst_dialysis_state,
  O.rst_start_date

from
  ord_main O
  left join pat_main P on O.pat_id = P.pat_id
  left join mst_treatment T_IND on O.ind_treatment_cd = T_IND.treatment_cd
  left join mst_treatment T_RST on O.rst_treatment_cd = T_RST.treatment_cd
  left join mst_bed B_IND on O.ind_bed_cd = B_IND.bed_cd
  left join mst_bed B_RST on O.rst_bed_cd = B_RST.bed_cd
  left join mst_kur K_IND on O.ind_kur_cd = K_IND.kur_cd
  left join mst_kur K_RST on O.rst_kur_cd = K_RST.kur_cd
  left join mss_bed MSB_IND on B_IND.bed_cd = MSB_IND.code
  left join mss_bed MSB_RST on B_RST.bed_cd = MSB_RST.code
  left join mss_treatment MST_IND on T_IND.treatment_cd = MST_IND.code
  left join mss_treatment MST_RST on T_RST.treatment_cd = MST_RST.code
where
  O.facility_cd = /*facilityCd*/'nkknkk'
  and
/*%if patId != null */
  O.pat_id = /*patId*/1
  and
/*%else*/
  O.pat_id > 0  -- ？？？？患者を除く
  and
  --実績確定前のみ
  O.rst_edition = 0
  and
/*%end*/
  (
    -- ①予定日が一致して、かつrst_dialysis_stateが1～2で治療完了前のもの
    -- isPastがtrueで過去日指定のものは、①を対象としない
    /*%if isPast == false*/
    (O.treat_date = /*treatDate*/'20000101' and O.rst_dialysis_state in ('0', '1', '2'))
    or
    /*%end*/
    -- ②治療終了日が範囲内に一致して、かつrst_dialysis_stateが4～5で治療完了から実績確定前のもの
    (
      (O.rst_end_date >= /*treatLocalDate*/null and O.rst_end_date < /*treatLocalDateLast*/null)
      and
      O.rst_dialysis_state in ('4', '5')
    )
    or
    -- ③治療開始日が指定日より前で終了しておらず、rst_dialysis_stateが3で治療中のもの
    (
      (O.rst_start_date < /*treatLocalDateLast*/null and O.rst_end_date is null)
      and
      O.rst_dialysis_state in ('3')
    )
  )
  and
  O.is_del = '0'
order by
  CASE 
    WHEN O.rst_dialysis_state IN ('0', '1') THEN K_IND.kur_start_time
    ELSE K_RST.kur_start_time
  END ASC NULLS LAST,
  CASE 
    WHEN O.rst_dialysis_state IN ('0', '1') THEN MSB_IND.ord_index
    ELSE MSB_RST.ord_index
  END ASC NULLS LAST
;
