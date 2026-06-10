WITH ms AS (
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
    master_physical_name = 'mst_water_survey_point'
    AND facility_cd = /*facilityCd*/'000000'
),
ms_type AS (
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
    master_physical_name = 'mst_water_survey_type'
    AND facility_cd = /*facilityCd*/'000000'
),
ms_machine AS (
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
    master_physical_name = 'mst_machine'
    AND facility_cd = /*facilityCd*/'000000'
)

SELECT
	ws.survey_point_cd,
	ws.point_name,
	ws.facility_cd,
	ws.machine_no,
	t.survey_type_cd,
	t.survey_type_name,
	ws.is_disp,
	ws.is_del,
	ws.reg_date,
	ws.up_date,
	ms.index AS water_survey_point_order_index,
	ms_type.index AS water_survey_type_order_index,
	ms_machine.index AS machine_order_index
FROM
	mst_water_survey_point AS ws
INNER JOIN mst_water_survey_type t ON 
  ws.survey_type_cd = t.survey_type_cd 
  AND t.is_disp = '1'
  AND t.is_del = '0'
LEFT JOIN ms ON ws.survey_point_cd  = ms.code
LEFT JOIN ms_type ON ws.survey_type_cd  = ms_type.code
LEFT JOIN ms_machine ON ws.machine_no = ms_machine.code
WHERE
  ws.facility_cd = /*facilityCd*/'000000'
  AND ws.is_disp = '1'
  AND ws.is_del = '0'
ORDER BY
  ms.index
;
