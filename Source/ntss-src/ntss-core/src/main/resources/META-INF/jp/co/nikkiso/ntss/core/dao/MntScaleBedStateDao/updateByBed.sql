update
  mnt_scale_bed_state
set
  weight_cd = /*weightCd*/0
  , up_date = current_timestamp
where
  bed_cd = /*bedCd*/1
;
