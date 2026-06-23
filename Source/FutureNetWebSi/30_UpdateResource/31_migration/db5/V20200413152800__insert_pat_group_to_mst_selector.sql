DELETE FROM mst_selector WHERE master_physical_name = 'pat_group';

INSERT INTO mst_selector
  SELECT 
    facility_cd,
    'pat_group' as master_physical_name,
    jsonb_build_object (
      'items',
      jsonb_agg(
        jsonb_build_object(
          'code', pat_group_cd,
          'name', pat_group_name
        )
      )
    ) as order_settings,
    now() as reg_date,
    now() as up_date
  FROM pat_group
  WHERE
    is_disp = '1'
    AND is_del = '0'
  GROUP BY facility_cd;