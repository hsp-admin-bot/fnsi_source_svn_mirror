DELETE 
FROM ntss.mst_coop_apilink
WHERE ctl_no IN (-310001,-310002,-310003,-310004,-307001,-307002,-307003,-307004)
;

-- 検査オーダ連携 → 検査依頼実績連携
INSERT INTO ntss.mst_coop_apilink(
    ctl_no,
    facility_cd,
    coop_cd,
    coop_cd_index,
    crud,
    direction,
    api_timing_io,
    api_timing_ba,
    api_timing_seq,
    api_uri,
    api_method,
    api_body,
    continue_api_status,
    after_api_status,
    is_del,
    user_id,
    reg_date,
    up_date,
    api_type,
    sql_setting,
    coop_version
)
VALUES
(
    -310001,
    'P_hosp',
    'exam_ord',
    '',
    'C',
    'S',
    'C9',
    'A',
    1,
    'http://localhost:8080/ntss-coop-api/runDataSet',
    'POST',
    ' {
    "sqlCode" : -310014,
    "facilityCd" : "$JOURNAL.facility_cd",
    "dataKey" : {
      "facilityCd" : "$JOURNAL.facility_cd",
      "ordNo" : "$JOURNAL.ord_no",
      "patId" : "$JOURNAL.pat_id",
      "hospPatId" : "$JOURNAL.hosp_pat_id"
    }
  }'::jsonb,
    '{"exit_code": [], "continue_code": [200]}'::jsonb,
    '{}'::jsonb,
    '0',
    -1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    '0',
    NULL,
    ''
),
(
    -310002,
    'P_hosp',
    'exam_ord',
    '',
    'U',
    'S',
    'C9',
    'A',
    1,
    'http://localhost:8080/ntss-coop-api/runDataSet',
    'POST',
    ' {
    "sqlCode" : -310014,
    "facilityCd" : "$JOURNAL.facility_cd",
    "dataKey" : {
      "facilityCd" : "$JOURNAL.facility_cd",
      "ordNo" : "$JOURNAL.ord_no",
      "patId" : "$JOURNAL.pat_id",
      "hospPatId" : "$JOURNAL.hosp_pat_id"
    }
  }'::jsonb,
    '{"exit_code": [], "continue_code": [200]}'::jsonb,
    '{}'::jsonb,
    '0',
    -1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    '0',
    NULL,
    ''
),
(
    -310003,
    'P_hosp',
    'exam_ord',
    '',
    'C',
    'S',
    'C9',
    'A',
    2,
    'http://localhost:8080/ntss-coop-api/runDataSet',
    'POST',
    ' {
    "sqlCode" : -310015,
    "facilityCd" : "$JOURNAL.facility_cd",
    "dataKey" : {
      "ordNo" : "$JOURNAL.ord_no"
    }
  }'::jsonb,
    '{"exit_code": [], "continue_code": [200]}'::jsonb,
    '{}'::jsonb,
    '0',
    -1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    '0',
    NULL,
    ''
),
(
    -310004,
    'P_hosp',
    'exam_ord',
    '',
    'U',
    'S',
    'C9',
    'A',
    2,
    'http://localhost:8080/ntss-coop-api/runDataSet',
    'POST',
    ' {
    "sqlCode" : -310015,
    "facilityCd" : "$JOURNAL.facility_cd",
    "dataKey" : {
      "ordNo" : "$JOURNAL.ord_no"
    }
  }'::jsonb,
    '{"exit_code": [], "continue_code": [200]}'::jsonb,
    '{}'::jsonb,
    '0',
    -1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    '0',
    NULL,
    ''
)
;


	-- 処方薬剤連携 ← 患者頭書情報連携
INSERT INTO ntss.mst_coop_apilink(
    ctl_no,
    facility_cd,
    coop_cd,
    coop_cd_index,
    crud,
    direction,
    api_timing_io,
    api_timing_ba,
    api_timing_seq,
    api_uri,
    api_method,
    api_body,
    continue_api_status,
    after_api_status,
    is_del,
    user_id,
    reg_date,
    up_date,
    api_type,
    sql_setting,
    coop_version
)
VALUES
(
    -307001,
    'P_hosp',
    'rst_dial',
    '',
    'C',
    'S',
    'I',
    'B',
    1,
    'http://localhost:8080/ntss-coop-api/journal/create',
    'POST',
    '{
  "crud": "C",
  "coop_cd": "profile",
  "ope_cd": "017001",
  "pat_id": "$JOURNAL.pat_id",
  "user_id": "$JOURNAL.user_id",
  "base_date": "$JOURNAL.base_date",
  "facility_cd": "$JOURNAL.facility_cd",
  "hosp_pat_id": "$JOURNAL.hosp_pat_id"
}'::jsonb,
    '{"exit_code": [], "continue_code": [200]}'::jsonb,
    '{}'::jsonb,
    '0',
    -1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    '0',
    NULL,
    ''
),
(
    -307002,
    'P_hosp',
    'rst_dial',
    '',
    'U',
    'S',
    'I',
    'B',
    1,
    'http://localhost:8080/ntss-coop-api/journal/create',
    'POST',
    '{
  "crud": "C",
  "coop_cd": "profile",
  "ope_cd": "017001",
  "pat_id": "$JOURNAL.pat_id",
  "user_id": "$JOURNAL.user_id",
  "base_date": "$JOURNAL.base_date",
  "facility_cd": "$JOURNAL.facility_cd",
  "hosp_pat_id": "$JOURNAL.hosp_pat_id"
}'::jsonb,
    '{"exit_code": [], "continue_code": [200]}'::jsonb,
    '{}'::jsonb,
    '0',
    -1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    '0',
    NULL,
    ''
),
-- 処方薬剤連携 ← 再来受付連携
(
    -307003,
    'P_hosp',
    'rst_dial',
    '',
    'C',
    'S',
    'I',
    'B',
    2,
    'http://localhost:8080/ntss-coop-api/journal/create',
    'POST',
    '{
  "crud": "C",
  "coop_cd": "accept",
  "ope_cd": "013001",
  "ord_no": "$JOURNAL.ord_no",
  "pat_id": "$JOURNAL.pat_id",
  "user_id": "$JOURNAL.user_id",
  "base_date": "$JOURNAL.base_date",
  "facility_cd": "$JOURNAL.facility_cd",
  "hosp_pat_id": "$JOURNAL.hosp_pat_id"
}'::jsonb,
    '{"exit_code": [], "continue_code": [200]}'::jsonb,
    '{}'::jsonb,
    '0',
    -1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    '0',
    NULL,
    ''
),
(
    -307004,
    'P_hosp',
    'rst_dial',
    '',
    'U',
    'S',
    'I',
    'B',
    2,
    'http://localhost:8080/ntss-coop-api/journal/create',
    'POST',
    '{
  "crud": "C",
  "coop_cd": "accept",
  "ope_cd": "013001",
  "ord_no": "$JOURNAL.ord_no",
  "pat_id": "$JOURNAL.pat_id",
  "user_id": "$JOURNAL.user_id",
  "base_date": "$JOURNAL.base_date",
  "facility_cd": "$JOURNAL.facility_cd",
  "hosp_pat_id": "$JOURNAL.hosp_pat_id"
}'::jsonb,
    '{"exit_code": [], "continue_code": [200]}'::jsonb,
    '{}'::jsonb,
    '0',
    -1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    '0',
    NULL,
    ''
)
;