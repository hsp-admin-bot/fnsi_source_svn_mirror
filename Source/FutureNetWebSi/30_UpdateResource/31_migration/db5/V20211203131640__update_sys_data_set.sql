UPDATE "ntss"."sys_data_set" SET "sql" = 'SELECT
	ntss_db5_mst_opp.insu_dr_id AS userid
	,ntss_db5_mst_opp.pat_id AS patid
	,personal_info_decrypt(ntss_db5_mst_opp.insu_dr_name) AS prescriptername
	,ntss_db5_mst_opp.remarks AS note
	,'''' AS prescriptercd
FROM
	ord_personal_prescription ntss_db5_mst_opp
WHERE 
	ntss_db5_mst_opp.is_del = ''0''
AND ntss_db5_mst_opp.facility_cd = @facilityCd;', "db_class" = 3, "detail" = '[]', "can_repeat" = '1', "use_application" = '{"applications": [5]}', "report_class" = '{"classes": []}', "memo" = '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["userid,patid"]}', "reg_date" = '2026-02-01 17:51:54.726', "up_date" = '2026-02-01 17:51:54.726', "pre_sql_info" = NULL WHERE "sql_cd" = -2231;
