SELECT  om.ord_no, om.pat_id, om.treat_date,
		om.ind_treatment_cd, om.ind_treatment_name,
		om.ind_kur_cd, om.ind_kur_name,
-- mod FNSI-改修内容 * -> /*%expand */* dou start
-- 		pia.*,
        pia.ord_no,
        pia.check_user1_cd,
        pia.check_user2_cd,
        pia.approve_user1_cd,
        pia.approve_user2_cd,
        pia.check_user1_time,
        pia.check_user2_time,
        pia.approve_user1_time,
        pia.approve_user2_time,
        pia.reg_date,
        pia.up_date,
        pia.is_content_changed,
        pia.check_content,
        pia.is_user1_checked,
        pia.is_user2_checked,
        pia.is_user1_approved,
        pia.is_user2_approved,
        pia.is_content_appd_changed,
        pia.approve_content,
        pia.is_content_changed_for_map,
        pia.content_for_map,
        pia.facility_cd,
-- mod FNSI-改修内容 * -> /*%expand */* dou end
		om.ind_bed_cd
FROM ord_main om
JOIN pat_ind_approve pia ON om.ord_no = pia.ord_no
WHERE

	to_char(om.reg_date, 'yyyyMMdd') = /*treatStartTime*/''

	/*%if null != treatStartDate */
	AND om.treat_date >= to_char(to_date(/*treatStartDate*/'19700101', 'yyyyMMdd'), 'yyyyMMdd')
	/*%else*/
	AND om.treat_date >= to_char(CURRENT_DATE, 'yyyyMMdd')
	/*%end*/

	/*%if null != treatEndDate */
	AND om.treat_date <= to_char(to_date(/*treatEndDate*/'19700101', 'yyyyMMdd'), 'yyyyMMdd')
	/*%else*/
	AND om.treat_date <= to_char(CURRENT_DATE, 'yyyyMMdd')
	/*%end*/
	AND pia.facility_cd = /*facilityCd*/'000000'

	/*%if checker1 */
	AND pia.check_user1_cd IS NOT NULL
	/*%end*/

	/*%if checker2 */
	AND pia.check_user2_cd IS NOT NULL
	/*%end*/

	/*%if approver1 */
	AND pia.approve_user1_cd IS NOT NULL
	/*%end*/

	/*%if approver2 */
	AND pia.approve_user2_cd IS NOT NULL
	/*%end*/

	/*%if null != instructorId */
	AND CAST (om.ind_schedule_user_info->>'ind_user_id' AS INTEGER) = /*instructorId*/0
	/*%end*/

	AND om.facility_cd = /*facilityCd*/'000000'
ORDER BY pia.check_user1_cd, pia.check_user2_cd,
		pia.approve_user1_cd, pia.approve_user2_cd,
		pia.check_user1_time DESC,  pia.check_user2_time DESC,
		pia.approve_user1_cd DESC,  pia.approve_user2_cd DESC, om.ord_no DESC
;
