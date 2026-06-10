-- add 9664 by kangjie 20240425 start
update ord_main
set
  ind_cond_info = jsonb_merge_recursive(ind_cond_info::jsonb, tmp.indUpdateObjectString::jsonb),
  /*%if rstDialysisState==true */
  rst_cond_info = jsonb_merge_recursive(rst_cond_info::jsonb,tmp.rstUpdateObjectString::jsonb),
  /*%end*/
  up_date = CURRENT_TIMESTAMP
from (values
  /*%for entity: fluidSpeedAndAmountEntities */
  (/*entity.ordNo*/null,
   /*entity.indUpdateObjectString*/null,
    /*entity.rstUpdateObjectString*/null
  )
       /*%if entity_has_next */
       /*# "," */
       /*%end */
       /*%end*/
  ) as tmp (ordNo,indUpdateObjectString,rstUpdateObjectString)
where
  ord_no  = tmp.ordNo
;

-- add 9664 by kangjie 20240425 end
