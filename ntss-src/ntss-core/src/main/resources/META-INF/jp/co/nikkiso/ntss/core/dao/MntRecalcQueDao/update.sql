update mnt_recalc_que
set
  /*%if params.status != null*/
  status = /*params.status*/'',
  /*%end */
  /*%if params.content != null*/
  content = /*params.content*/'',
  /*%end */
  /*%if params.upId != null*/
  up_id = /*params.upId*/'',
  /*%end */
  /*%if params.journal != null*/
  journal = /*params.journal*/'',
  /*%end */
  /*%if params.detail != null*/
  detail = /*params.detail*/'',
  /*%end */
  /*%if params.endDate != null*/
  end_date = /*params.endDate*/'',
  /*%end */
  /*%if params.dispFlg != null*/
  disp_flg = /*params.dispFlg*/'',
  /*%end */
  /*%if params.calcPatId != null*/
  calc_pat_id = /*params.calcPatId*/'',
  /*%end */
  up_date=CURRENT_TIMESTAMP
where
  recalc_que_cd= /* params.recalcQueCd */null;
