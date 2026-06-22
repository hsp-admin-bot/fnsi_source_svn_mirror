SELECT
	pat.pat_id,
	pat.facility_cd,
	pat.is_same,
	pat.is_implant,
	pat.is_infect,
	pat.is_diabetes,
	pat.is_blood_suger_exam,
	pat.is_wheel_chair,
	pat.in_out_current_state,
	pat.in_out_plan_state,
	pat.in_out_plan_date,
	pat.pat_memo_info,
	pat.addition_info,
	pat.charge_staff_info,
	pat.pat_group_info,
	pat.taboo_allergy_info,
	pat.infect_info,
	pat.implant_info,
	pat.tare_info,
	pat.off_water_info,
	pat.device_set_info,
	pat.acceptance_status_info,
	pat.is_del,
	pat.up_date,
	pat.reg_date,
	pat.medical_care_info,
	pat.sch_ext_end_date,
	pat.sch_ext_status
FROM
	pat_main pat
	INNER JOIN ord_main ord ON ord.pat_id = pat.pat_id
	AND ord.facility_cd = /*facilityCd*/NULL
	AND ord.pat_id IN /* patIdList */( NULL )
	-- del FNSi6523DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される 周 start
    --AND (ord.rst_dialysis_state = '0' OR ord.rst_dialysis_state = '6')
    -- del FNSi6523DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される 周 end
	AND (
		( treat_date >= REPLACE ( /*startDate*/NULL, '-', '' ) -- 治療日
		AND treat_date <= REPLACE ( /*endDate*/NULL, '-', '' ) ) -- 治療日

		OR ( rst_start_date >= TO_TIMESTAMP( /* startDate */NULL, 'YYYY-MM-DD' ) :: TIMESTAMP -- 実績：治療開始日時
		AND rst_start_date <= TO_TIMESTAMP( /* endDate   */NULL, 'YYYY-MM-DD' ) :: TIMESTAMP ) -- 実績：治療開始日時

		OR ( rst_end_date >= TO_TIMESTAMP( /* startDate */NULL, 'YYYY-MM-DD' ) :: TIMESTAMP -- 実績：治療終了日時
		AND rst_end_date <= TO_TIMESTAMP( /* endDate   */NULL, 'YYYY-MM-DD' ) :: TIMESTAMP ) -- 実績：治療終了日時
	)
WHERE
	pat.is_del = '0'
ORDER BY
	pat_id;
