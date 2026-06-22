update
  ord_main
set
  rst_puncture_user_info = COALESCE(rst_puncture_user_info, '{}') ||
/*%if inpNo != 2 */
  ('{"user_id_1": ' || /*userId*/'null' || ',"date": ' || /*date*/'null' || ',"date_1": ' || /*userDate*/'null' ||
  ',"user_last_name_1": ' || /*lastName*/'null' || ',"user_first_name_1": ' || /*firstName*/'null' || '}') :: jsonb,
/*%else */
  ('{"user_id_2": ' || /*userId*/'null' || ',"date": ' || /*date*/'null' || ',"date_2": ' || /*userDate*/'null' ||
  ',"user_last_name_2": ' || /*lastName*/'null' || ',"user_first_name_2": ' || /*firstName*/'null' || '}') :: jsonb,
/*%end */
  up_date = current_timestamp
where
  ord_no = /*ordNo*/1
;
