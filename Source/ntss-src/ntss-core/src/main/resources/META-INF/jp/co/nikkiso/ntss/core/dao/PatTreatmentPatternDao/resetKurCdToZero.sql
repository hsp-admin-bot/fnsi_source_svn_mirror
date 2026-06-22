update pat_treatment_pattern
set ind_kur_cd   = 0,
    ind_sch_info = jsonb_set(jsonb_set(jsonb_set(ind_sch_info, '{ind_user_id}'::text[], to_jsonb(/*userId*/-1)),
                                       '{upd_user_id}', to_jsonb(/*updUserId*/-1)), '{ind_treat_start_time}', 'null'),
  up_date = CURRENT_TIMESTAMP
where facility_cd = /*facilityCd*/'999999'
  and (
/*%for cp : changedPatternList */
  (pat_id = /* cp.patId */null and ctl_no = /* cp.ctlNo */null)
  /*%if cp_has_next */
    /*# "or" */
  /*%end */
/*%end*/
  )
