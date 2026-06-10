DELETE FROM ntss.mst_coop_apilink WHERE ctl_no = -501;

INSERT INTO ntss.mst_coop_apilink
(ctl_no, facility_cd, coop_cd, coop_cd_index, crud, direction, api_timing_io, api_timing_ba, api_timing_seq, api_uri, api_method, api_body, continue_api_status, after_api_status, is_del, user_id, reg_date, up_date, api_type, sql_setting, coop_version)
VALUES(-501, 'F_hosp', 'rep_dial', 'pdf', 'D', 'S', 'I', 'B', 1, 'http://localhost:8080/ntss-coop-api/journal/setReportDialSkip', 'POST', '{"key0": "GX", "ord_no": "$JOURNAL.ord_no", "pat_id": "$JOURNAL.pat_id", "coop_cd": "$JOURNAL.coop_cd", "facility_cd": "$JOURNAL.facility_cd"}'::jsonb, '{"exit_code": [], "continue_code": [200]}'::jsonb, '{}'::jsonb, '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '0', NULL, 'GX');