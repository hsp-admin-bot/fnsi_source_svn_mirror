SELECT A.facility_cd as facility_cd, B.bed_cd as next_pat_mode, C.lcd_npat as lcd_npat
FROM
    (select
         MM.facility_cd as facility_cd, MB.bed_cd as bed_cd, count(1) as bedCount
     from
         mst_bed MB
             inner join  mst_machine MM
                         ON MB.machine_no = MM.machine_no and MM.facility_cd = MB.facility_cd
     where
             MM.facility_cd = /*facilityCd*/'1' and
             MB.bed_cd in /*bedCdList*/(null) and
             MM.is_del = '0'
     group by MM.facility_cd, MB.bed_cd
    ) as A,
    (select
         MM.facility_cd as facility_cd, MB.bed_cd as bed_cd, MM.machine_type_cd as machine_type_cd, MM.machine_serial as machine_serial, MM.device_edge_no as device_edge_no
     from
         mst_bed MB
             inner join  mst_machine MM
                         ON MB.machine_no = MM.machine_no and MM.facility_cd = MB.facility_cd
     where
             MM.facility_cd = /*facilityCd*/'1' and
             MB.bed_cd in /*bedCdList*/(null) and
             MM.is_del = '0'
    ) AS B,
    mst_comsv_setting AS C
WHERE
        A.bedCount = 1
  AND
        A.facility_cd = B.facility_cd
  AND
        A.facility_cd = C.facility_cd
  AND
        A.bed_cd = B.bed_cd
  AND
        C.device_edge_no = B.device_edge_no
;
