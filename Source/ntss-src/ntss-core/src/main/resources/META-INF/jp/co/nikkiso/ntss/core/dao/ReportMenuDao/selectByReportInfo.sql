select
DISTINCT om.pat_id
from
ord_main om
LEFT JOIN mst_treatment mt on mt.treatment_cd = om.rst_treatment_cd
where
om.facility_cd = /* facilityCd */''
/*%if reportCd == -3L */
and mt.report_id is not null
and mt.report_id > 0
/*%end */
/*%if reportCd == -2L */
and mt.report_id_hw is not null
and mt.report_id_hw > 0
/*%end */
and om.pat_id in /* patIds */(null)
/*%if fromDate != null*/
and om.treat_date between /* fromDate */'' and /* toDate */''
/*%end*/
