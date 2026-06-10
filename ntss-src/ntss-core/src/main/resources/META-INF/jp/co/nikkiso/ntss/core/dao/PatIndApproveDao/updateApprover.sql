UPDATE pat_ind_approve
SET
  /*%if approve_user1_cd != null || approve_user2_cd != null*/
    is_content_appd_changed = '0',
    approve_content = /*approve_content*/'{}',
  /*%end */ 
  /*%if approve_user1_cd != null */
    approve_user1_cd = /*approve_user1_cd*/null,
    approve_user1_time = CURRENT_TIMESTAMP,
    is_user1_approved = '1',
  /*%else */
    approve_user1_cd = null,
    approve_user1_time = null,
    is_user1_approved = '0',
  /*%end */

  /*%if approve_user2_cd != null */
    approve_user2_cd = /*approve_user2_cd*/null,
    approve_user2_time = CURRENT_TIMESTAMP,
    is_user2_approved = '1',
  /*%else */
    approve_user2_cd = null,
    approve_user2_time = null,
    is_user2_approved = '0',
  /*%end */
  /*%if approve_user1_cd == null && approve_user2_cd == null*/
    is_content_appd_changed = '1',
    approve_content = '{}',
  /*%end */

  up_date = CURRENT_TIMESTAMP
WHERE ord_no = /*ord_no*/0
