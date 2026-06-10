-- mode 9522 by kangjie 20231012 start
update
  mst_personal_user
set
/*%if mstPersonalUser.jobCd == "0" */
    job_cd = null
/*%else*/
    job_cd = personal_info_encrypt(/*mstPersonalUser.jobCd*/'1')
/*%end*/
where
  user_id = /*mstPersonalUser.userId*/0
;
-- mode 9522 by kangjie 20231012 end