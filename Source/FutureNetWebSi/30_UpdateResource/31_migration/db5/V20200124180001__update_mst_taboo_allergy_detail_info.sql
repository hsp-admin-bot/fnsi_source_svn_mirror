-- 詳細カラム内の禁忌対象区分のキー名変更(class→classCd)
update mst_taboo_allergy t1
set detail_info = 
  (select json_agg(el::jsonb - 'class' || jsonb_build_object('classCd', el->'class')) 
   from mst_taboo_allergy t2, jsonb_array_elements(t2.detail_info) as el 
   where t1.taboo_allergy_cd = t2.taboo_allergy_cd)
