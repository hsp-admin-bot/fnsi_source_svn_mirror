  select
     -- /*%expand "A" */*
     A.bed_cd
,A.facility_cd
-- del #10280 ベッドマスタに不要なカラムが存在する dengshen start
--   ,A.bed_no
-- del #10280 ベッドマスタに不要なカラムが存在する dengshen end
,A.bed_name
,A.shunt_position
,A.is_infection
,A.emergency_class
,A.machine_no
,A.output_printer
,A.is_autoprint_before
,A.is_autoprint_after
,A.is_autoprint_commit
,A.fn_bed_no
,A.is_disp
,A.is_del
,A.reg_date
,A.up_date
,A.is_home_dialysis
,A.in_hospital_cd_1
,A.in_hospital_cd_2

  from
    mst_bed A   --テーブル名
         ,(
                 select
                         mss.facility_cd, ms.*, row_number() over() as index
                 from
                         mst_selector mss
                 cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
                 (
                         code bigint,
                         name text
                 )
                 where
    /*%if facility_cd != null */
                         facility_cd = /* facility_cd*/'0'
                 and
    /*%end */
                         master_physical_name = 'mst_bed' --テーブル名
         ) ms
      where
             A.facility_cd = ms.facility_cd
       and
             A.bed_cd = ms.code --コードのカラム
/*%if null != is_del */
       and
             A.is_del = '0'
  /*%end*/
/*%if null != is_disp */
--        and
--              A.is_disp = '1'
  /*%end*/
       order by
             ms.index
;
