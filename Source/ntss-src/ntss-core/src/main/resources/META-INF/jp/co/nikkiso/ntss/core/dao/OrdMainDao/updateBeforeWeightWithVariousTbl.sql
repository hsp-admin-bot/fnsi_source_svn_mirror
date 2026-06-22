WITH various_value AS (
select
mf.facility_name,
om.ind_treatment_cd,
mt.treatment_name,
mt.device_mode,
om.ind_kur_cd,
mk.kur_name,
om.ind_bed_cd,
mb.bed_name,
mw.ward_cd,
mw.ward_name,
mc.course_cd,
mc.course_name
FROM
ord_main om
left join mst_facility mf on om.facility_cd = mf.facility_cd
left join mst_treatment mt on om.facility_cd = mt.facility_cd and om.ind_treatment_cd = mt.treatment_cd
left join mst_kur mk on om.facility_cd = mk.facility_cd and om.ind_kur_cd = mk.kur_cd
left join mst_bed mb on om.facility_cd = mb.facility_cd and om.ind_bed_cd = mb.bed_cd
INNER JOIN pat_main pm ON om.pat_id = pm.pat_id
left JOIN mst_course mc ON pm.facility_cd = mc.facility_cd AND (pm.medical_care_info ->> 'dialysis_course_cd' ) = mc.course_cd::text
left join mst_ward mw on pm.facility_Cd = mw.facility_cd and (pm.medical_care_info ->> 'ward_cd') = mw.ward_cd::text
WHERE
om.ord_no = /*ordNo*/0
)
update ord_main om1
set
  rst_weight_info = jsonb_merge_recursive(COALESCE(om1.rst_weight_info, '{}'), /*weightInfo*/'{}'::jsonb),
  rst_tare_info = jsonb_merge_recursive(COALESCE(om1.rst_tare_info, '{}'), /*tareInfo*/'{}'::jsonb),
  rst_off_water_info = jsonb_merge_recursive(COALESCE(om1.rst_off_water_info, '{}'), /*offWaterInfo*/'{}'::jsonb),
  rst_accept_date = /*rstAcceptDate*/null,
  ind_dw = /*dw*/null,
  rst_dw = /*dw*/null,
  up_date = CURRENT_TIMESTAMP,
  facility_name = vv.facility_name,
  ind_treatment_name = vv.treatment_name,
  ind_device_mode = vv.device_mode,
  ind_kur_name = vv.kur_name,
  ind_bed_name = vv.bed_name,
  rst_treatment_cd = vv.ind_treatment_cd,
  rst_treatment_name = vv.treatment_name,
  rst_kur_cd = vv.ind_kur_cd,
  rst_kur_name = vv.kur_name,
  rst_bed_cd = vv.ind_bed_cd,
  rst_bed_name = vv.bed_name,
  rst_ward_cd = vv.ward_cd,
  rst_ward_name = vv.ward_name,
  rst_course_cd = vv.course_cd,
  rst_course_name = vv.course_name,
  rst_device_mode = vv.device_mode
FROM
ord_main om2
LEFT JOIN various_value vv on true
where
  om1.ord_no = om2.ord_no
  AND om2.ord_no = /*ordNo*/0
;
