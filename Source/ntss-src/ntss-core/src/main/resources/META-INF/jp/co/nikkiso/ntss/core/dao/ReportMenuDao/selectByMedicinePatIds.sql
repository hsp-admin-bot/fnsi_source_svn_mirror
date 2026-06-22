SELECT
 rs.pat_id
FROM
(
select
  om.pat_id
from
  ord_main as om
cross join lateral
  json_array_elements (om.rst_medi_info :: json) rst_medi
left join mst_medicine as me
  on
  ((rst_medi ->> 'cd')::integer = me.medicine_cd)
where
  me.class_cd in /* medicineCdList */(null)

UNION

select
  om.pat_id
from
  ord_main as om
cross join lateral
  json_array_elements (om.ind_medi_info :: json) ind_medi
left join mst_medicine as me
  on
  ((ind_medi ->> 'cd')::integer = me.medicine_cd)
where
  me.class_cd in /* medicineCdList */(null)

UNION

select
  om.pat_id
from
  ord_main as om
cross join lateral
  json_array_elements (om.rst_treatment_info :: json) rst_treat
left join mst_medicine as me
  on
  ((rst_treat ->> 'medicine_cd')::integer = me.medicine_cd)
where
  me.class_cd in /* medicineCdList */(null)

UNION

select
  om.pat_id
from
  ord_main as om
LEFT OUTER JOIN mst_medicine md ON TO_NUMBER(om.ind_cond_info::json#>>'{15,value}','99999999')=md.medicine_cd
where
  md.class_cd in  /* medicineCdList */(null)
  AND om.ind_cond_info::json#>>'{15,value}' IS NOT NULL

UNION

select
  om.pat_id
from
  ord_main as om
LEFT OUTER JOIN mst_medicine md ON TO_NUMBER(om.ind_cond_info::json#>>'{19,value}','99999999')=md.medicine_cd
where
  md.class_cd in  /* medicineCdList */(null)
  AND om.ind_cond_info::json#>>'{19,value}' IS NOT NULL


UNION

select
  om.pat_id
from
  ord_main as om
LEFT OUTER JOIN mst_medicine md ON TO_NUMBER(om.ind_cond_info::json#>>'{25,value}','99999999')=md.medicine_cd
where
  md.class_cd in  /* medicineCdList */(null)
  AND om.ind_cond_info::json#>>'{25,value}' IS NOT NULL




) as rs

where
  rs.pat_id in /* patIds */(null)
