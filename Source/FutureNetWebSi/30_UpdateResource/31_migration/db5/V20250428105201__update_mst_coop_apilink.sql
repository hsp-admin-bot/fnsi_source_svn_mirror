DELETE FROM ntss.mst_coop_apilink
WHERE ctl_no=-307005;

INSERT INTO ntss.mst_coop_apilink
(ctl_no, facility_cd, coop_cd, coop_cd_index, crud, direction, api_timing_io, api_timing_ba, api_timing_seq, api_uri, api_method, api_body, continue_api_status, after_api_status, is_del, user_id, reg_date, up_date, api_type, sql_setting, coop_version)
VALUES(-307005, 'P_hosp', 'rst_dial', '', 'D', 'S', 'I', 'B', 1, 'http://localhost:8080/ntss-coop-api/journal/create', 'POST', '{"crud": "C", "ope_cd": "017001", "pat_id": "$JOURNAL.pat_id", "coop_cd": "profile", "user_id": "$JOURNAL.user_id", "base_date": "$JOURNAL.base_date", "facility_cd": "$JOURNAL.facility_cd", "hosp_pat_id": "$JOURNAL.hosp_pat_id", "coop_version": "MED"}'::jsonb, '{"exit_code": [], "continue_code": [200]}'::jsonb, '{}'::jsonb, '0', -1, current_timestamp, current_timestamp, '0', NULL, 'MED');