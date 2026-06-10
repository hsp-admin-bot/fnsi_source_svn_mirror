UPDATE pat_ind_approve
SET
	/*%if check_user1_cd != null || check_user2_cd != null*/
		is_content_changed = '0',
		check_content = /*check_content*/'{}',
	/*%end */
  /*%if check_user1_cd != null */
		check_user1_cd = /*check_user1_cd*/null,
		check_user1_time = CURRENT_TIMESTAMP,
		is_user1_checked = '1',
	/*%else */
		check_user1_cd = null,
		check_user1_time = null,
		is_user1_checked = '0',
	/*%end */

	/*%if check_user2_cd != null */
		check_user2_cd = /*check_user2_cd*/null,
		check_user2_time = CURRENT_TIMESTAMP,
		is_user2_checked = '1',
	/*%else */
		check_user2_cd = null,
		check_user2_time = null,
		is_user2_checked = '0',
	/*%end */
	/*%if check_user1_cd == null && check_user2_cd == null*/
		is_content_changed = '1',
		check_content = '{}',
	/*%end */

	up_date = CURRENT_TIMESTAMP
WHERE ord_no = /*ord_no*/0
