-- #11124 2025.08.26 add 酸素飽和度対応 TDC高村
select
  count(*)
from
  mst_machine
where
  facility_cd = /*facilityCd*/'1' and
  is_del = '0' and
  machine_option ->> 'opt_3_6' = '1'
;
