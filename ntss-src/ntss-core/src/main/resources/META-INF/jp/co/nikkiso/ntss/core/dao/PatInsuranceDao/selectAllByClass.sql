--add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
select insurance_cd,
       facility_cd,
       insu_class,
       insu_name
from pat_insurance
where is_del = '0'
  and pat_id in /* patIdList */(null)
  and facility_cd = /* facilityCd */null
/*%if insuClass != null */
  and insu_class = /* insuClass */'1'
/*%end */
--add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end
