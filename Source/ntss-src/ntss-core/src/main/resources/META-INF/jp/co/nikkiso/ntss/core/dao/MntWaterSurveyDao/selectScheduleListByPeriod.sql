SELECT
  to_char(mws.inspection_date, 'YYYYMMDD') AS str_date,
  mb.bed_cd
FROM
  mnt_water_survey mws
CROSS JOIN LATERAL jsonb_array_elements(mws.survey_data) AS elem
INNER JOIN mst_water_survey_point mwsp
  ON (elem->>'point_cd')::int = mwsp.survey_point_cd
INNER JOIN mst_bed mb
  ON mwsp.machine_no = mb.machine_no
WHERE
  mws.is_disp = '1'
  AND mws.is_del = '0'
  AND mws.facility_cd = /*facilityCd*/null
  AND mws.inspection_date >= TO_TIMESTAMP(/* startDate */null, 'YYYY/MM/DD')::timestamp
  AND mws.inspection_date <= TO_TIMESTAMP(/* endDate */null, 'YYYY/MM/DD')::timestamp
  AND elem->>'value' IS NOT NULL -- 予定未登録→結果登録→結果削除するとjsonにレコードが残るため除外
;