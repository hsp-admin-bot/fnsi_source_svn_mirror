WITH mss_bed AS (
  select
    mss.facility_cd, ms.*, row_number() over() as ord_index
  from
    mst_selector mss
    cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
    (
      code bigint,
      name text
    )
  where
    master_physical_name = 'mst_bed'
    AND facility_cd = /*facilityCd*/'nkknkk'
),
mss_treatment AS (
  select
    mss.facility_cd, ms.*, row_number() over() as ord_index
  from
    mst_selector mss
    cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
    (
      code bigint,
      name text
    )
  where
    master_physical_name = 'mst_treatment'
    AND facility_cd = /*facilityCd*/'nkknkk'
)

SELECT  om.ord_no, om.pat_id, om.treat_date,
		om.ind_treatment_cd, om.ind_treatment_name,
		om.ind_kur_cd, om.ind_kur_name,
		om.ind_schedule_user_info,
-- 		add FNSI-7570 劉全航 start
		om.rst_dialysis_state,
-- 		add FNSI-7570 劉全航 end
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
		om.ind_bed_cd,
		CASE WHEN om.ind_kur_cd = 0 THEN '999999' ELSE mk.kur_start_time END AS ind_kur_start_time,
		CASE WHEN om.ind_bed_cd = 0 THEN 999999 ELSE msb.ord_index END AS ind_bed_order_index,
		mst.ord_index AS ind_treatment_order_index
FROM ord_main om
JOIN pat_ind_approve pia ON om.ord_no = pia.ord_no
LEFT JOIN mst_kur mk ON om.ind_kur_cd = mk.kur_cd
LEFT JOIN mss_bed msb ON om.ind_bed_cd = msb.code
LEFT JOIN mss_treatment mst ON om.ind_treatment_cd = mst.code
WHERE
	/*%if null != treatDate */
		om.treat_date = to_char(to_date(/*treatDate*/'19700101', 'yyyyMMdd'),'yyyyMMdd')
	/*%else*/
		om.treat_date = to_char(CURRENT_DATE, 'yyyyMMdd')
	/*%end*/

	/*%if null != treatmentCode */
		AND om.ind_treatment_cd = /*treatmentCode*/0
	/*%end*/

	/*%if 0 < kurCode.size() */
		AND om.ind_kur_cd IN /*kurCode*/(0)
	/*%end*/

	/*%if null != bedGroup */
		AND ind_bed_cd IN (
			SELECT e::text::int
			FROM mst_room_bed_group, json_array_elements(bed_list::json) e
			WHERE room_bed_group_cd = /*bedGroup*/0
		)
	/*%end*/

	/*%if checker1 */
		AND pia.check_user1_cd IS NULL
	/*%end*/

	/*%if checker2 */
		AND pia.check_user2_cd IS NULL
	/*%end*/

	/*%if approver1 */
		AND pia.approve_user1_cd IS NULL
	/*%end*/

	/*%if approver2 */
		AND pia.approve_user2_cd IS NULL
	/*%end*/

	/*%if null != instructorId */
		AND CAST (om.ind_schedule_user_info->>'ind_user_id' AS INTEGER) = /*instructorId*/0
	/*%end*/

		AND om.facility_cd = /*facilityCd*/'000000'
		AND om.is_del = '0'
ORDER BY mk.kur_start_time ASC, om.ind_bed_name ASC, om.ord_no DESC
;
