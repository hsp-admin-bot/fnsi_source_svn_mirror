select
  list ->> 'list_cd' as list_cd,
  list ->> 'list_name' as list_name,
  list ->> 'dialysis_prog_cd' as list_prog
  -- mod FNSI-バグ 通信サーバ 高 start
  from (
    select
        mst1.checklist_settings
    from
        mst_checklist as mst1
    where
        mst1.facility_cd = /*facilityCd*/'000000' and
        mst1.is_disp = '1' and
        mst1.is_del = '0' and
        mst1.up_date IS NOT NULL
        ORDER BY mst1.up_date DESC
        LIMIT 1
    ) mst
cross join lateral
  json_array_elements (mst.checklist_settings :: json) list
where
  list ->> 'dialysis_prog_cd' != '3'
  -- mod FNSI-バグ 通信サーバ 高 end
;
