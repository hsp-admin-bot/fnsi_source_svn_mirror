SELECT
mwsp.survey_point_cd,
	mwst.decimal_digits
FROM

mst_water_survey_point mwsp
left join
	mst_water_survey_type mwst on mwsp.survey_type_cd = mwst.survey_type_cd
WHERE
  mwsp.facility_cd = /*facilityCd*/1
and
	mwsp.is_disp = '1'
	AND
	mwsp.is_del = '0'
