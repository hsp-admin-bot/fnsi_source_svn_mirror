-- add 10061 by kangjie
select
  pat_id,
  hosp_pat_id,
  personal_info_decrypt(pat_last_name) as pat_last_name,
  personal_info_decrypt(pat_first_name) as pat_first_name,
  in_out_class
from
  pat_personal_main
where
  is_del = '0'
  and facility_cd = /*facilityCd*/'000001'
/*%if patIdList.size() > 0 */
  and pat_id in /* patIdList */(null)
/*%end*/

;
