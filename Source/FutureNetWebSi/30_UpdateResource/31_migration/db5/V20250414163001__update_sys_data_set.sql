DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (
	-307003,-307002
	);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307003, 'select
	(
		case
			when @transKbn IN (''0'',''1'',''2'') then (
				select
					personal_info_decrypt(user_last_name) || personal_info_decrypt(user_first_name)
				from
					mst_personal_user
				where
					user_id = @staffCd
			)
			ELSE @staffName
		end
	) as doctor_name', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -307001, "field_name": "trans_kbn", "replace_var": "@transKbn"}, {"sql_cd": -307001, "field_name": "staff_cd", "replace_var": "@staffCd"}, {"sql_cd": -307001, "field_name": "staff_name", "replace_var": "@staffName"}]'::jsonb);
	
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307002, 'select
	(
		case
			when @transKbn IN (''0'',''1'',''2'') then (
				select
					disp_user_id
				from
					mst_user_authentication
				where
					user_id = @staffCd
			)
			ELSE @staffCd
		end
	) as doctor_id', 1, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, '[{"sql_cd": -307001, "field_name": "trans_kbn", "replace_var": "@transKbn"}, {"sql_cd": -307001, "field_name": "staff_cd", "replace_var": "@staffCd"}]'::jsonb);
	