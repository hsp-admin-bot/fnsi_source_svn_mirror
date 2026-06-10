-- ベッドから見て-- ①治療中患者(ord_no)、次患者(next_ord_no)　←mnt_machine_stateより-- ②当日以降未来方向すべてのstat=0のord_no(next_ord_no_stat0)-- の一覧
select
  t_mb.facility_cd as facility_cd,
  t_mb.bed_cd as bed_cd,
  t_mmc.machine_no as machine_no,
  t_mmc.machine_type_cd as machine_type_cd,
  t_mmc.machine_serial as machine_serial,
  t_mmc.device_edge_no as device_edge_no,
  t_mms.pat_id,
  t_mms.ord_no,
  t_mms.next_patid,
  t_mms.next_ord_no,
  nxord.ord_no as next_ord_no_stat0
from
  mst_machine t_mmc, -- 装置マスタ
  mnt_machine_state t_mms, -- 装置状態管理
  mst_bed t_mb -- ベッドマスタ
  left join
  (
    select
      t.facility_cd,t.pat_id,t.ord_no,t.bed_cd,t.next_treat_date,t.kur_cd
    from
      (
        select
          om.facility_cd as facility_cd,om.pat_id as pat_id,om.ord_no as ord_no,om.ind_bed_cd as bed_cd,om.treat_date as next_treat_date,mk.kur_cd,
          ROW_NUMBER() OVER (PARTITION BY om.ind_bed_cd ORDER BY om.treat_date, mk.kur_standard_start_time) as rn
        from
          ord_main om
            inner join
          mst_kur mk on om.facility_cd = mk.facility_cd and om.ind_kur_cd = mk.kur_cd
        where
            om.facility_cd = /*facilityCd*/'1'
          and om.rst_dialysis_state = '0' --0：条件送信前のデータのみ対象
          and om.treat_date >= /*searchStartDate*/null
          and om.ind_bed_cd IS NOT NULL
          and om.ind_bed_cd != 0
          /*%if bedCdList != null */
          and om.ind_bed_cd in /*bedCdList*/(null)
          /*%end*/
      ) t
    where
        rn = 1
  ) nxord  -- 次患者　rst_dialysis_state='0'
  on t_mb.facility_cd = nxord.facility_cd
  and t_mb.bed_cd = nxord.bed_cd
where
    t_mb.facility_cd = t_mmc.facility_cd
  and t_mb.machine_no = t_mmc.machine_no
  and t_mmc.facility_cd = t_mms.facility_cd
  and t_mmc.machine_type_cd = t_mms.machine_type_cd
  and t_mmc.machine_serial = t_mms.machine_serial
  /*%if bedCdList != null */
  and t_mb.bed_cd in /*bedCdList*/(null)
  /*%end*/
  /*%if ordNoList != null */
  and (t_mms.next_ord_no in /*ordNoList*/(null)  or nxord.ord_no in /*ordNoList*/(null))
  /*%end*/
order by
  bed_cd
