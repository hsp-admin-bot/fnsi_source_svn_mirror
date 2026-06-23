DELETE FROM mst_coop_apilink WHERE ctl_no IN 
(-1208001);

INSERT INTO ntss.mst_coop_apilink
(ctl_no, facility_cd, coop_cd, coop_cd_index, crud, direction, api_timing_io, api_timing_ba, api_timing_seq, api_uri, api_method, api_body, continue_api_status, after_api_status, is_del, user_id, reg_date, up_date, api_type, sql_setting, coop_version)
VALUES(-1208001, 'F_SX', 'rep_dial', 'pdf', 'D', 'S', 'I', 'A', 1, 'http://localhost:8080/ntss-coop-api/journal/setReportDialSkip', 'POST', '{"crud": "D", "key0": "$JOURNAL.key0", "ord_no": "$JOURNAL.ord_no", "pat_id": "$JOURNAL.pat_id", "coop_cd": "$JOURNAL.coop_cd", "facility_cd": "$JOURNAL.facility_cd", "coop_version": "F_SX", "coop_cd_index": "$JOURNAL.coop_cd_index"}'::jsonb, '{"exit_code": [], "continue_code": [200]}'::jsonb, '{}'::jsonb, '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '0', NULL, 'F_SX');

