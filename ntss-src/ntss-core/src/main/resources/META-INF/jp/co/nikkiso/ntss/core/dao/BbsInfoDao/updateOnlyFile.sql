update
 bbs_info
set
  file_info = file_info::jsonb - ((
  select
    jsonbList.index
  from
  (
    select
      row_number() over() as index,
      jsonb
    from
      bbs_info,
      jsonb_array_elements(file_info) as jsonb
    where
      bbs_ctl_no = /*bbs_ctl_no*/null
  ) as jsonbList
  where
    jsonb = /* file_info */null
  )::int-1)
where
  bbs_ctl_no = /*bbs_ctl_no*/null
;
