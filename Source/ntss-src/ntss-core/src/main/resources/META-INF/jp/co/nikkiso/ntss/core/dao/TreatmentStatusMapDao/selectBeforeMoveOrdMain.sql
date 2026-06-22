-- 指定オーダー番号の治療予定と指定ベッドコードからベッド割り当て前チェックに必要な情報を取得する
select
  A.ord_no,
  A.ind_bed_cd,
  A.ind_va_cd,
  A.ind_treatment_cd,
  P.pat_id,
  P.is_infect,
  T.device_mode,
  MV.va_direct,

  MB.machine_no,
  MB.shunt_position,
  MB.is_infection,
  MM.machine_type_cd,
  MM.is_support_hd,
  MM.is_support_ecum,
  MM.is_support_hdf,
  MM.is_support_hf,
  MM.is_support_hd_ho,
  MM.is_support_ecum_ho,
  MM.is_support_afbf,
  MM.is_support_ohdf,
  MM.is_support_ohf,
  MM.is_support_i_hdf as is_support_ihdf,
  MM.is_support_blood_purify,
  MS.machine_serial,
  MS.process_state

from
-- 治療予定関連
(
  -- modify by zhaohan 2022-10-31 [7090] システムを停止しないDBバージョンアップができない。 --start
  -- select *
  select ord_no, ind_bed_cd, ind_va_cd, ind_treatment_cd, pat_id
  -- modify by zhaohan 2022-10-31 [7090] システムを停止しないDBバージョンアップができない。 --end
  from ntss.ord_main
  where ord_no = /*ordNo*/0
) A
left outer join
  ntss.mst_va MV
on
  A.ind_va_cd = MV.va_cd
inner join
  ntss.pat_main P
on
  P.pat_id = A.pat_id
left outer join
  ntss.mst_treatment T
on
  T.treatment_cd = A.ind_treatment_cd

-- ベッド関連
,(
  -- modify by zhaohan 2022-10-31 [7090] システムを停止しないDBバージョンアップができない。 --start
  -- select *
  select machine_no, shunt_position, is_infection
  -- modify by zhaohan 2022-10-31 [7090] システムを停止しないDBバージョンアップができない。 --end
  from ntss.mst_bed
  where bed_cd = /*bedCd*/0
) MB

left outer join
  ntss.mst_machine MM
on
  MB.machine_no = MM.machine_no
left outer join
  ntss.mnt_machine_state MS
on
  MS.facility_cd = MM.facility_cd
and
  MS.machine_type_cd = MM.machine_type_cd
and
  MS.machine_serial = MM.machine_serial
;
