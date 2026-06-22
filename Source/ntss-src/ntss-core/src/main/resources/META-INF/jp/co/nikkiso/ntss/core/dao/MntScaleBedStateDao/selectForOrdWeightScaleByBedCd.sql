SELECT
  /* targetOrdNo */0 as ord_no
  , mst_weight.weight_name
  , mst_bed.machine_no
  , mnt_machine_state.machine_name
  , ord_main.ind_kur_cd as kur_cd
  , mst_kur.kur_name
  , mst_bed.bed_name
  , mnt_machine_state.next_patid as pat_id
  , ord_main.ind_tare_info as rst_tare_info
  , ord_main.ind_off_water_info as rst_off_water_info
  , ord_main.ind_treatment_cd as treatment_cd
  , mst_treatment.treatment_name
FROM
  mnt_scale_bed_state
    LEFT JOIN mst_bed
              ON mnt_scale_bed_state.bed_cd = mst_bed.bed_cd
              AND mst_bed.is_del = '0'
              AND mst_bed.is_disp = '1'
    LEFT JOIN mnt_machine_state
              ON mnt_scale_bed_state.bed_cd = mnt_machine_state.bed_cd
    LEFT JOIN ord_main
              ON ord_main.ord_no = /* targetOrdNo */0
              AND ord_main.is_del = '0'
    LEFT JOIN mst_kur
              ON ord_main.ind_kur_cd = mst_kur.kur_cd
              AND mst_kur.is_del = '0'
    LEFT JOIN mst_treatment
              ON ord_main.ind_treatment_cd = mst_treatment.treatment_cd
              AND mst_treatment.is_del = '0'
              AND mst_treatment.is_disp = '1'
    INNER JOIN mst_weight
              ON mnt_scale_bed_state.weight_cd = mst_weight.weight_cd
              AND mst_weight.is_del = '0'
              AND mst_weight.is_disp = '1'
WHERE
  mnt_scale_bed_state.bed_cd = /* bedCd */0
;
