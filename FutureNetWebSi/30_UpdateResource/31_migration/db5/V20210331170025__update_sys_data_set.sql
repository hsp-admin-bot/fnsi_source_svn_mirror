UPDATE sys_data_set 
SET SQL = 'select
  wheel_chair_name,
  wheel_chair_weight
from
  mst_wheel_chair,
  (
    select
      mss.facility_cd, ms.*, row_number() over() as index
    from
      mst_selector mss
    cross join lateral jsonb_to_recordset(mss.order_settings->''items'') as ms
    (
      code bigint,
      name text
    )
    where
      facility_cd = 
        (select
          facility_cd
        from
          pat_main
        where
          pat_id = @patId and is_del =''0'' 
        )
    and
      master_physical_name = ''mst_wheel_chair''
  ) ms
where
  mst_wheel_chair.wheel_chair_cd = ms.code
and
  pat_id = @patId
and
  is_disp = ''1''
and
  is_del = ''0''
and
  is_personal = ''1''
limit 1
' 
WHERE
	sql_cd = '34'
