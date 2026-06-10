update ntss.mst_coop_facility 
set
    facility_cd = 'F_hosp'
    , description = null
    , is_disp = '1'
    , is_del = '0'
    , if_edge_setting = '{"send": {"keepDirRoot": "/home/ntss/if_edge/save/send"}, "timer": [{"datatype": "profile", "send_time": ["05:00", "16:00"]}], "receive": {"watch": [{"port": "9999", "ope_cd": "800001", "datatype": "ini_dial", "protocol": "socket", "socket-type": "fujitsu"}, {"port": "9998", "ope_cd": "800003", "datatype": "profile", "protocol": "socket", "socket-type": "fujitsu"}, {"port": "9997", "ope_cd": "800005", "datatype": "exam_rst", "protocol": "socket", "socket-type": "fujitsu"}, {"port": "9996", "ope_cd": "800006", "datatype": "shot_ord", "protocol": "socket", "socket-type": "fujitsu"}, {"port": "9995", "ope_cd": "800007", "datatype": "pre_ord", "protocol": "socket", "socket-type": "fujitsu"}, {"port": "9994", "ope_cd": "800008", "datatype": "staff_mst", "protocol": "socket", "socket-type": "fujitsu"}], "keepDirRoot": "/home/ntss/if_edge/save/receive"}, "urlRoot": "https://dev.nksfn.com/ntss-coop-api/", "tmpDirPath": "/home/ntss/if_edge/tmp", "facility_cd": "MG13CO", "response_telegram": {"type_name": "ResponseType", "skip_value": "N2", "length_name": "TelegramLength", "retry_value": "N1", "socket_type": "fujitsu", "abnormal_value": ["NG", "N3", "N4"], "response_failure": {"header": [{"name": "TlegramType", "value": "", "length": 2}, {"name": "RecordContinuationInstructions", "value": "", "length": 1}, {"name": "DestinationSystemCode", "value": "XX", "length": 2}, {"name": "SourceSystemCode", "value": "VN", "length": 2}, {"name": "DATE", "value": "$DATE", "format": "YYYYMMDD", "length": 8}, {"name": "TIME", "value": "$DATE", "format": "HH24MISS", "length": 6}, {"name": "TerminalName", "value": "VOSERVER", "length": 8}, {"name": "UserID", "value": "00000000", "length": 8}, {"name": "TreatmentDivision", "value": "", "length": 2}, {"name": "ResponseType", "value": "N2", "length": 2}, {"name": "TelegramLength", "value": "000065", "length": 6}, {"name": "ErrorCode", "value": "", "length": 5}, {"name": "Preliminary", "value": "", "length": 12}, {"name": "Terminal", "value": "\r", "length": 1}], "header_length": 65}, "response_success": {"header": [{"name": "TlegramType", "value": "", "length": 2}, {"name": "RecordContinuationInstructions", "value": "", "length": 1}, {"name": "DestinationSystemCode", "value": "XX", "length": 2}, {"name": "SourceSystemCode", "value": "VN", "length": 2}, {"name": "DATE", "value": "$DATE", "format": "YYYYMMDD", "length": 8}, {"name": "TIME", "value": "$DATE", "format": "HH24MISS", "length": 6}, {"name": "TerminalName", "value": "VOSERVER", "length": 8}, {"name": "UserID", "value": "00000000", "length": 8}, {"name": "TreatmentDivision", "value": "", "length": 2}, {"name": "ResponseType", "value": "OK", "length": 2}, {"name": "TelegramLength", "value": "000065", "length": 6}, {"name": "ErrorCode", "value": "", "length": 5}, {"name": "Preliminary", "value": "", "length": 12}, {"name": "Terminal", "value": "\r", "length": 1}], "header_length": 65}, "header_length_included": false}}'
    , common_setting = '{"status": "on", "ins_mode": "FUJITSU_PROFILE", "coop_ope_cd": {"ope_cd_send": [{"ope_cd": "004001", "status": "on"}, {"ope_cd": "004002", "status": "on"}, {"ope_cd": "004003", "status": "on"}, {"ope_cd": "004004", "status": "on"}, {"ope_cd": "004005", "status": "on"}, {"ope_cd": "004006", "status": "on"}, {"ope_cd": "004007", "status": "on"}, {"ope_cd": "004008", "status": "on"}, {"ope_cd": "004009", "status": "on"}, {"ope_cd": "004010", "status": "on"}, {"ope_cd": "004011", "status": "on"}, {"ope_cd": "004012", "status": "on"}, {"ope_cd": "004013", "status": "on"}, {"ope_cd": "004014", "status": "on"}, {"ope_cd": "004015", "status": "on"}, {"ope_cd": "004016", "status": "on"}, {"ope_cd": "004017", "status": "on"}, {"ope_cd": "004018", "status": "on"}, {"ope_cd": "004019", "status": "on"}, {"ope_cd": "004020", "status": "on"}, {"ope_cd": "004021", "status": "on"}, {"ope_cd": "004022", "status": "on"}, {"ope_cd": "004023", "status": "on"}, {"ope_cd": "004024", "status": "on"}, {"ope_cd": "004025", "status": "on"}, {"ope_cd": "004026", "status": "on"}, {"ope_cd": "004027", "status": "on"}, {"ope_cd": "004028", "status": "on"}, {"ope_cd": "011001", "status": "on"}, {"ope_cd": "011002", "status": "on"}, {"ope_cd": "011003", "status": "on"}, {"ope_cd": "011004", "status": "on"}, {"ope_cd": "011005", "status": "on"}, {"ope_cd": "011006", "status": "on"}, {"ope_cd": "011007", "status": "on"}, {"ope_cd": "011008", "status": "on"}, {"ope_cd": "006001", "status": "on"}, {"ope_cd": "006002", "status": "on"}, {"ope_cd": "006003", "status": "on"}, {"ope_cd": "006004", "status": "on"}, {"ope_cd": "006005", "status": "on"}, {"ope_cd": "006006", "status": "on"}, {"ope_cd": "013001", "status": "on"}, {"ope_cd": "009001", "status": "on"}, {"ope_cd": "009002", "status": "on"}, {"ope_cd": "009003", "status": "on"}, {"ope_cd": "021001", "status": "on"}, {"ope_cd": "021002", "status": "on"}, {"ope_cd": "021003", "status": "on"}, {"ope_cd": "021004", "status": "on"}, {"ope_cd": "021005", "status": "on"}, {"ope_cd": "021006", "status": "on"}, {"ope_cd": "021007", "status": "on"}, {"ope_cd": "021008", "status": "on"}, {"ope_cd": "021009", "status": "on"}, {"ope_cd": "021010", "status": "on"}, {"ope_cd": "022001", "status": "on"}, {"ope_cd": "022002", "status": "on"}, {"ope_cd": "022003", "status": "on"}, {"ope_cd": "022004", "status": "on"}, {"ope_cd": "022005", "status": "on"}, {"ope_cd": "022006", "status": "on"}, {"ope_cd": "022007", "status": "on"}, {"ope_cd": "022008", "status": "on"}, {"ope_cd": "022009", "status": "on"}, {"ope_cd": "022010", "status": "on"}, {"ope_cd": "017001", "status": "on"}, {"ope_cd": "007001", "status": "on"}, {"ope_cd": "031001", "status": "on"}, {"ope_cd": "031002", "status": "on"}, {"ope_cd": "031003", "status": "on"}, {"ope_cd": "031004", "status": "on"}, {"ope_cd": "900001", "status": "on"}, {"ope_cd": "900002", "status": "on"}, {"ope_cd": "900003", "status": "on"}, {"ope_cd": "900004", "status": "on"}, {"ope_cd": "007002", "status": "on"}, {"ope_cd": "007003", "status": "on"}, {"ope_cd": "007004", "status": "on"}, {"ope_cd": "007005", "status": "on"}, {"ope_cd": "007006", "status": "on"}, {"ope_cd": "007007", "status": "on"}, {"ope_cd": "007008", "status": "on"}, {"ope_cd": "017002", "status": "on"}, {"ope_cd": "013002", "status": "on"}, {"ope_cd": "027001", "status": "on"}, {"ope_cd": "027002", "status": "on"}, {"ope_cd": "027003", "status": "on"}, {"ope_cd": "027004", "status": "on"}, {"ope_cd": "027005", "status": "on"}, {"ope_cd": "027006", "status": "on"}, {"ope_cd": "004029", "status": "on"}, {"ope_cd": "004030", "status": "on"}, {"ope_cd": "004031", "status": "on"}, {"ope_cd": "004032", "status": "on"}, {"ope_cd": "004033", "status": "on"}, {"ope_cd": "004034", "status": "on"}, {"ope_cd": "004035", "status": "on"}, {"ope_cd": "004036", "status": "on"}, {"ope_cd": "004037", "status": "on"}, {"ope_cd": "004038", "status": "on"}, {"ope_cd": "018001", "status": "on"}, {"ope_cd": "018002", "status": "on"}, {"ope_cd": "018003", "status": "on"}, {"ope_cd": "010001", "status": "on"}, {"ope_cd": "010002", "status": "on"}, {"ope_cd": "010003", "status": "on"}, {"ope_cd": "010004", "status": "on"}, {"ope_cd": "010005", "status": "on"}, {"ope_cd": "010006", "status": "on"}, {"ope_cd": "010007", "status": "on"}, {"ope_cd": "010008", "status": "on"}, {"ope_cd": "010009", "status": "on"}, {"ope_cd": "010010", "status": "on"}, {"ope_cd": "010011", "status": "on"}, {"ope_cd": "028001", "status": "on"}, {"ope_cd": "028002", "status": "on"}, {"ope_cd": "028003", "status": "on"}, {"ope_cd": "028004", "status": "on"}, {"ope_cd": "028005", "status": "on"}, {"ope_cd": "028006", "status": "on"}, {"ope_cd": "028007", "status": "on"}, {"ope_cd": "028008", "status": "on"}, {"ope_cd": "028009", "status": "on"}, {"ope_cd": "028010", "status": "on"}, {"ope_cd": "028011", "status": "on"}, {"ope_cd": "028012", "status": "on"}, {"ope_cd": "028013", "status": "on"}, {"ope_cd": "028014", "status": "on"}, {"ope_cd": "028015", "status": "on"}, {"ope_cd": "028016", "status": "on"}, {"ope_cd": "028017", "status": "on"}, {"ope_cd": "028018", "status": "on"}, {"ope_cd": "028019", "status": "on"}, {"ope_cd": "028020", "status": "on"}, {"ope_cd": "011009", "status": "on"}, {"ope_cd": "004037", "status": "on"}, {"ope_cd": "012001", "status": "on"}, {"ope_cd": "013003", "status": "on"}, {"ope_cd": "013004", "status": "on"}, {"ope_cd": "013005", "status": "on"}], "ope_cd_receive": [{"ope_cd": "800001", "status": "on"}, {"ope_cd": "800002", "status": "on"}, {"ope_cd": "800003", "status": "on"}, {"ope_cd": "800004", "status": "on"}, {"ope_cd": "800005", "status": "on"}, {"ope_cd": "800006", "status": "on"}, {"ope_cd": "800007", "status": "on"}, {"ope_cd": "800008", "status": "on"}]}, "coop_ord_cd": [{"ctl_no": "1", "ope_cd": ["800001"], "coop_cd": "ini_dial", "coop_name": "浄化申し込み・初回指示", "direction": "R", "is_get_no": "true", "ana_result": "0", "coop_result": "9", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}, {"ctl_no": "2", "ope_cd": ["800002"], "coop_cd": "is_death", "coop_name": "死亡退院", "direction": "R", "is_get_no": "true", "ana_result": "0", "coop_result": "9", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}, {"ctl_no": "3", "ope_cd": ["017001", "017002", "007001", "007004", "007005", "007006", "007007", "007008"], "coop_cd": "profile", "coop_name": "患者プロファイル(送信)", "direction": "S", "is_get_no": "true", "ana_result": "0", "coop_result": "0", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}, {"ctl_no": "4", "ope_cd": ["800003"], "coop_cd": "profile", "coop_name": "患者プロファイル(受信)", "direction": "R", "is_get_no": "true", "ana_result": "0", "coop_result": "9", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}, {"ctl_no": "5", "ope_cd": ["004001", "004002", "004003", "004004", "004005", "004006", "004007", "004008", "004009", "004010", "004011", "004012", "004013", "004014", "004015", "004016", "004017", "004018", "004019", "004020", "004021", "004022", "004023", "004024", "004025", "004026", "004027", "004028", "009001", "009002", "009003", "013003", "013004", "013005", "031002", "900001", "007002", "007003", "004029", "004030", "004031", "004032", "004033", "004034", "004035", "004036", "004037", "004038", "010001", "010002", "010003", "010004", "010005", "010006", "010007", "010008", "010009", "010010", "010011", "028001", "028002", "028003", "028004", "028005", "028006", "028007", "028008", "028009", "028010", "028011", "028012", "028013", "028014", "028015", "028016", "028017", "028018", "028019", "028020", "013003", "013004", "013005"], "coop_cd": "ind_dial", "coop_name": "透析予約", "direction": "S", "is_get_no": "true", "ana_result": "0", "coop_result": "0", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}, {"ctl_no": "6", "ope_cd": ["800004"], "coop_cd": "ord_dial", "coop_name": "オーダ受け", "direction": "R", "is_get_no": "true", "ana_result": "0", "coop_result": "9", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}, {"ctl_no": "7", "ope_cd": ["013001", "011009", "004037", "012001"], "coop_cd": "accept", "coop_name": "受付情報", "direction": "S", "is_get_no": "true", "ana_result": "0", "coop_result": "0", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}, {"ctl_no": "8", "ope_cd": ["011001", "011005", "006001", "006004", "006006", "013002", "027001", "027002", "027003", "027004", "027005", "027006", "004039", "018001", "018002", "018003"], "coop_cd": "rst_dial", "coop_name": "透析実績", "direction": "S", "is_get_no": "true", "ana_result": "0", "coop_result": "0", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}, {"ctl_no": "9", "ope_cd": ["011004", "011008", "006003", "006005"], "coop_cd": "rep_dial", "coop_name": "透析レポート", "direction": "S", "is_get_no": "true", "ana_result": "0", "coop_result": "0", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}, {"ctl_no": "10", "ope_cd": ["031005"], "coop_cd": "exam_rst", "coop_name": "検査結果(定時一括送信)", "direction": "S", "is_get_no": "true", "ana_result": "0", "coop_result": "0", "createIndex": "false", "effect_days": 6, "coop_cd_index": "send_time", "time_out_second": 10}, {"ctl_no": "11", "ope_cd": ["800005"], "coop_cd": "exam_rst", "coop_name": "検査結果(受信)", "direction": "R", "is_get_no": "true", "ana_result": "0", "coop_result": "9", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}, {"ctl_no": "12", "ope_cd": ["021001", "021002", "021003", "021004", "021005", "021006", "021007", "021008", "021009", "021010", "031003", "900002"], "coop_cd": "exam_ord", "coop_name": "検査オーダ", "direction": "S", "is_get_no": "true", "ana_result": "0", "coop_result": "0", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}, {"ctl_no": "13", "ope_cd": ["022001", "022002", "022003", "022004", "022005", "022006", "022007", "022008", "022009", "022010", "031004", "900003"], "coop_cd": "rad_ord", "coop_name": "放射線検査オーダ", "direction": "S", "is_get_no": "true", "ana_result": "0", "coop_result": "0", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}, {"ctl_no": "14", "ope_cd": ["XXXX", "XXXX", "XXXX"], "coop_cd": "phy_ord", "coop_name": "心電図検査オーダ", "direction": "S", "is_get_no": "true", "ana_result": "0", "coop_result": "0", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}, {"ctl_no": "15", "ope_cd": ["800006"], "coop_cd": "shot_ord", "coop_name": "透析注射連携", "direction": "R", "is_get_no": "true", "ana_result": "0", "coop_result": "9", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}, {"ctl_no": "16", "ope_cd": ["800007"], "coop_cd": "pre_ord", "coop_name": "処方情報連携", "direction": "R", "is_get_no": "true", "ana_result": "0", "coop_result": "9", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}, {"ctl_no": "17", "ope_cd": ["800008"], "coop_cd": "staff_mst", "coop_name": "スタッフマスタ連携", "direction": "R", "is_get_no": "true", "ana_result": "0", "coop_result": "9", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}, {"ctl_no": "18", "ope_cd": ["011003", "011007"], "coop_cd": "vit_cop", "coop_name": "バイタル連携", "direction": "S", "is_get_no": "true", "ana_result": "0", "coop_result": "0", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}, {"ctl_no": "19", "ope_cd": ["011002", "011006", "006002"], "coop_cd": "karte_ord", "coop_name": "カルテ記載連携", "direction": "S", "is_get_no": "true", "ana_result": "0", "coop_result": "0", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}, {"ctl_no": "20", "ope_cd": ["031001"], "coop_cd": "profile", "coop_name": "患者プロファイル(定時一括送信)", "direction": "S", "is_get_no": "true", "ana_result": "0", "coop_result": "0", "createIndex": "false", "effect_days": 6, "coop_cd_index": "send_time", "time_out_second": 10}, {"ctl_no": "21", "ope_cd": ["900004"], "coop_cd": "", "coop_name": "連携イベント作成・中止ツール(送信)", "direction": "S", "is_get_no": "true", "ana_result": "0", "coop_result": "0", "createIndex": "false", "effect_days": 6, "coop_cd_index": "", "time_out_second": 10}], "dataset_limit": "1000", "journal_keep_days": "100"}'
    , user_id = 4
    , reg_date = now()
    , up_date = now() 
