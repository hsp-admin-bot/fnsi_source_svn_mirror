select
  facility.facility_name,
  state.facility_cd,
  state.machine_type_cd,
  machine_type.machine_type,
  state.machine_serial,
  state.model,
  state.machine_name,
  state.bed_name,
  state.process_state,
  COALESCE(state.m_notice_cnt, 0) as m_notice_cnt,
  COALESCE(state.preventive_mainte_cnt, 0) as preventive_mainte_cnt,
  COALESCE(state.service_support_cnt, 0) as service_support_cnt,
  state.is_preventive_mainte,
  machine.com_format_cd,
  machine.com_type,
  machine.device_edge_no,
  machine.is_ftp,
  machine.version,
  sort_bed.bed_disp_no,
  sort_machine.machine_disp_no
from
  mnt_machine_state state
    left outer join mst_facility facility
      on state.facility_cd = facility.facility_cd
    left outer join mst_machine_type machine_type
      on state.machine_type_cd = machine_type.machine_type_cd
  left outer join mst_machine machine
    on state.facility_cd = machine.facility_cd
    and state.machine_type_cd = machine.machine_type_cd
    and state.machine_serial = machine.machine_serial
  left outer join (
    select
      row_number() over() as bed_disp_no,
      *
    from
      jsonb_to_recordset((
        select
          order_settings->'items'
        from
          mst_selector
        where
          facility_cd = /*facilityCd*/'1'
        and
          master_physical_name = 'mst_bed'
      )) as mb(code bigint, name text)
  ) as sort_bed
    on state.bed_cd = sort_bed.code
  left outer join (
    select
      row_number() over() as machine_disp_no,
      *
    from
      jsonb_to_recordset((
        select
          order_settings->'items'
        from
          mst_selector
        where
          facility_cd = /*facilityCd*/'1'
        and
          master_physical_name = 'mst_machine'
      )) as mb(code bigint, name text)
  ) as sort_machine
    on machine.machine_no = sort_machine.code

where
  state.facility_cd = /*facilityCd*/'1'

order by
  -- mod #8640 「【デグレ】警報を対処済にしてもバックカラーが赤いまま」について、対応する。 dengshen start
  -- state.model, sort_bed.bed_disp_no, sort_machine.machine_disp_no, state.bed_name;
  state.bed_name, state.model, sort_bed.bed_disp_no, sort_machine.machine_disp_no;
  -- mod #8640 「【デグレ】警報を対処済にしてもバックカラーが赤いまま」について、対応する。 dengshen end
