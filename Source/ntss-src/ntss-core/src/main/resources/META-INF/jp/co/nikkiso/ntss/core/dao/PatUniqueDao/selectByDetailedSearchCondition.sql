select
  pat_id
from
  pat_unique
where
  is_del = '0'

/*%if patIdList.size() > 0 */
  and pat_id in /* patIdList */(null)
/*%end */

--- 転帰
/*%if conditions.outComeList.size() > 0 */
  and (
  /*%for outCome : conditions.outComeList */
    pat_unique_json_contains_value(medical_hst_info, 'out_come', /* outCome */null, (/* "{" + facilityCdList.toString().substring(1, facilityCdList.toString().length() -1) + "}" */null)::text[])
    /*%if outCome_has_next */
    or
    /*%end */
  /*%end */
  )
/*%end */

--- 病名
/*%if conditions.diseaseCd != null */
  and pat_unique_json_contains_value(medical_hst_info, 'disease_cd', (/* conditions.diseaseCd */null)::text, (/* "{" + facilityCdList.toString().substring(1, facilityCdList.toString().length() -1) + "}" */null)::text[])
/*%end */
--- 透析導入原疾患
/*%if conditions.dialysis_underlying_disease_List.size() > 0 */
and pat_id in (select pat_id FROM(select pat_id,(h->> 'disease_cd')::INTEGER as disease_cd,(h->>'is_dialysis_underlying_disease') as is_dialysis_underlying_disease
    from pat_unique as t, jsonb_array_elements(medical_hst_info) as h ) as r where r.is_dialysis_underlying_disease = '1' and r.disease_cd IN/* conditions.dialysis_underlying_disease_List */(null))
/*%end */
--- 主病
/*%if conditions.primary_disease_cd != null */
and pat_id in (select pat_id FROM(select pat_id,(h->> 'disease_cd')::INTEGER as disease_cd,(h->>'is_main_disease') as is_main_disease
    from pat_unique as t, jsonb_array_elements(medical_hst_info) as h ) as r where r.is_main_disease = '1' and r.disease_cd=/* conditions.primary_disease_cd */null)
/*%end */
