SELECT 
  recalc_que_cd, 
  content, 
  detail, 
  calc_pat_id 
FROM 
  mnt_recalc_que 
WHERE 
  disp_flg = '1' 
  /*%if statusList != null && statusList.size() != 0 */
AND
  status IN /* statusList */(null)
  /*%end */
;
