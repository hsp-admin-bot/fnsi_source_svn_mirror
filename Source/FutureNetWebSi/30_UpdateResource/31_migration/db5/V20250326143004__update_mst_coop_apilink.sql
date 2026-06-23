DELETE FROM mst_coop_apilink WHERE ctl_no IN (-505001);

INSERT INTO mst_coop_apilink
(ctl_no, facility_cd, coop_cd, coop_cd_index, crud, direction, api_timing_io, api_timing_ba, api_timing_seq, api_uri, api_method, api_body, continue_api_status, after_api_status, is_del, user_id, reg_date, up_date, api_type, sql_setting, coop_version)
VALUES(-505001, 'S_hosp', 'ord_dial', '', 'C', 'R', 'A9', 'A', 1, 'http://localhost:8080/ntss-coop-api/journal/ordDialBedReplace', 'POST', '{"ctl_no": "$JOURNAL.ctl_no", "ope_cd": "800011"}'::jsonb, '{"exit_code": [], "continue_code": [200]}'::jsonb, '{}'::jsonb, '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '0', NULL, 'SSI');