    select
      ord.pat_id as pat_id,
      ord.facility_cd as facility_cd,
      fac.facility_name as facility_name,
      tre.treatment_name as treatment_name,
      tre.device_mode as device_mode, -- add by shiyw 2024-01-29 [#10196]
      kur.kur_name as kur_name,
      bed.bed_name as bed_name,
      bed.machine_no as machine_no,
      mac.machine_name as machine_name
    from
      ord_main ord
      left outer join mst_facility fac on
        fac.facility_cd = ord.facility_cd
      left outer join mst_treatment tre on
        tre.facility_cd = ord.facility_cd
        and
        tre.treatment_cd = ord.ind_treatment_cd
      left outer join mst_kur kur on
        kur.facility_cd =  ord.facility_cd
        and
        kur.kur_cd =  ord.ind_kur_cd
      left outer join mst_bed bed on
        bed.facility_cd =  ord.facility_cd
        and
        bed.bed_cd =  ord.ind_bed_cd
      left outer join mst_machine mac on
        mac.facility_cd = ord.facility_cd
        and
        mac.machine_no = bed.machine_no
    where
     ord.ord_no = /*ordNo*/0

