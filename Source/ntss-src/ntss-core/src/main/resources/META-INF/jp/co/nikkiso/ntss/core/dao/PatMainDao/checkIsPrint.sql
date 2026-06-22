select count(1) from ord_main om
LEFT JOIN mst_treatment mt on mt.treatment_cd = om.rst_treatment_cd
where
om.is_del = '0'
and om.facility_cd = /*facilityCd*/'000000'
and om.pat_id = /*patId*/0
and mt.report_id = /*reportCd*/0
/*%if treatDate != null && treatDate != "" */
and om.treat_date = /*treatDate*/''
/*%end*/;