where
    facility_cd = 'F_hosp';
    
update ntss.mst_coop_facility 
set
    common_setting = '{
    "status": "on",
    "ins_mode": "FUJITSU_PROFILE",
    "coop_ope_cd": {
        "ope_cd_send": [
            {
                "ope_cd": "004001",
                "status": "on"
            },
            {
                "ope_cd": "004002",
                "status": "on"
            },
            {
                "ope_cd": "004003",
                "status": "on"
            },
            {
                "ope_cd": "004004",
                "status": "on"
            },
            {
                "ope_cd": "004005",
                "status": "on"
            },
            {
                "ope_cd": "004006",
                "status": "on"
            },
            {
                "ope_cd": "004007",
                "status": "on"
            },
            {
                "ope_cd": "004008",
                "status": "on"
            },
            {
                "ope_cd": "004009",
                "status": "on"
            },
            {
                "ope_cd": "004010",
                "status": "on"
            },
            {
                "ope_cd": "004011",
                "status": "on"
            },
            {
                "ope_cd": "004012",
                "status": "on"
            },
            {
                "ope_cd": "004013",
                "status": "on"
            },
            {
                "ope_cd": "004014",
                "status": "on"
            },
            {
                "ope_cd": "004015",
                "status": "on"
            },
            {
                "ope_cd": "004016",
                "status": "on"
            },
            {
                "ope_cd": "004017",
                "status": "on"
            },
            {
                "ope_cd": "004018",
                "status": "on"
            },
            {
                "ope_cd": "004019",
                "status": "on"
            },
            {
                "ope_cd": "004020",
                "status": "on"
            },
            {
                "ope_cd": "004021",
                "status": "on"
            },
            {
                "ope_cd": "004022",
                "status": "on"
            },
            {
                "ope_cd": "004023",
                "status": "on"
            },
            {
                "ope_cd": "004024",
                "status": "on"
            },
            {
                "ope_cd": "004025",
                "status": "on"
            },
            {
                "ope_cd": "004026",
                "status": "on"
            },
            {
                "ope_cd": "004027",
                "status": "on"
            },
            {
                "ope_cd": "004028",
                "status": "on"
            },
            {
                "ope_cd": "011001",
                "status": "on"
            },
            {
                "ope_cd": "011002",
                "status": "on"
            },
            {
                "ope_cd": "011003",
                "status": "on"
            },
            {
                "ope_cd": "011004",
                "status": "on"
            },
            {
                "ope_cd": "011005",
                "status": "on"
            },
            {
                "ope_cd": "011006",
                "status": "on"
            },
            {
                "ope_cd": "011007",
                "status": "on"
            },
            {
                "ope_cd": "011008",
                "status": "on"
            },
            {
                "ope_cd": "006001",
                "status": "on"
            },
            {
                "ope_cd": "006002",
                "status": "on"
            },
            {
                "ope_cd": "006003",
                "status": "on"
            },
            {
                "ope_cd": "006004",
                "status": "on"
            },
            {
                "ope_cd": "006005",
                "status": "on"
            },
            {
                "ope_cd": "006006",
                "status": "on"
            },
            {
                "ope_cd": "013001",
                "status": "on"
            },
            {
                "ope_cd": "009001",
                "status": "on"
            },
            {
                "ope_cd": "009002",
                "status": "on"
            },
            {
                "ope_cd": "009003",
                "status": "on"
            },
            {
                "ope_cd": "021001",
                "status": "on"
            },
            {
                "ope_cd": "021002",
                "status": "on"
            },
            {
                "ope_cd": "021003",
                "status": "on"
            },
            {
                "ope_cd": "021004",
                "status": "on"
            },
            {
                "ope_cd": "021005",
                "status": "on"
            },
            {
                "ope_cd": "021006",
                "status": "on"
            },
            {
                "ope_cd": "021007",
                "status": "on"
            },
            {
                "ope_cd": "021008",
                "status": "on"
            },
            {
                "ope_cd": "021009",
                "status": "on"
            },
            {
                "ope_cd": "021010",
                "status": "on"
            },
            {
                "ope_cd": "022001",
                "status": "on"
            },
            {
                "ope_cd": "022002",
                "status": "on"
            },
            {
                "ope_cd": "022003",
                "status": "on"
            },
            {
                "ope_cd": "022004",
                "status": "on"
            },
            {
                "ope_cd": "022005",
                "status": "on"
            },
            {
                "ope_cd": "022006",
                "status": "on"
            },
            {
                "ope_cd": "022007",
                "status": "on"
            },
            {
                "ope_cd": "022008",
                "status": "on"
            },
            {
                "ope_cd": "022009",
                "status": "on"
            },
            {
                "ope_cd": "022010",
                "status": "on"
            },
            {
                "ope_cd": "017001",
                "status": "on"
            },
            {
                "ope_cd": "007001",
                "status": "on"
            },
            {
                "ope_cd": "031001",
                "status": "on"
            },
            {
                "ope_cd": "031002",
                "status": "on"
            },
            {
                "ope_cd": "031003",
                "status": "on"
            },
            {
                "ope_cd": "031004",
                "status": "on"
            },
            {
                "ope_cd": "900001",
                "status": "on"
            },
            {
                "ope_cd": "900002",
                "status": "on"
            },
            {
                "ope_cd": "900003",
                "status": "on"
            },
            {
                "ope_cd": "900004",
                "status": "on"
            },
            {
                "ope_cd": "007002",
                "status": "on"
            },
            {
                "ope_cd": "007003",
                "status": "on"
            },
            {
                "ope_cd": "007004",
                "status": "on"
            },
            {
                "ope_cd": "007005",
                "status": "on"
            },
            {
                "ope_cd": "007006",
                "status": "on"
            },
            {
                "ope_cd": "007007",
                "status": "on"
            },
            {
                "ope_cd": "007008",
                "status": "on"
            },
            {
                "ope_cd": "017002",
                "status": "on"
            },
            {
                "ope_cd": "013002",
                "status": "on"
            },
            {
                "ope_cd": "027001",
                "status": "on"
            },
            {
                "ope_cd": "027002",
                "status": "on"
            },
            {
                "ope_cd": "027003",
                "status": "on"
            },
            {
                "ope_cd": "027004",
                "status": "on"
            },
            {
                "ope_cd": "027005",
                "status": "on"
            },
            {
                "ope_cd": "027006",
                "status": "on"
            },
            {
                "ope_cd": "004029",
                "status": "on"
            },
            {
                "ope_cd": "004030",
                "status": "on"
            },
            {
                "ope_cd": "004031",
                "status": "on"
            },
            {
                "ope_cd": "004032",
                "status": "on"
            },
            {
                "ope_cd": "004033",
                "status": "on"
            },
            {
                "ope_cd": "004034",
                "status": "on"
            },
            {
                "ope_cd": "004035",
                "status": "on"
            },
            {
                "ope_cd": "004036",
                "status": "on"
            },
            {
                "ope_cd": "004037",
                "status": "on"
            },
            {
                "ope_cd": "004038",
                "status": "on"
            },
            {
                "ope_cd": "018001",
                "status": "on"
            },
            {
                "ope_cd": "018002",
                "status": "on"
            },
            {
                "ope_cd": "018003",
                "status": "on"
            },
            {
                "ope_cd": "010001",
                "status": "on"
            },
            {
                "ope_cd": "010002",
                "status": "on"
            },
            {
                "ope_cd": "010003",
                "status": "on"
            },
            {
                "ope_cd": "010004",
                "status": "on"
            },
            {
                "ope_cd": "010005",
                "status": "on"
            },
            {
                "ope_cd": "010006",
                "status": "on"
            },
            {
                "ope_cd": "010007",
                "status": "on"
            },
            {
                "ope_cd": "010008",
                "status": "on"
            },
            {
                "ope_cd": "010009",
                "status": "on"
            },
            {
                "ope_cd": "010010",
                "status": "on"
            },
            {
                "ope_cd": "010011",
                "status": "on"
            },
            {
                "ope_cd": "028001",
                "status": "on"
            },
            {
                "ope_cd": "028002",
                "status": "on"
            },
            {
                "ope_cd": "028003",
                "status": "on"
            },
            {
                "ope_cd": "028004",
                "status": "on"
            },
            {
                "ope_cd": "028005",
                "status": "on"
            },
            {
                "ope_cd": "028006",
                "status": "on"
            },
            {
                "ope_cd": "028007",
                "status": "on"
            },
            {
                "ope_cd": "028008",
                "status": "on"
            },
            {
                "ope_cd": "028009",
                "status": "on"
            },
            {
                "ope_cd": "028010",
                "status": "on"
            },
            {
                "ope_cd": "028011",
                "status": "on"
            },
            {
                "ope_cd": "028012",
                "status": "on"
            },
            {
                "ope_cd": "028013",
                "status": "on"
            },
            {
                "ope_cd": "028014",
                "status": "on"
            },
            {
                "ope_cd": "028015",
                "status": "on"
            },
            {
                "ope_cd": "028016",
                "status": "on"
            },
            {
                "ope_cd": "028017",
                "status": "on"
            },
            {
                "ope_cd": "028018",
                "status": "on"
            },
            {
                "ope_cd": "028019",
                "status": "on"
            },
            {
                "ope_cd": "028020",
                "status": "on"
            },
            {
                "ope_cd": "011009",
                "status": "on"
            },
            {
                "ope_cd": "004037",
                "status": "on"
            },
            {
                "ope_cd": "012001",
                "status": "on"
            },
            {
                "ope_cd": "013003",
                "status": "on"
            },
            {
                "ope_cd": "013004",
                "status": "on"
            },
            {
                "ope_cd": "013005",
                "status": "on"
            }
        ],
        "ope_cd_receive": [
            {
                "ope_cd": "800001",
                "status": "on"
            },
            {
                "ope_cd": "800002",
                "status": "on"
            },
            {
                "ope_cd": "800003",
                "status": "on"
            },
            {
                "ope_cd": "800004",
                "status": "on"
            },
            {
                "ope_cd": "800005",
                "status": "on"
            },
            {
                "ope_cd": "800006",
                "status": "on"
            },
            {
                "ope_cd": "800007",
                "status": "on"
            },
            {
                "ope_cd": "800008",
                "status": "on"
            }
        ]
    },
    "coop_ord_cd": [
        {
            "ctl_no": "1",
            "ope_cd": [
                "800001"
            ],
            "coop_cd": "ini_dial",
            "coop_name": "浄化申し込み・初回指示",
            "direction": "R",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "9",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "",
            "time_out_second": 10
        },
        {
            "ctl_no": "2",
            "ope_cd": [
                "800002"
            ],
            "coop_cd": "is_death",
            "coop_name": "死亡退院",
            "direction": "R",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "9",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "",
            "time_out_second": 10
        },
        {
            "ctl_no": "3",
            "ope_cd": [
                "017001",
                "017002",
                "007001",
                "007004",
                "007005",
                "007006",
                "007007",
                "007008"
            ],
            "coop_cd": "profile",
            "coop_name": "患者プロファイル(送信)",
            "direction": "S",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "0",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "000001001",
            "time_out_second": 10
        },
        {
            "ctl_no": "4",
            "ope_cd": [
                "800003"
            ],
            "coop_cd": "profile",
            "coop_name": "患者プロファイル(受信)",
            "direction": "R",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "9",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "",
            "time_out_second": 10
        },
        {
            "ctl_no": "5",
            "ope_cd": [
                "004001",
                "004002",
                "004003",
                "004004",
                "004005",
                "004006",
                "004007",
                "004008",
                "004009",
                "004010",
                "004011",
                "004012",
                "004013",
                "004014",
                "004015",
                "004016",
                "004017",
                "004018",
                "004019",
                "004020",
                "004021",
                "004022",
                "004023",
                "004024",
                "004025",
                "004026",
                "004027",
                "004028",
                "009001",
                "009002",
                "009003",
                "013003",
                "013004",
                "013005",
                "031002",
                "900001",
                "007002",
                "007003",
                "004029",
                "004030",
                "004031",
                "004032",
                "004033",
                "004034",
                "004035",
                "004036",
                "004037",
                "004038",
                "010001",
                "010002",
                "010003",
                "010004",
                "010005",
                "010006",
                "010007",
                "010008",
                "010009",
                "010010",
                "010011",
                "028001",
                "028002",
                "028003",
                "028004",
                "028005",
                "028006",
                "028007",
                "028008",
                "028009",
                "028010",
                "028011",
                "028012",
                "028013",
                "028014",
                "028015",
                "028016",
                "028017",
                "028018",
                "028019",
                "028020",
                "013003",
                "013004",
                "013005"
            ],
            "coop_cd": "ind_dial",
            "coop_name": "透析予約",
            "direction": "S",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "0",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "",
            "time_out_second": 10
        },
        {
            "ctl_no": "6",
            "ope_cd": [
                "800004"
            ],
            "coop_cd": "ord_dial",
            "coop_name": "オーダ受け",
            "direction": "R",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "9",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "",
            "time_out_second": 10
        },
        {
            "ctl_no": "7",
            "ope_cd": [
                "013001",
                "011009",
                "004037",
                "012001"
            ],
            "coop_cd": "accept",
            "coop_name": "受付情報",
            "direction": "S",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "0",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "",
            "time_out_second": 10
        },
        {
            "ctl_no": "8",
            "ope_cd": [
                "011001",
                "011005",
                "006001",
                "006004",
                "006006",
                "013002",
                "027001",
                "027002",
                "027003",
                "027004",
                "027005",
                "027006",
                "004039",
                "018001",
                "018002",
                "018003"
            ],
            "coop_cd": "rst_dial",
            "coop_name": "透析実績",
            "direction": "S",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "0",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "",
            "time_out_second": 10
        },
        {
            "ctl_no": "9",
            "ope_cd": [
                "011004",
                "011008",
                "006003",
                "006005"
            ],
            "coop_cd": "rep_dial",
            "coop_name": "透析レポート",
            "direction": "S",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "0",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "",
            "time_out_second": 10
        },
        {
            "ctl_no": "10",
            "ope_cd": [
                "031005"
            ],
            "coop_cd": "exam_rst",
            "coop_name": "検査結果(定時一括送信)",
            "direction": "S",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "0",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "send_time",
            "time_out_second": 10
        },
        {
            "ctl_no": "11",
            "ope_cd": [
                "800005"
            ],
            "coop_cd": "exam_rst",
            "coop_name": "検査結果(受信)",
            "direction": "R",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "9",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "",
            "time_out_second": 10
        },
        {
            "ctl_no": "12",
            "ope_cd": [
                "021001",
                "021002",
                "021003",
                "021004",
                "021005",
                "021006",
                "021007",
                "021008",
                "021009",
                "021010",
                "031003",
                "900002"
            ],
            "coop_cd": "exam_ord",
            "coop_name": "検査オーダ",
            "direction": "S",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "0",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "",
            "time_out_second": 10
        },
        {
            "ctl_no": "13",
            "ope_cd": [
                "022001",
                "022002",
                "022003",
                "022004",
                "022005",
                "022006",
                "022007",
                "022008",
                "022009",
                "022010",
                "031004",
                "900003"
            ],
            "coop_cd": "rad_ord",
            "coop_name": "放射線検査オーダ",
            "direction": "S",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "0",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "",
            "time_out_second": 10
        },
        {
            "ctl_no": "14",
            "ope_cd": [
                "XXXX",
                "XXXX",
                "XXXX"
            ],
            "coop_cd": "phy_ord",
            "coop_name": "心電図検査オーダ",
            "direction": "S",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "0",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "",
            "time_out_second": 10
        },
        {
            "ctl_no": "15",
            "ope_cd": [
                "800006"
            ],
            "coop_cd": "shot_ord",
            "coop_name": "透析注射連携",
            "direction": "R",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "9",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "",
            "time_out_second": 10
        },
        {
            "ctl_no": "16",
            "ope_cd": [
                "800007"
            ],
            "coop_cd": "pre_ord",
            "coop_name": "処方情報連携",
            "direction": "R",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "9",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "",
            "time_out_second": 10
        },
        {
            "ctl_no": "17",
            "ope_cd": [
                "800008"
            ],
            "coop_cd": "staff_mst",
            "coop_name": "スタッフマスタ連携",
            "direction": "R",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "9",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "",
            "time_out_second": 10
        },
        {
            "ctl_no": "18",
            "ope_cd": [
                "011003",
                "011007"
            ],
            "coop_cd": "vit_cop",
            "coop_name": "バイタル連携",
            "direction": "S",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "0",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "",
            "time_out_second": 10
        },
        {
            "ctl_no": "19",
            "ope_cd": [
                "011002",
                "011006",
                "006002"
            ],
            "coop_cd": "karte_ord",
            "coop_name": "カルテ記載連携",
            "direction": "S",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "0",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "",
            "time_out_second": 10
        },
        {
            "ctl_no": "20",
            "ope_cd": [
                "031001"
            ],
            "coop_cd": "profile",
            "coop_name": "患者プロファイル(定時一括送信)",
            "direction": "S",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "0",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "send_time",
            "time_out_second": 10
        },
        {
            "ctl_no": "21",
            "ope_cd": [
                "900004"
            ],
            "coop_cd": "",
            "coop_name": "連携イベント作成・中止ツール(送信)",
            "direction": "S",
            "is_get_no": "true",
            "ana_result": "0",
            "coop_result": "0",
            "createIndex": "false",
            "effect_days": 6,
            "coop_cd_index": "",
            "time_out_second": 10
        }
    ],
    "dataset_limit": "1000",
    "journal_keep_days": "100"
}'
    , reg_date = now()
    , up_date = now() 
where
    facility_cd = 'MG13CO';