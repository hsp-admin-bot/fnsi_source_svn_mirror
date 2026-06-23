UPDATE "ntss"."sys_data_set" SET "sql" = 'with ord_tbl as (
  select
    ord_no,
    facility_cd,
    pat_id,
    case
      when coalesce(rst_dialysis_state, ''0'') = ''0'' then to_timestamp( treat_date || coalesce(ind_treat_start_time, ''2359'' ) || ''59'', ''yyyymmddhh24miss'')
      else coalesce(rst_cond_send_date, rst_start_date)
    end as key_date,
    case
      when coalesce(rst_dialysis_state, ''0'') = ''0'' then ind_bed_cd
      else rst_bed_cd
    end as bed_cd
  from
    ord_main
  where
    ord_no = @ordNo and is_del = ''0''

), bed_tbl as (
  select
    *
  from
    mst_bed
  where
    bed_cd = (select bed_cd from ord_tbl)
  and
    is_disp = ''1''
  and
    is_del = ''0''

), machine_tbl as (
  select
    mm.*,
    mmt.machine_type
  from
    mst_machine as mm
      left join mst_machine_type as mmt on mm.machine_type_cd = mmt.machine_type_cd
  where
    machine_no = (select machine_no from bed_tbl)
  and
    is_disp =''1''
  and
    is_del = ''0''

), mente_tbl as (
  select
    mmr.*
  from
    mnt_motion_record mmr
      inner join machine_tbl as mt
        on mmr.facility_cd = mt.facility_cd
          and mmr.machine_type_cd = mt.machine_type_cd
          and mmr.machine_serial = mt.machine_serial
  where
    mmr.event_reg_date <= (select key_date from ord_tbl)
  and
    mmr.data_type = 4

), mente_tbl1 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 1
  order by
    event_reg_date desc
  limit 1
  
), mente_tbl2 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 2
  order by
    event_reg_date desc
  limit 1

), mente_tbl3 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 3
  order by
    event_reg_date desc
  limit 1

), mente_tbl4 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 4
  order by
    event_reg_date desc
  limit 1

), mente_tbl5 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 5
  order by
    event_reg_date desc
  limit 1

), mente_tbl6 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 6
  order by
    event_reg_date desc
  limit 1

), mente_tbl7 as (
  select
    *
  from
    mente_tbl
  where
    test_type = 7
  order by
    event_reg_date desc
  limit 1

)


select
  mt.machine_no,
  mt.machine_type,
  mt.com_format_cd,
  mt.setting_date,

  tbl1.event_reg_date as dt1_date,
  tbl1.contents->>''43'' as dt1_data43,
  tbl1.contents->>''44'' as dt1_data44,
  tbl1.contents->>''45'' as dt1_data45,
  tbl1.contents->>''46'' as dt1_data46,
  case
    when tbl1.contents->>''47'' in (''000'', ''0101'', ''0201'', ''0301'') then ''1''
    else ''0''
  end as dt1_data47,
  tbl1.contents->>''48'' as dt1_data48,
  tbl1.contents->>''49'' as dt1_data49,

  tbl2.event_reg_date as dt2_date,
  tbl2.contents->>''53'' as dt2_data53,
  tbl2.contents->>''54'' as dt2_data54,

  tbl3.event_reg_date as dt3_date,
  tbl3.contents->>''58'' as dt3_data58,

  tbl4.event_reg_date as dt4_date,
  tbl4.contents->>''63'' as dt4_data63,
  tbl4.contents->>''64'' as dt4_data64,
  case
    when tbl4.contents->>''65'' in (''3001'', ''3101'') then ''1''
    else ''0''
  end as dt4_data65,

  tbl5.event_reg_date as dt5_date,
  tbl5.contents->>''5'' as dt5_data5,
  case
    when tbl5.contents->>''6'' = ''0001'' then ''1''
    else ''0''
  end as dt5_data6,
  tbl5.contents->>''7'' as dt5_data7,
  tbl5.contents->>''8'' as dt5_data8,
  tbl5.contents->>''9'' as dt5_data9,
  tbl5.contents->>''10'' as dt5_data10,
  tbl5.contents->>''11'' as dt5_data11,

  tbl6.event_reg_date as dt6_date,
  tbl6.contents->>''4'' as dt6_data4,
  tbl6.contents->>''5'' as dt6_data5,
  case
    when tbl6.contents->>''6'' = ''3001'' then ''1''
    else ''0''
  end as dt6_data6,

  tbl7.event_reg_date as dt7_date,
  tbl7.machine_record_message as dt7_message

from
  machine_tbl as mt
   left join mente_tbl1 as tbl1
     on mt.facility_cd = tbl1.facility_cd
       and mt.machine_type_cd = tbl1.machine_type_cd
       and mt.machine_serial = tbl1.machine_serial
   left join mente_tbl2 as tbl2
     on mt.facility_cd = tbl2.facility_cd
       and mt.machine_type_cd = tbl2.machine_type_cd
       and mt.machine_serial = tbl2.machine_serial
   left join mente_tbl3 as tbl3
     on mt.facility_cd = tbl3.facility_cd
       and mt.machine_type_cd = tbl3.machine_type_cd
       and mt.machine_serial = tbl3.machine_serial
   left join mente_tbl4 as tbl4
     on mt.facility_cd = tbl4.facility_cd
       and mt.machine_type_cd = tbl4.machine_type_cd
       and mt.machine_serial = tbl4.machine_serial
   left join mente_tbl5 as tbl5
     on mt.facility_cd = tbl5.facility_cd
       and mt.machine_type_cd = tbl5.machine_type_cd
       and mt.machine_serial = tbl5.machine_serial
   left join mente_tbl6 as tbl6
     on mt.facility_cd = tbl6.facility_cd
       and mt.machine_type_cd = tbl6.machine_type_cd
       and mt.machine_serial = tbl6.machine_serial
   left join mente_tbl7 as tbl7
     on mt.facility_cd = tbl7.facility_cd
       and mt.machine_type_cd = tbl7.machine_type_cd
       and mt.machine_serial = tbl7.machine_serial

' WHERE "sql_cd" = 96;