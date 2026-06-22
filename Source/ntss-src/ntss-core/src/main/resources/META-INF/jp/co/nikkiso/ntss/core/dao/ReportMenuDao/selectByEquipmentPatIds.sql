SELECT
 rs.pat_id
FROM
(
select
  om.pat_id
from
  ord_main as om
cross join lateral
  json_array_elements (om.rst_equip_info :: json) rst_equip
left join mst_equipment as me
  on
  (
      (rst_equip ->> 'cd')::integer = me.equipment_cd
  )

where
  me.class_cd in /* equipmentCdList */(null)

UNION

select
  om.pat_id
from
  ord_main as om
cross join lateral
  json_array_elements (om.ind_equip_info :: json) ind_equip
left join mst_equipment as me
  on
  (
  (ind_equip ->> 'cd')::integer = me.equipment_cd
  )
where
  me.class_cd in /* equipmentCdList */(null)

UNION

select
  om.pat_id
from
  ord_main as om
LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{6,value}','99999999')=eq.equipment_cd
where
  eq.class_cd in  /* equipmentCdList */(null)
  AND om.ind_cond_info::json#>>'{6,value}' IS NOT NULL

UNION

select
  om.pat_id
from
  ord_main as om
LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{7,value}','99999999')=eq.equipment_cd
where
  eq.class_cd in  /* equipmentCdList */(null)
  AND om.ind_cond_info::json#>>'{7,value}' IS NOT NULL

  UNION

select
  om.pat_id
from
  ord_main as om
LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{8,value}','99999999')=eq.equipment_cd
where
  eq.class_cd in  /* equipmentCdList */(null)
  AND om.ind_cond_info::json#>>'{8,value}' IS NOT NULL

  UNION

select
  om.pat_id
from
  ord_main as om
LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{9,value}','99999999')=eq.equipment_cd
where
  eq.class_cd in  /* equipmentCdList */(null)
  AND om.ind_cond_info::json#>>'{9,value}' IS NOT NULL

  UNION

select
  om.pat_id
from
  ord_main as om
LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{10,value}','99999999')=eq.equipment_cd
where
  eq.class_cd in  /* equipmentCdList */(null)
  AND om.ind_cond_info::json#>>'{10,value}' IS NOT NULL

  UNION

select
  om.pat_id
from
  ord_main as om
LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{11,value}','99999999')=eq.equipment_cd
where
  eq.class_cd in  /* equipmentCdList */(null)
  AND om.ind_cond_info::json#>>'{11,value}' IS NOT NULL

  UNION

select
  om.pat_id
from
  ord_main as om
LEFT OUTER JOIN mst_equipment eq ON TO_NUMBER(om.ind_cond_info::json#>>'{13,value}','99999999')=eq.equipment_cd
where
  eq.class_cd in  /* equipmentCdList */(null)
  AND om.ind_cond_info::json#>>'{13,value}' IS NOT NULL


) as rs

where
  rs.pat_id in /* patIds */(null)
