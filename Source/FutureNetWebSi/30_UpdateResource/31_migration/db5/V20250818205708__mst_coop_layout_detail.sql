-- DELETE (by ctl_no) + INSERT (rows for facility_cd = 'Secom')
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no IN ('-1103500001','-1104000000','-1104000001','-1104000002','-1104000003','-1104000004','-1104000005','-1104000006','-1104000007','-1104000008','-1104000009','-1104000010','-1104000011','-1104000012','-1104000013','-1104000014','-1104000015','-1104000016','-1104000017','-1104000018','-1104000019','-1104000020','-1104000021','-1104000022','-1104000023','-1104000024','-1104000025','-1104000026','-1104000027','-1104000028','-1104000029','-1104000030','-1104000031','-1104000032','-1104000033','-11040004','-1107000000','-1107000001','-1107000002','-1107000003','-1107000004','-1107000005','-1107000006','-1107000007','-1107000008','-1107000009','-1107000010','-1107000011','-1107000012','-1107000013','-1107000014','-1107000015','-1107000016','-1107000017','-1107000018','-1107000019','-1107000020','-1107000021','-1107000022','-1107000023','-1107000024','-1107000025','-1107000026','-1107000027','-1110100001','-1110100002','-1110100003','-1110200001','-1110200002','-1111000001','-1111000002','-1111000003','-1111000004','-1111000005','-1111000006','-1111000007','-1111000008');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1103500001','Secom','profile','R','患者プロファイル詳細','pre','セコム患者プロファイル患者プロファイル項目','患者プロファイル項目','1','<root name="患者プロファイル連携詳細(pre)">
<item name="プロファイル項目連番" len="2" type="string"/>
<item name="プロファイルコード" len="5" col="$journal.detail.pat_main.profile_code" type="string"/>
<item name="データタイプ" len="2" col="$journal.detail.pat_main.data_type" type="string"/>
<item name="データ長" len="6" type="string" data_length=""/>
<item name="データ内容" len="0" col="$journal.detail.pat_main.content" type="string" data_length_use=""/>
</root>
','{}'::jsonb,'1','0','-1','2025-05-18T22:33:05.959',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000000','Secom','ind_dial','S','res_top_cre','01','セコム連携_透析指示連携','セコム連携_透析指示連携_予約受付_cre','1','<root name="セコム連携_透析指示_予約受付" multi="true:CRLF">
<item name="更新モード" value="const:0"/>
<item name="予約担当者ユーザID" value="dataset:-1102000.res_user_id"/>
<item name="予約番号" value="$BLANK"/>
<item name="診察券番号・患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="患者氏名(漢字)" value="$BLANK"/>
<item name="患者氏名(ふりがな)" value="$BLANK"/>
<item name="受付・予約タイプ" value="const:1"/>
<item name="登録日時" value="$BLANK"/>
<item name="予約予定日時" value="dataset:-1104000.appointment_date"/>
<item name="シーケンス番号" value="dataset:-1102000.coop_ord_no"/>
<item name="予約枠コード+コメント" value="dataset:-1102000.res_cd_comment"/>
</root>','{"dataset": [{"key0": "-1102006.key0", "ctlNo": "-1102006.ctl_no", "ordNo": "-1102006.ord_no", "patId": "-1102006.pat_id", "sqlCode": -1102000, "facilityCd": "-1102006.facility_cd"}, {"key0": "-1102006.key0", "patId": "-1102006.pat_id", "sqlCode": -1100006, "facilityCd": "-1102006.facility_cd"}, {"ordNo": "ordNo", "sqlCode": -1104000, "facilityCd": "-1102006.facility_cd"}]}'::jsonb,'1','0','5843','2025-07-08T15:03:28.373',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000001','Secom','ind_dial','S','res_top_del','01','セコム連携_透析指示連携','セコム連携_透析指示連携_予約受付_del','1','<root name="セコム連携_透析指示_予約受付">
<item name="更新モード" value="const:1"/>
<item name="予約担当者ユーザID" value="dataset:-1102031.col2"/>
<item name="予約番号" value="$BLANK"/>
<item name="診察券番号・患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="患者氏名(漢字)" value="$BLANK"/>
<item name="患者氏名(ふりがな)" value="$BLANK"/>
<item name="受付・予約タイプ" value="const:1"/>
<item name="登録日時" value="$BLANK"/>
<item name="予約予定日時" value="dataset:-1102031.col9"/>
<item name="シーケンス番号" value="dataset:-1102000.coop_ord_no"/>
<item name="予約枠コード+コメント" value="dataset:-1102000.res_cd_comment"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"ordNo": "ordNo", "sqlCode": -1104000, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102031, "facilityCd": "facility_cd", "fileSubKind": "res"}]}'::jsonb,'1','0','5843','2025-07-02T17:37:53.252',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000002','Secom','ind_dial','S','trt_top_cre','01','セコム連携_透析指示連携','セコム連携_透析指示_処置依頼','1','<root name="処置依頼" useSharedSysdate="true">
<file name="オーダーインデックス" detail="trt_index_cre" sqlCode="-1102016"/>
<file name="処置ヘッダー" detail="trt_header_cre" sqlCode="-1102017"/>
<file name="処置単位" detail="trt_unit_top_cre" sqlCode="-1102018"/>
<file name="処置項目" detail="trt_item_top_cre" sqlCode="-1102019"/>
<file name="ファイル作成終了" detail="trt_finish" sqlCode="-1102020"/>
</root>
','{"dataset": [{"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "TREAT_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102016, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "TREAT_HEAD_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102017, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "TREAT_RP_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102018, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "TREAT_ITEM_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102019, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102020, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb,'1','0','-1','2025-06-26T23:35:08.627',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000003','Secom','ind_dial','S','trt_top_del','01','セコム連携_透析指示連携','セコム連携_透析指示_処置依頼','1','<root name="処置依頼" useSharedSysdate="true">
<file name="オーダーインデックス" detail="trt_index_del" sqlCode="-1102016"/>
<file name="処置ヘッダー" detail="trt_header_del" sqlCode="-1102017"/>
<file name="処置単位" detail="trt_unit_top_del" sqlCode="-1102018"/>
<file name="処置項目" detail="trt_item_top_del" sqlCode="-1102019"/>
<file name="ファイル作成終了" detail="trt_finish" sqlCode="-1102020"/>
</root>
','{"dataset": [{"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "TREAT_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102016, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "TREAT_HEAD_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102017, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "TREAT_RP_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102018, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "TREAT_ITEM_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102019, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102020, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb,'1','0','-1','2025-06-26T23:35:08.627',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000004','Secom','ind_dial','S','trt_unit_top_cre','01','セコム連携_透析指示連携','処置依頼ファイル_処置単位','1','<root name="セコム連携_透析指示_処置依頼ファイル_実施単位">
<record detail="trt_unit_cre" sqlCode="-1102015"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102015, "facilityCd": "facility_cd"}]}'::jsonb,'1','0','-1','2025-06-27T14:08:24.4',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000005','Secom','ind_dial','S','trt_item_top_cre','01','セコム連携_透析指示連携','処置依頼ファイル_処置項目','1','<root name="セコム連携_透析指示_処置依頼ファイル_実施項目">
<record detail="trt_item_cre" sqlCode="-1102002"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102002, "facilityCd": "facility_cd"}]}'::jsonb,'1','0','-1','2025-06-27T14:08:24.4',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000006','Secom','ind_dial','S','trt_index_cre','01','セコム連携_透析指示連携','処置依頼ファイル_オーダーインデックス','1','<root name="セコム連携_透析指示_処置依頼ファイル_オーダーインデックス">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1102000.user_id"/>
<item name="INDEX区分" value="const:2"/>
<item name="XX区分" value="const:61"/>
<item name="タイトル" value="dataset:-1102000.treat_title"/>
<item name="診療科コード" value="dataset:-1100000.course_cd2"/>
<item name="事業所コード" value="const:000"/>
<item name="入外区分" value="dataset:-1100006.in_out_class"/>
<item name="開始日" value="dataset:-1102000.treat_date"/>
<item name="終了日" value="dataset:-1102000.treat_date"/>
<item name="実施時刻" value="$BLANK"/>
<item name="中止フラグ" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="事後入力フラグ" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}]}'::jsonb,'1','0','-1','2025-06-27T14:08:24.4',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000007','Secom','ind_dial','S','trt_header_cre','01','セコム連携_透析指示連携','処置依頼ファイル_処置ヘッダー','1','<root name="処置ヘッダー">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1102000.user_id"/>
<item name="指示区分" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="依頼発生日" value="$BLANK"/>
<item name="依頼SEQ番号" value="$BLANK"/>
<item name="依頼ユーザID" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}]}'::jsonb,'1','0','-1','2025-06-27T14:08:24.4',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000008','Secom','ind_dial','S','trt_unit_cre','01','セコム連携_透析指示連携','処置依頼ファイル_処置単位','1','<root name="処置単位">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1102000.user_id"/>
<item name="指示区分" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="RP番号(処置番号)" value="dataset:-1100014.e01"/>
<item name="処置タイミング" value="const:0"/>
<item name="処置開始日" value="dataset:-1102000.treat_date"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="処置終了日" value="dataset:-1102000.treat_date"/>
<item name="フリーコメント1" value="$BLANK"/>
<item name="フリーコメント2" value="$BLANK"/>
<item name="フリーコメント3" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="診療区分コード" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1100015, "fileKind": "treatment", "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1102015.rp_no", "e02": "''''", "e03": "''''", "e04": "''''", "e05": "''''", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb,'1','0','-1','2025-06-27T14:08:24.4',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000009','Secom','ind_dial','S','trt_item_cre','01','セコム連携_透析指示連携','処置依頼ファイル_処置項目','1','<root name="処置項目">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1102000.user_id"/>
<item name="指示区分" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="RP番号(処置番号)" value="dataset:-1100014.e01"/>
<item name="処置項目番号" value="dataset:-1100014.e02"/>
<item name="処置項目コード" value="dataset:-1100014.e03"/>
<item name="未使用" value="$BLANK"/>
<item name="処置数量" value="dataset:-1100014.e04"/>
<item name="単位コード" value="dataset:-1100014.e05"/>
<item name="未使用" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1100015, "fileKind": "treatment", "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1102002.rp_no", "e02": "-1102002.item_no", "e03": "-1102002.medi_cd", "e04": "-1102002.medi_amount", "e05": "-1102002.unit", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb,'1','0','-1','2025-06-27T14:08:24.4',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000010','Secom','ind_dial','S','trt_finish','01','セコム連携_透析指示連携','処置依頼ファイル_ファイル作成終了','1','<root name="ファイル作成終了">
</root>','{}'::jsonb,'1','0','-1','2025-06-27T14:08:24.4',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000011','Secom','ind_dial','S','inj_top_cre','01','セコム連携_透析指示連携','セコム連携_透析指示_注射依頼_cre','1','<root name="透析指示_注射依頼" useSharedSysdate="true">
<file name="セコム連携_透析指示_注射依頼ファイル_オーダーインデックス" detail="inj_index_cre" sqlCode="-1102021"/>
<file name="セコム連携_透析指示_注射依頼ファイル_注射ヘッダー" detail="inj_header_cre" sqlCode="-1102022"/>
<file name="セコム連携_透析指示_注射依頼ファイル_実施単位" detail="inj_unit_top_cre" sqlCode="-1102023"/>
<file name="セコム連携_透析指示_注射依頼ファイル_処置項目" detail="inj_item_top_cre" sqlCode="-1102024"/>
<file name="セコム連携_透析指示_注射依頼ファイル_ファイル作成終了" detail="inj_finish" sqlCode="-1102025"/>
</root>','{"dataset": [{"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102021, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_HEAD_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102022, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_RP_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102023, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_ITEM_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102024, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102025, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb,'1','0','-1','2025-06-26T23:43:00.02',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000012','Secom','ind_dial','S','inj_top_del','01','セコム連携_透析指示連携','セコム連携_透析指示_注射依頼_del','1','<root name="透析指示_注射依頼" useSharedSysdate="true">
<file name="セコム連携_透析指示_注射依頼ファイル_オーダーインデックス" detail="inj_index_del" sqlCode="-1102021"/>
<file name="セコム連携_透析指示_注射依頼ファイル_注射ヘッダー" detail="inj_header_del" sqlCode="-1102022"/>
<file name="セコム連携_透析指示_注射依頼ファイル_実施単位" detail="inj_unit_top_del" sqlCode="-1102023"/>
<file name="セコム連携_透析指示_注射依頼ファイル_処置項目" detail="inj_item_top_del" sqlCode="-1102024"/>
<file name="セコム連携_透析指示_注射依頼ファイル_ファイル作成終了" detail="inj_finish" sqlCode="-1102025"/>
</root>','{"dataset": [{"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102021, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_HEAD_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102022, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_RP_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102023, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_ITEM_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102024, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102025, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb,'1','0','-1','2025-06-26T23:43:00.02',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000013','Secom','ind_dial','S','inj_unit_top_cre','01','セコム連携_透析指示連携','注射依頼ファイル_実施単位_cre','1','<root name="セコム連携_透析指示_注射依頼ファイル_実施単位">
<record name="セコム連携_透析指示_注射依頼ファイル_実施単位" detail="inj_unit_cre" sqlCode="-1102003" />
</root>','{"dataset": [{"key0": "-1102023.key0", "ctlNo": "-1102023.ctl_no", "ordNo": "-1102023.ord_no", "patId": "-1102023.pat_id", "sqlCode": -1102003, "facilityCd": "-1102023.facility_cd"}]}'::jsonb,'1','0','-1','2025-07-08T15:03:27.649',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000014','Secom','ind_dial','S','inj_item_top_cre','01','セコム連携_透析指示連携','注射依頼ファイル_処置項目_cre','1','<root name="セコム連携_透析指示_注射依頼ファイル_処置項目">
<record name="セコム連携_透析指示_注射依頼ファイル_処置項目" detail="inj_item_cre" sqlCode="-1102011" />
</root>','{"dataset": [{"key0": "-1102024.key0", "ctlNo": "-1102024.ctl_no", "ordNo": "-1102024.ord_no", "patId": "-1102024.pat_id", "sqlCode": -1102011, "facilityCd": "-1102024.facility_cd"}]}'::jsonb,'1','0','-1','2025-07-08T15:03:27.649',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000015','Secom','ind_dial','S','inj_index_cre','01','セコム連携_透析指示連携','注射依頼ファイル_オーダーインデックス_cre','1','<root name="セコム連携_透析指示_注射依頼ファイル_オーダーインデックス">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1102000.user_id"/>
<item name="INDEX区分" value="const:2"/>
<item name="XX区分" value="const:11"/>
<item name="タイトル" value="dataset:-1102000.shot_title"/>
<item name="診療科コード" value="dataset:-1100000.course_cd2"/>
<item name="事業所コード" value="const:000"/>
<item name="入外区分" value="dataset:-1100006.in_out_class"/>
<item name="開始日" value="dataset:-1102000.treat_date"/>
<item name="終了日" value="dataset:-1102000.treat_date"/>
<item name="実施時刻" value="$BLANK"/>
<item name="中止フラグ" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="事後入力フラグ" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
</root>','{"dataset": [{"key0": "-1102021.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102021.ctl_no", "ordNo": "-1102021.ord_no", "patId": "-1102021.pat_id", "sqlCode": -1100000, "facilityCd": "-1102021.facility_cd"}, {"key0": "-1102021.key0", "ctlNo": "-1102021.ctl_no", "ordNo": "-1102021.ord_no", "patId": "-1102021.pat_id", "sqlCode": -1102000, "facilityCd": "-1102021.facility_cd"}, {"key0": "-1102021.key0", "patId": "-1102021.pat_id", "sqlCode": -1100006, "facilityCd": "-1102021.facility_cd"}]}'::jsonb,'1','0','-1','2025-07-08T15:03:27.649',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000016','Secom','ind_dial','S','inj_index_del','01','セコム連携_透析指示連携','注射依頼ファイル_オーダーインデックス_del','1','<root name="セコム連携_透析指示_注射依頼ファイル_オーダーインデックス">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1102031.col3"/>
<item name="SEQ番号" value="dataset:-1102031.col4"/>
<item name="ユーザID" value="dataset:-1102031.col5"/>
<item name="INDEX区分" value="const:2"/>
<item name="XX区分" value="const:11"/>
<item name="タイトル" value="dataset:-1102000.shot_title"/>
<item name="診療科コード" value="dataset:-1100000.course_cd2"/>
<item name="事業所コード" value="const:000"/>
<item name="入外区分" value="dataset:-1100006.in_out_class"/>
<item name="開始日" value="dataset:-1102031.col12"/>
<item name="終了日" value="dataset:-1102031.col13"/>
<item name="実施時刻" value="$BLANK"/>
<item name="中止フラグ" value="const:1"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="事後入力フラグ" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102031, "facilityCd": "facility_cd", "fileSubKind": "inj_index"}]}'::jsonb,'1','0','-1','2025-06-30T17:17:47.452',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000017','Secom','ind_dial','S','inj_header_cre','01','セコム連携_透析指示連携','注射依頼ファイル_注射ヘッダー_cre','1','<root name="セコム連携_透析指示_注射依頼ファイル_注射ヘッダー">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1102000.user_id"/>
<item name="未使用" value="$BLANK"/>
<item name="注射種別コード" value="dataset:-1102000.shot_type"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="RP数" value="dataset:-1102000.rp_num_sum"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="処方コメント" value="$BLANK"/>
</root>','{"dataset": [{"key0": "-1102022.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102022.ctl_no", "ordNo": "-1102022.ord_no", "patId": "-1102022.pat_id", "sqlCode": -1100000, "facilityCd": "-1102022.facility_cd"}, {"key0": "-1102022.key0", "ctlNo": "-1102022.ctl_no", "ordNo": "-1102022.ord_no", "patId": "-1102022.pat_id", "sqlCode": -1102000, "facilityCd": "-1102022.facility_cd"}, {"key0": "-1102022.key0", "patId": "-1102022.pat_id", "sqlCode": -1100006, "facilityCd": "-1102022.facility_cd"}]}'::jsonb,'1','0','-1','2025-07-08T15:03:27.649',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000018','Secom','ind_dial','S','med_top_cre','01','セコム連携_透析指示連携','セコム連携_透析指示連携_カルテ記録_cre','1','<root name="セコム連携_透析指示_カルテ" >
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1102000.user_id"/>
<item name="INDEX区分" value="const:5"/>
<item name="XX区分" value="dataset:-1100000.xx_type_code"/>
<item name="タイトル" value="$BLANK"/>
<item name="診療科コード" value="dataset:-1100000.course_cd1"/>
<item name="事業所コード" value="const:000"/>
<item name="入外区分" value="dataset:-1100006.in_out_class"/>
<item name="実施日" value="dataset:-1102000.treat_date"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="中止フラグ" value="const:0"/>
<item name="中止日" value="$BLANK"/>
<item name="中止時刻" value="$BLANK"/>
<item name="中止ユーザ" value="$BLANK"/>
<item name="事後入力フラグ" value="const:0"/>
<item name="カルテ記録テキスト" value="dataset:-1102000.medical_record_text"/>
</root>
','{"dataset": [{"key0": "-1100010.key0", "ctlNo": "-1100010.ctl_no", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "-1100010.facility_cd", "sharedSysdate": "$SHARED_SYSDATE:yyyyMMddHHmmss"}, {"key0": "-1100010.key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "-1100010.facility_cd"}, {"key0": "-1100010.key0", "ctlNo": "-1100010.ctl_no", "ordNo": "-1100010.ord_no", "patId": "-1100010.pat_id", "sqlCode": -1102000, "facilityCd": "-1100010.facility_cd"}]}'::jsonb,'1','0','-1','2025-06-24T14:35:49.849',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000019','Secom','ind_dial','S','med_top_del','01','セコム連携_透析指示連携','セコム連携_透析指示連携_カルテ記録_del','1','<root name="セコム連携_透析指示_カルテ">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1102031.col3"/>
<item name="SEQ番号" value="dataset:-1102031.col4"/>
<item name="ユーザID" value="dataset:-1102031.col5"/>
<item name="INDEX区分" value="const:5"/>
<item name="XX区分" value="dataset:-1100000.xx_type_code"/>
<item name="タイトル" value="$BLANK"/>
<item name="診療科コード" value="dataset:-1100000.course_cd1"/>
<item name="事業所コード" value="const:000"/>
<item name="入外区分" value="dataset:-1100006.in_out_class"/>
<item name="実施日" value="dataset:-1102031.col12"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="中止フラグ" value="const:1"/>
<item name="中止日" value="$BLANK"/>
<item name="中止時刻" value="$BLANK"/>
<item name="中止ユーザ" value="$BLANK"/>
<item name="事後入力フラグ" value="const:0"/>
<item name="カルテ記録テキスト" value="dataset:-1102031.col20"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facility_cd", "sharedSysdate": "$SHARED_SYSDATE:yyyyMMddHHmmss"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102031, "facilityCd": "facility_cd", "fileSubKind": "med"}]}'::jsonb,'1','0','-1','2025-06-24T14:35:49.849',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000020','Secom','ind_dial','S','inj_unit_cre','01','セコム連携_透析指示連携','注射依頼ファイル_実施単位1行_cre','1','<root name="セコム連携_透析指示_注射依頼ファイル_実施単位">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1102000.user_id"/>
<item name="RP番号" value="dataset:-1102010.rp_num"/>
<item name="処方開始日" value="dataset:-1102000.treat_date"/>
<item name="投与日数" value="const:1"/>
<item name="隔日" value="const:0"/>
<item name="処方終了日" value="dataset:-1102000.treat_date"/>
<item name="薬品数" value="dataset:-1102010.medi_count"/>
<item name="手技" value="dataset:-1102010.procedure_hosp_cd"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="一日回数" value="const:1"/>
<item name="タイミング1" value="$BLANK"/>
<item name="タイミング2" value="$BLANK"/>
<item name="タイミング3" value="$BLANK"/>
<item name="タイミング4" value="$BLANK"/>
<item name="タイミング5" value="$BLANK"/>
<item name="コメントコード" value="$BLANK"/>
<item name="フリーコメント" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
</root>','{"dataset": [{"key0": "-1102003.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102003.ctl_no", "ordNo": "-1102003.ord_no", "patId": "-1102003.pat_id", "sqlCode": -1100000, "facilityCd": "-1102003.facility_cd"}, {"key0": "-1102003.key0", "ctlNo": "-1102003.ctl_no", "ordNo": "-1102003.ord_no", "patId": "-1102003.pat_id", "sqlCode": -1102000, "facilityCd": "-1102003.facility_cd"}, {"key0": "-1102003.key0", "ctlNo": "-1102003.ctl_no", "ordNo": "-1102003.ord_no", "sortKey": "-1102003.sort_key", "sqlCode": -1102010, "facilityCd": "-1102003.facility_cd"}, {"key0": "-1102003.key0", "patId": "-1102003.pat_id", "sqlCode": -1100006, "facilityCd": "-1102003.facility_cd"}]}'::jsonb,'1','0','-1','2025-07-08T15:03:31.494',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000021','Secom','ind_dial','S','inj_item_cre','01','セコム連携_透析指示連携','注射依頼ファイル_処置項目1行_cre','1','<root name="セコム連携_透析指示_注射依頼ファイル_処置項目">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1102000.user_id"/>
<item name="RP番号(処置番号)" value="dataset:-1102012.rp_num"/>
<item name="薬品番号" value="dataset:-1102012.medi_num"/>
<item name="薬品コード" value="dataset:-1102012.medi_cd"/>
<item name="用量" value="dataset:-1102012.medi_amount"/>
<item name="未使用" value="$BLANK"/>
<item name="単位コード" value="dataset:-1102012.unit_convert"/>
<item name="未使用" value="$BLANK"/>
</root>','{"dataset": [{"key0": "-1102011.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102011.ctl_no", "ordNo": "-1102011.ord_no", "patId": "-1102011.pat_id", "sqlCode": -1100000, "facilityCd": "-1102011.facility_cd"}, {"key0": "-1102011.key0", "ctlNo": "-1102011.ctl_no", "ordNo": "-1102011.ord_no", "patId": "-1102011.pat_id", "sqlCode": -1102000, "facilityCd": "-1102011.facility_cd"}, {"key0": "-1102011.key0", "ctlNo": "-1102011.ctl_no", "ordNo": "-1102011.ord_no", "sortKey": "-1102011.sort_key", "sqlCode": -1102012, "facilityCd": "-1102011.facility_cd"}, {"key0": "-1102011.key0", "patId": "-1102011.pat_id", "sqlCode": -1100006, "facilityCd": "-1102011.facility_cd"}]}'::jsonb,'1','0','-1','2025-07-08T15:03:27.649',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000022','Secom','ind_dial','S','inj_finish','01','セコム連携_透析指示連携','注射依頼ファイル_ファイル作成終了','1','<root name="ファイル作成終了">
</root>','{}'::jsonb,'1','0','-1','2025-07-08T15:03:27.649',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000023','Secom','ind_dial','S','inj_header_del','01','セコム連携_透析指示連携','注射依頼ファイル_注射ヘッダー_del','1','<root name="セコム連携_透析指示_注射依頼ファイル_注射ヘッダー">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1102031.col3"/>
<item name="SEQ番号" value="dataset:-1102031.col4"/>
<item name="ユーザID" value="dataset:-1102031.col5"/>
<item name="未使用" value="$BLANK"/>
<item name="注射種別コード" value="dataset:-1102000.shot_type"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="RP数" value="dataset:-1102000.rp_num_sum"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="処方コメント" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102031, "facilityCd": "facility_cd", "fileSubKind": "inj_header"}]}'::jsonb,'1','0','-1','2025-06-30T17:17:47.452',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000024','Secom','ind_dial','S','inj_unit_top_del','01','セコム連携_透析指示連携','注射依頼ファイル_実施単位_del','1','<root name="セコム連携_透析指示_注射依頼ファイル_実施単位">
<record name="セコム連携_透析指示_注射依頼ファイル_実施単位" detail="inj_unit_del" sqlCode="-1102030"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102030, "facilityCd": "facility_cd", "fileSubKind": "inj_unit"}]}'::jsonb,'1','0','5843','2025-07-25T11:43:52.058',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000025','Secom','ind_dial','S','inj_unit_del','01','セコム連携_透析指示連携','注射依頼ファイル_実施単位1行_del','1','<root name="セコム連携_透析指示_注射依頼ファイル_実施単位">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1100014.e01"/>
<item name="SEQ番号" value="dataset:-1100014.e02"/>
<item name="ユーザID" value="dataset:-1100014.e03"/>
<item name="RP番号" value="dataset:-1100014.e04"/>
<item name="処方開始日" value="dataset:-1100014.e07"/>
<item name="投与日数" value="const:1"/>
<item name="隔日" value="const:0"/>
<item name="処方終了日" value="dataset:-1100014.e10"/>
<item name="薬品数" value="dataset:-1100014.e05"/>
<item name="手技" value="dataset:-1100014.e06"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="一日回数" value="const:1"/>
<item name="タイミング1" value="$BLANK"/>
<item name="タイミング2" value="$BLANK"/>
<item name="タイミング3" value="$BLANK"/>
<item name="タイミング4" value="$BLANK"/>
<item name="タイミング5" value="$BLANK"/>
<item name="コメントコード" value="$BLANK"/>
<item name="フリーコメント" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"e01": "-1102030.col3", "e02": "-1102030.col4", "e03": "-1102030.col5", "e04": "-1102030.col6", "e05": "-1102030.col11", "e06": "-1102030.col12", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}]}'::jsonb,'1','0','5843','2025-07-24T22:27:41.256',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000026','Secom','ind_dial','S','inj_item_top_del','01','セコム連携_透析指示連携','注射依頼ファイル_処置項目_del','1','<root name="セコム連携_透析指示_注射依頼ファイル_処置項目">
<record name="セコム連携_透析指示_注射依頼ファイル_処置項目" detail="inj_item_del" sqlCode="-1102030"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102030, "facilityCd": "facility_cd", "fileSubKind": "inj_item"}]}'::jsonb,'1','0','5843','2025-07-25T11:43:52.058',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000027','Secom','ind_dial','S','inj_item_del','01','セコム連携_透析指示連携','注射依頼ファイル_処置項目1行_del','1','<root name="セコム連携_透析指示_注射依頼ファイル_処置項目">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1100014.e01"/>
<item name="SEQ番号" value="dataset:-1100014.e02"/>
<item name="ユーザID" value="dataset:-1100014.e03"/>
<item name="RP番号(処置番号)" value="dataset:-1100014.e04"/>
<item name="薬品番号" value="dataset:-1100014.e05"/>
<item name="薬品コード" value="dataset:-1100014.e06"/>
<item name="用量" value="dataset:-1100014.e07"/>
<item name="未使用" value="$BLANK"/>
<item name="単位コード" value="dataset:-1100014.e08"/>
<item name="未使用" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"e01": "-1102030.col3", "e02": "-1102030.col4", "e03": "-1102030.col5", "e04": "-1102030.col6", "e05": "-1102030.col7", "e06": "-1102030.col8", "e07": "-1102030.col9", "e08": "-1102030.col11", "e09": "''''", "e10": "''''", "sqlCode": -1100014}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}]}'::jsonb,'1','0','5843','2025-07-24T22:27:41.256',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000028','Secom','ind_dial','S','trt_unit_top_del','01','セコム連携_透析指示連携','処置依頼ファイル_処置単位','1','<root name="セコム連携_透析指示_処置依頼ファイル_実施単位">
<record detail="trt_unit_del" sqlCode="-1102030"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102030, "facilityCd": "facility_cd", "fileSubKind": "trt_unit"}]}'::jsonb,'1','0','5843','2025-07-25T11:43:52.058',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000029','Secom','ind_dial','S','trt_item_top_del','01','セコム連携_透析指示連携','処置依頼ファイル_処置項目','1','<root name="セコム連携_透析指示_処置依頼ファイル_実施項目">
<record detail="trt_item_del" sqlCode="-1102030"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102030, "facilityCd": "facility_cd", "fileSubKind": "trt_item"}]}'::jsonb,'1','0','5843','2025-07-25T11:43:52.058',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000030','Secom','ind_dial','S','trt_index_del','01','セコム連携_透析指示連携','処置依頼ファイル_オーダーインデックス','1','<root name="セコム連携_透析指示_処置依頼ファイル_オーダーインデックス">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1102031.col3"/>
<item name="SEQ番号" value="dataset:-1102031.col4"/>
<item name="ユーザID" value="dataset:-1102031.col5"/>
<item name="INDEX区分" value="const:2"/>
<item name="XX区分" value="const:61"/>
<item name="タイトル" value="dataset:-1102000.treat_title"/>
<item name="診療科コード" value="dataset:-1100000.course_cd2"/>
<item name="事業所コード" value="const:000"/>
<item name="入外区分" value="dataset:-1100006.in_out_class"/>
<item name="開始日" value="dataset:-1102031.col12"/>
<item name="終了日" value="dataset:-1102031.col13"/>
<item name="実施時刻" value="$BLANK"/>
<item name="中止フラグ" value="const:1"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="事後入力フラグ" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102031, "facilityCd": "facility_cd", "fileSubKind": "trt_index"}]}'::jsonb,'1','0','-1','2025-06-30T16:08:51.714',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000031','Secom','ind_dial','S','trt_header_del','01','セコム連携_透析指示連携','処置依頼ファイル_処置ヘッダー','1','<root name="処置ヘッダー">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1102031.col3"/>
<item name="SEQ番号" value="dataset:-1102031.col4"/>
<item name="ユーザID" value="dataset:-1102031.col5"/>
<item name="指示区分" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="依頼発生日" value="$BLANK"/>
<item name="依頼SEQ番号" value="$BLANK"/>
<item name="依頼ユーザID" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102031, "facilityCd": "facility_cd", "fileSubKind": "trt_header"}]}'::jsonb,'1','0','-1','2025-06-30T16:08:51.714',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000032','Secom','ind_dial','S','trt_unit_del','01','セコム連携_透析指示連携','処置依頼ファイル_処置単位','1','<root name="処置単位">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1100014.e01"/>
<item name="SEQ番号" value="dataset:-1100014.e02"/>
<item name="ユーザID" value="dataset:-1100014.e03"/>
<item name="指示区分" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="RP番号(処置番号)" value="dataset:-1100014.e04"/>
<item name="処置タイミング" value="const:0"/>
<item name="処置開始日" value="dataset:-1100014.e010"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="処置終了日" value="dataset:-1100014.e013"/>
<item name="フリーコメント1" value="$BLANK"/>
<item name="フリーコメント2" value="$BLANK"/>
<item name="フリーコメント3" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="診療区分コード" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1102030.col3", "e02": "-1102030.col4", "e03": "-1102030.col5", "e04": "-1102030.col8", "e05": "''''", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb,'1','0','5843','2025-07-24T22:27:41.256',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1104000033','Secom','ind_dial','S','trt_item_del','01','セコム連携_透析指示連携','処置依頼ファイル_処置項目','1','<root name="処置項目">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1100014.e01"/>
<item name="SEQ番号" value="dataset:-1100014.e02"/>
<item name="ユーザID" value="dataset:-1100014.e03"/>
<item name="指示区分" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="RP番号(処置番号)" value="dataset:-1100014.e04"/>
<item name="処置項目番号" value="dataset:-1100014.e05"/>
<item name="処置項目コード" value="dataset:-1100014.e06"/>
<item name="未使用" value="$BLANK"/>
<item name="処置数量" value="dataset:-1100014.e07"/>
<item name="単位コード" value="dataset:-1100014.e08"/>
<item name="未使用" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1102030.col3", "e02": "-1102030.col4", "e03": "-1102030.col5", "e04": "-1102030.col8", "e05": "-1102030.col9", "e06": "-1102030.col10", "e07": "-1102030.col12", "e08": "-1102030.col13", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb,'1','0','5843','2025-07-24T22:27:41.256',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-11040004','Secom','ind_dial','S','処置依頼','処置依頼','(未完了）セコム連携_透析指示連携_処置依頼ファイル','（未完了）透析指示連携_処置依頼ファイル','1','<root name="処置依頼">
<!-- memo:SQLの参照先確認 -->
<file name="オーダーインデックス" detail="オーダーインデックス" sqlCode="105" />
<file name="処置ヘッダー" detail="処置ヘッダー" sqlCode="105" />
<file name="処置単位" detail="処置単位" sqlCode="105" />
<file name="処置項目" detail="処置項目" sqlCode="105" />
<file name="ファイル作成終了" detail="ファイル作成終了" sqlCode="106" />
</root>
<root name="処置ヘッダー">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1100000.occur_date"/>
<item name="SEQ番号" value="dataset:-1100000.occur_time"/>
<item name="ユーザID" value="dataset:-1102000.user_id"/>
<item name="指示区分" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="依頼発生日" value="$BLANK"/>
<item name="依頼SEQ番号" value="$BLANK"/>
<item name="依頼ユーザID" value="$BLANK"/>
</root>
<!-- memo:RP番号(処置番号)について、取得元確認 -->
<root name="処置単位">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1100000.occur_date"/>
<item name="SEQ番号" value="dataset:-1100000.occur_time"/>
<item name="ユーザID" value="dataset:-1102000.user_id"/>
<item name="指示区分" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="RP番号(処置番号)" value="dataset:-1102002.rp_no"/>
<item name="処置タイミング" value="const:0"/>
<item name="処置開始日" value="dataset:-1102000.rst_start_date"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="処置終了日" value="dataset:-1102000.rst_start_date"/>
<item name="フリーコメント1" value="$BLANK"/>
<item name="フリーコメント2" value="$BLANK"/>
<item name="フリーコメント3" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="診療区分コード" value="$BLANK"/>
</root>
<root name="処置項目">
</root>','{}'::jsonb,'1','0','-1','2025-07-08T15:03:25.457',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000000','Secom','rst_dial','S','med_top_del','01','セコム連携_透析実績連携','セコム連携_透析実績連携_カルテ記録_del','1','<root name="セコム連携_透析実績_カルテ">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1103020.col3"/>
<item name="SEQ番号" value="dataset:-1103020.col4"/>
<item name="ユーザID" value="dataset:-1103020.col5"/>
<item name="INDEX区分" value="const:5"/>
<item name="XX区分" value="dataset:-1100000.xx_type_code"/>
<item name="タイトル" value="$BLANK"/>
<item name="診療科コード" value="dataset:-1100000.course_cd1"/>
<item name="事業所コード" value="const:000"/>
<item name="入外区分" value="dataset:-1100006.in_out_class"/>
<item name="実施日" value="dataset:-1103020.col12"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="中止フラグ" value="const:1"/>
<item name="中止日" value="$BLANK"/>
<item name="中止時刻" value="$BLANK"/>
<item name="中止ユーザ" value="$BLANK"/>
<item name="事後入力フラグ" value="const:0"/>
<item name="カルテ記録テキスト" value="dataset:-1103020.col20"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103020, "facilityCd": "facility_cd", "fileSubKind": "med"}]}'::jsonb,'1','0','5843','2025-07-16T14:08:48.541',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000001','Secom','rst_dial','S','med_top_cre','01','セコム連携_透析実績連携','セコム連携_透析実績連携_カルテ記録_cre','1','<root name="セコム連携_透析実績_カルテ">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1103000.user_id"/>
<item name="INDEX区分" value="const:5"/>
<item name="XX区分" value="dataset:-1100000.xx_type_code"/>
<item name="タイトル" value="$BLANK"/>
<item name="診療科コード" value="dataset:-1100000.course_cd1"/>
<item name="事業所コード" value="const:000"/>
<item name="入外区分" value="dataset:-1100006.in_out_class"/>
<item name="実施日" value="dataset:-1103000.treat_date"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="中止フラグ" value="const:0"/>
<item name="中止日" value="$BLANK"/>
<item name="中止時刻" value="$BLANK"/>
<item name="中止ユーザ" value="$BLANK"/>
<item name="事後入力フラグ" value="const:0"/>
<item name="カルテ記録テキスト" value="dataset:-1103000.medical_record_text"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103000, "facilityCd": "facility_cd"}]}'::jsonb,'1','0','5843','2025-07-16T14:08:48.541',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000002','Secom','rst_dial','S','trt_top_del','01','セコム連携_透析実績連携','セコム連携_透析実績_処置実績','1','<root name="処置実績" useSharedSysdate="true">
<file name="オーダーインデックス" detail="trt_index_del" sqlCode="-1103005"/>
<file name="処置ヘッダー" detail="trt_header_del" sqlCode="-1103006"/>
<file name="処置単位" detail="trt_unit_top_del" sqlCode="-1103007"/>
<file name="処置項目" detail="trt_item_top_del" sqlCode="-1103008"/>
<file name="ファイル作成終了" detail="trt_finish" sqlCode="-1103009"/>
</root>
','{"dataset": [{"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "TREAT_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103005, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "TREAT_HEAD_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103006, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "TREAT_RP_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103007, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "TREAT_ITEM_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103008, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103009, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb,'1','0','-1','2025-07-17T12:22:00.639',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000003','Secom','rst_dial','S','trt_top_cre','01','セコム連携_透析実績連携','セコム連携_透析実績_処置実績','1','<root name="処置実績" useSharedSysdate="true">
<file name="オーダーインデックス" detail="trt_index_cre" sqlCode="-1103005"/>
<file name="処置ヘッダー" detail="trt_header_cre" sqlCode="-1103006"/>
<file name="処置単位" detail="trt_unit_top_cre" sqlCode="-1103007"/>
<file name="処置項目" detail="trt_item_top_cre" sqlCode="-1103008"/>
<file name="ファイル作成終了" detail="trt_finish" sqlCode="-1103009"/>
</root>
','{"dataset": [{"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "TREAT_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103005, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "TREAT_HEAD_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103006, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "TREAT_RP_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103007, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "TREAT_ITEM_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103008, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103009, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb,'1','0','-1','2025-07-17T12:27:33.708',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000004','Secom','rst_dial','S','trt_index_del','01','セコム連携_透析実績連携','処置実績ファイル_オーダーインデックス','1','<root name="セコム連携_透析実績_処置実績ファイル_オーダーインデックス">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1103020.col3"/>
<item name="SEQ番号" value="dataset:-1103020.col4"/>
<item name="ユーザID" value="dataset:-1103020.col5"/>
<item name="INDEX区分" value="const:2"/>
<item name="XX区分" value="const:61"/>
<item name="タイトル" value="dataset:-1103020.col8"/>
<item name="診療科コード" value="dataset:-1100000.course_cd2"/>
<item name="事業所コード" value="const:000"/>
<item name="入外区分" value="dataset:-1100006.in_out_class"/>
<item name="開始日" value="dataset:-1103020.col12"/>
<item name="終了日" value="dataset:-1103020.col13"/>
<item name="未使用" value="$BLANK"/>
<item name="中止フラグ" value="const:1"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="中止ユーザID" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="事後入力フラグ" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103020, "facilityCd": "facility_cd", "fileSubKind": "trt_index"}]}'::jsonb,'1','0','-1','2025-07-17T12:22:00.639',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000005','Secom','rst_dial','S','trt_index_cre','01','セコム連携_透析実績連携','処置実績ファイル_オーダーインデックス','1','<root name="セコム連携_透析実績_処置実績ファイル_オーダーインデックス">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1103000.user_id"/>
<item name="INDEX区分" value="const:2"/>
<item name="XX区分" value="const:61"/>
<item name="タイトル" value="dataset:-1103000.treat_title"/>
<item name="診療科コード" value="dataset:-1100000.course_cd2"/>
<item name="事業所コード" value="const:000"/>
<item name="入外区分" value="dataset:-1100006.in_out_class"/>
<item name="開始日" value="dataset:-1103000.treat_date"/>
<item name="終了日" value="dataset:-1103000.treat_date"/>
<item name="未使用" value="$BLANK"/>
<item name="中止フラグ" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="中止ユーザID" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="事後入力フラグ" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}]}'::jsonb,'1','0','-1','2025-07-17T12:27:33.708',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000006','Secom','rst_dial','S','trt_header_cre','01','セコム連携_透析実績連携','処置実績ファイル_処置ヘッダー','1','<root name="処置ヘッダー">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1103000.user_id"/>
<item name="指示区分" value="const:1"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="依頼発生日" value="dataset:-1103000.treatment_req_date"/>
<item name="依頼SEQ番号" value="dataset:-1103000.treatment_req_seq_no"/>
<item name="依頼ユーザID" value="dataset:-1103000.treatment_req_user_id"/>
</root>
','{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}]}'::jsonb,'1','0','-1','2025-07-17T12:27:33.708',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000007','Secom','rst_dial','S','trt_unit_top_del','01','セコム連携_透析実績連携','処置実績ファイル_処置単位','1','<root name="セコム連携_透析実績_処置実績ファイル_処置単位">
<record detail="trt_unit_del" sqlCode="-1103019"/>
</root>
','{"dataset": [{"ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103019, "facilityCd": "facility_cd", "fileSubKind": "trt_unit"}]}'::jsonb,'1','0','-1','2025-07-17T12:22:00.639',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000008','Secom','rst_dial','S','trt_unit_top_cre','01','セコム連携_透析実績連携','処置実績ファイル_処置単位','1','<root name="セコム連携_透析実績_処置実績ファイル_処置単位">
<record detail="trt_unit_cre" sqlCode="-1103003"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103003, "facilityCd": "facility_cd"}]}'::jsonb,'1','0','-1','2025-07-17T12:27:33.708',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000009','Secom','rst_dial','S','trt_unit_del','01','セコム連携_透析実績連携','処置実績ファイル_処置単位','1','<root name="処置単位">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1100014.e01"/>
<item name="SEQ番号" value="dataset:-1100014.e02"/>
<item name="ユーザID" value="dataset:-1100014.e03"/>
<item name="指示区分" value="const:1"/>
<item name="未使用" value="$BLANK"/>
<item name="RP番号(処置番号)" value="dataset:-1100014.e04"/>
<item name="処置タイミング" value="const:0"/>
<item name="処置開始日" value="dataset:-1100014.e05"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="処置終了日" value="dataset:-1100014.e06"/>
<item name="フリーコメント1" value="$BLANK"/>
<item name="フリーコメント2" value="$BLANK"/>
<item name="フリーコメント3" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="診療区分コード" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1103019.col3", "e02": "-1103019.col4", "e03": "-1103019.col5", "e04": "-1103019.col8", "e05": "-1103019.col10", "e06": "-1103019.col13", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb,'1','0','-1','2025-07-17T12:22:00.639',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000010','Secom','rst_dial','S','trt_unit_cre','01','セコム連携_透析実績連携','処置実績ファイル_処置単位','1','<root name="処置単位">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1103000.user_id"/>
<item name="指示区分" value="const:1"/>
<item name="未使用" value="$BLANK"/>
<item name="RP番号(処置番号)" value="dataset:-1100014.e01"/>
<item name="処置タイミング" value="const:0"/>
<item name="処置開始日" value="dataset:-1103000.rst_start_date"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="処置終了日" value="dataset:-1103000.rst_start_date"/>
<item name="フリーコメント1" value="$BLANK"/>
<item name="フリーコメント2" value="$BLANK"/>
<item name="フリーコメント3" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="診療区分コード" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1103003.rp_no", "e02": "''''", "e03": "''''", "e04": "''''", "e05": "''''", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb,'1','0','-1','2025-07-30T18:33:19.963',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000011','Secom','rst_dial','S','trt_item_top_del','01','セコム連携_透析実績連携','処置実績ファイル_処置項目','1','<root name="セコム連携_透析実績_処置実績ファイル_実施項目">
<record detail="trt_item_del" sqlCode="-1103019"/>
</root>
','{"dataset": [{"ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103019, "facilityCd": "facility_cd", "fileSubKind": "trt_item"}]}'::jsonb,'1','0','-1','2025-07-17T12:22:00.639',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000012','Secom','rst_dial','S','trt_item_top_cre','01','セコム連携_透析実績連携','処置実績ファイル_処置項目','1','<root name="セコム連携_透析実績_処置実績ファイル_実施項目">
<record detail="trt_item_cre" sqlCode="-1103001"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103001, "facilityCd": "facility_cd"}]}'::jsonb,'1','0','-1','2025-07-17T12:27:33.708',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000013','Secom','rst_dial','S','trt_item_del','01','セコム連携_透析実績連携','処置実績ファイル_処置項目','1','<root name="処置実績ファイル_処置項目">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1100014.e01"/>
<item name="SEQ番号" value="dataset:-1100014.e02"/>
<item name="ユーザID" value="dataset:-1100014.e03"/>
<item name="指示区分" value="const:1"/>
<item name="未使用" value="$BLANK"/>
<item name="RP番号(処置番号)" value="dataset:-1100014.e04"/>
<item name="処置項目番号" value="dataset:-1100014.e05"/>
<item name="処置項目コード" value="dataset:-1100014.e06"/>
<item name="未使用" value="$BLANK"/>
<item name="処置数量" value="dataset:-1100014.e07"/>
<item name="単位コード" value="dataset:-1100014.e08"/>
<item name="未使用" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1103019.col3", "e02": "-1103019.col4", "e03": "-1103019.col5", "e04": "-1103019.col8", "e05": "-1103019.col9", "e06": "-1103019.col10", "e07": "-1103019.col12", "e08": "-1103019.col13", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb,'1','0','-1','2025-07-17T12:22:00.639',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000014','Secom','rst_dial','S','trt_item_cre','01','セコム連携_透析実績連携','処置実績ファイル_処置項目','1','<root name="処置項目">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1103000.user_id"/>
<item name="指示区分" value="const:1"/>
<item name="未使用" value="$BLANK"/>
<item name="RP番号(処置番号)" value="dataset:-1100014.e01"/>
<item name="処置項目番号" value="dataset:-1100014.e02"/>
<item name="処置項目コード" value="dataset:-1100014.e03"/>
<item name="未使用" value="$BLANK"/>
<item name="処置数量" value="dataset:-1100014.e04"/>
<item name="単位コード" value="dataset:-1100014.e05"/>
<item name="未使用" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1103001.rp_no", "e02": "-1103001.item_no", "e03": "-1103001.hosp_cd", "e04": "-1103001.amount", "e05": "-1103001.unit", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb,'1','0','-1','2025-07-17T12:27:33.708',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000015','Secom','rst_dial','S','trt_finish','01','セコム連携_透析実績連携','処置実績ファイル_ファイル作成終了','1','<root name="ファイル作成終了">
</root>','{}'::jsonb,'1','0','-1','2025-07-17T12:27:33.708',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000016','Secom','rst_dial','S','trt_header_del','01','セコム連携_透析実績連携','処置実績ファイル_処置ヘッダー','1','<root name="処置実績ファイル_処置ヘッダー">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1103020.col3"/>
<item name="SEQ番号" value="dataset:-1103020.col4"/>
<item name="ユーザID" value="dataset:-1103020.col5"/>
<item name="指示区分" value="const:1"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="依頼発生日" value="dataset:-1103020.col12"/>
<item name="依頼SEQ番号" value="dataset:-1103020.col13"/>
<item name="依頼ユーザID" value="dataset:-1103020.col14"/>
</root>
','{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103020, "facilityCd": "facility_cd", "fileSubKind": "trt_header"}]}'::jsonb,'1','0','-1','2025-07-17T12:22:00.639',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000017','Secom','rst_dial','S','inj_top_cre','01','セコム連携_透析実績連携','セコム連携_透析実績_注射実績_cre','1','<root name="透析実績_注射実績" useSharedSysdate="true" updateSharedSysdate="true">
<file name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス" detail="inj_index_cre" sqlCode="-1103010"/>
<file name="セコム連携_透析実績_注射実績ファイル_処置項目" detail="inj_item_top_cre" sqlCode="-1103011"/>
<file name="セコム連携_透析実績_注射実績ファイル_ファイル作成終了" detail="inj_finish" sqlCode="-1103012"/>
</root>
','{"dataset": [{"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_IDX_FILE_STR", "rpNo": "-1103004.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103010, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_ITEM_FILE_STR", "rpNo": "-1103004.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103011, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103012, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb,'1','0','-1','2025-07-30T10:00:10.996',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000018','Secom','rst_dial','S','inj_top_del','01','セコム連携_透析実績連携','セコム連携_透析実績_注射実績_del','1','<root name="透析実績_注射実績" useSharedSysdate="true" updateSharedSysdate="true">
<file name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス" detail="inj_index_del" sqlCode="-1103010"/>
<file name="セコム連携_透析実績_注射実績ファイル_処置項目" detail="inj_item_top_del" sqlCode="-1103011"/>
<file name="セコム連携_透析実績_注射実績ファイル_ファイル作成終了" detail="inj_finish" sqlCode="-1103012"/>
</root>
','{"dataset": [{"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_IDX_FILE_STR", "rpNo": "-1103018.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103010, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_ITEM_FILE_STR", "rpNo": "-1103018.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103011, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103012, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb,'1','0','-1','2025-07-30T14:47:47.273',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000019','Secom','rst_dial','S','inj_index_cre','01','セコム連携_透析実績連携','注射実績ファイル_オーダーインデックス_cre','1','<root name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1103000.user_id"/>
<item name="指示コード" value="const:211"/>
<item name="指示サブコード1" value="const:0000000000"/>
<item name="指示サブコード2" value="const:0000000000"/>
<item name="RP番号" value="dataset:-1100014.e01"/>
<item name="実施日付" value="dataset:-1103000.rst_start_date"/>
<item name="実施時刻" value="dataset:-1103000.rst_start_time"/>
<item name="実施終了日" value="$BLANK"/>
<item name="実施終了時刻" value="$BLANK"/>
<item name="実施内容" value="$BLANK"/>
<item name="実施値１" value="$BLANK"/>
<item name="実施値１" value="$BLANK"/>
<item name="IN TAKE" value="$BLANK"/>
<item name="OUTPUT" value="$BLANK"/>
<item name="依頼発生日" value="dataset:-1103000.injection_req_date"/>
<item name="依頼SEQ番号" value="dataset:-1103000.injection_req_seq_no"/>
<item name="依頼ユーザID" value="dataset:-1103000.injection_req_user_id"/>
<item name="中止フラグ" value="const:0"/>
<item name="取消フラグ" value="$BLANK"/>
<item name="背景色" value="$BLANK"/>
<item name="実施予定日" value="dataset:-1103000.treat_date"/>
<item name="実施予定時刻" value="dataset:-1103000.kur_standard_start_time"/>
<item name="実施フラグ" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1103010.rp_no", "e02": "''''", "e03": "''''", "e04": "''''", "e05": "''''", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb,'1','0','-1','2025-07-30T17:12:03.624',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000020','Secom','rst_dial','S','inj_index_del','01','セコム連携_透析実績連携','注射実績ファイル_オーダーインデックス_del','1','<root name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1103022.col3"/>
<item name="SEQ番号" value="dataset:-1103022.col4"/>
<item name="ユーザID" value="dataset:-1103022.col5"/>
<item name="指示コード" value="const:211"/>
<item name="指示サブコード1" value="const:0000000000"/>
<item name="指示サブコード2" value="const:0000000000"/>
<item name="RP番号" value="dataset:-1103022.col9"/>
<item name="実施日付" value="dataset:-1103022.col10"/>
<item name="実施時刻" value="dataset:-1103022.col11"/>
<item name="実施終了日" value="$BLANK"/>
<item name="実施終了時刻" value="$BLANK"/>
<item name="実施内容" value="$BLANK"/>
<item name="実施値１" value="$BLANK"/>
<item name="実施値１" value="$BLANK"/>
<item name="IN TAKE" value="$BLANK"/>
<item name="OUTPUT" value="$BLANK"/>
<item name="依頼発生日" value="dataset:-1103022.col19"/>
<item name="依頼SEQ番号" value="dataset:-1103022.col20"/>
<item name="依頼ユーザID" value="dataset:-1103022.col21"/>
<item name="中止フラグ" value="const:0"/>
<item name="取消フラグ" value="const:1"/>
<item name="背景色" value="$BLANK"/>
<item name="実施予定日" value="dataset:-1103022.col25"/>
<item name="実施予定時刻" value="dataset:-1103022.col26"/>
<item name="実施フラグ" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103022, "facilityCd": "facility_cd", "fileSubKind": "inj_index", "conditionValue": "-1103010.rp_no", "conditionTargetColNo": 8}]}'::jsonb,'1','0','-1','2025-07-30T14:47:47.273',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000021','Secom','rst_dial','S','inj_item_top_cre','01','セコム連携_透析実績連携','注射実績ファイル_処置項目_cre','1','<root name="セコム連携_透析実績_注射実績ファイル_処置項目">
<record name="セコム連携_透析実績_注射実績ファイル_処置項目" detail="inj_item_cre" sqlCode="-1103002"/>
</root>
','{"dataset": [{"key0": "key0", "rpNo": "-1103011.rp_no", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103002, "facilityCd": "facility_cd"}]}'::jsonb,'1','0','-1','2025-07-30T10:00:10.996',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000022','Secom','rst_dial','S','inj_item_top_del','01','セコム連携_透析実績連携','注射実績ファイル_処置項目_del','1','<root name="セコム連携_透析実績_注射実績ファイル_処置項目">
<record name="セコム連携_透析実績_注射実績ファイル_処置項目" detail="inj_item_del" sqlCode="-1103021"/>
</root>
','{"dataset": [{"ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103021, "facilityCd": "facility_cd", "fileSubKind": "inj_item", "conditionValue": "-1103011.rp_no", "conditionTargetColNo": 8}]}'::jsonb,'1','0','-1','2025-07-30T14:47:47.273',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000023','Secom','rst_dial','S','inj_item_cre','01','セコム連携_透析実績連携','注射実績ファイル_処置項目1行_cre','1','<root name="セコム連携_透析実績_注射実績ファイル_処置項目">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1103000.user_id"/>
<item name="指示コード" value="const:211"/>
<item name="指示サブコード1" value="const:0000000000"/>
<item name="指示サブコード2" value="const:0000000000"/>
<item name="RP番号" value="dataset:-1100014.e01"/>
<item name="薬品番号" value="dataset:-1100014.e02"/>
<item name="薬品コード" value="dataset:-1100014.e03"/>
<item name="薬品容量" value="dataset:-1100014.e04"/>
<item name="単位コード" value="dataset:-1100014.e05"/>
<item name="中止フラグ" value="const:0"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1103002.rp_no", "e02": "-1103002.medi_no", "e03": "-1103002.medi_cd", "e04": "-1103002.amount", "e05": "-1103002.unit", "e06": "-1103002.stop_flg", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb,'1','0','-1','2025-07-30T17:12:03.624',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000024','Secom','rst_dial','S','inj_item_del','01','セコム連携_透析実績連携','注射実績ファイル_処置項目1行_del','1','<root name="セコム連携_透析実績_注射実績ファイル_処置項目">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1100014.e01"/>
<item name="SEQ番号" value="dataset:-1100014.e02"/>
<item name="ユーザID" value="dataset:-1100014.e03"/>
<item name="指示コード" value="const:211"/>
<item name="指示サブコード1" value="const:0000000000"/>
<item name="指示サブコード2" value="const:0000000000"/>
<item name="RP番号" value="dataset:-1100014.e04"/>
<item name="薬品番号" value="dataset:-1100014.e05"/>
<item name="薬品コード" value="dataset:-1100014.e06"/>
<item name="薬品容量" value="dataset:-1100014.e07"/>
<item name="単位コード" value="dataset:-1100014.e08"/>
<item name="中止フラグ" value="const:1"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1103021.col3", "e02": "-1103021.col4", "e03": "-1103021.col5", "e04": "-1103021.col9", "e05": "-1103021.col10", "e06": "-1103021.col11", "e07": "-1103021.col12", "e08": "-1103021.col13", "e09": "-1103021.col14", "e10": "''''", "sqlCode": -1100014}]}'::jsonb,'1','0','-1','2025-07-30T14:47:47.273',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000025','Secom','rst_dial','S','inj_finish','01','セコム連携_透析実績連携','注射実績ファイル_ファイル作成終了','1','<root name="ファイル作成終了">
</root>','{}'::jsonb,'1','0','-1','2025-07-30T10:00:10.996',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000026','Secom','rst_dial','S','inj_cancel_top_del','01','セコム連携_透析実績連携','セコム連携_透析実績_注射中止_del','1','<root name="透析実績_注射実績" useSharedSysdate="true" updateSharedSysdate="true">
<file name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス" detail="inj_cancel_index_del" sqlCode="-1103010"/>
<file name="セコム連携_透析実績_注射実績ファイル_処置項目" detail="inj_item_top_del" sqlCode="-1103011"/>
<file name="セコム連携_透析実績_注射実績ファイル_ファイル作成終了" detail="inj_finish" sqlCode="-1103012"/>
</root>
','{"dataset": [{"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_IDX_FILE_STR", "rpNo": "-1103013.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103010, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_ITEM_FILE_STR", "rpNo": "-1103013.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103011, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103012, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb,'1','0','-1','2025-08-01T15:43:21.079',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1107000027','Secom','rst_dial','S','inj_cancel_index_del','01','セコム連携_透析実績連携','注射中止ファイル_オーダーインデックス_del','1','<root name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1103022.col3"/>
<item name="SEQ番号" value="dataset:-1103022.col4"/>
<item name="ユーザID" value="dataset:-1103022.col5"/>
<item name="指示コード" value="const:211"/>
<item name="指示サブコード1" value="const:0000000000"/>
<item name="指示サブコード2" value="const:0000000000"/>
<item name="RP番号" value="dataset:-1103022.col9"/>
<item name="実施日付" value="dataset:-1103022.col10"/>
<item name="実施時刻" value="dataset:-1103022.col11"/>
<item name="実施終了日" value="$BLANK"/>
<item name="実施終了時刻" value="$BLANK"/>
<item name="実施内容" value="$BLANK"/>
<item name="実施値１" value="$BLANK"/>
<item name="実施値１" value="$BLANK"/>
<item name="IN TAKE" value="$BLANK"/>
<item name="OUTPUT" value="$BLANK"/>
<item name="依頼発生日" value="dataset:-1103022.col19"/>
<item name="依頼SEQ番号" value="dataset:-1103022.col20"/>
<item name="依頼ユーザID" value="dataset:-1103022.col21"/>
<item name="中止フラグ" value="const:1"/>
<item name="取消フラグ" value="$BLANK"/>
<item name="背景色" value="$BLANK"/>
<item name="実施予定日" value="dataset:-1103022.col25"/>
<item name="実施予定時刻" value="dataset:-1103022.col26"/>
<item name="実施フラグ" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103022, "facilityCd": "facility_cd", "fileSubKind": "inj_index", "conditionValue": "-1103010.rp_no", "conditionTargetColNo": 8}]}'::jsonb,'1','0','-1','2025-08-01T15:43:21.079',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1110100001','Secom','exam_ord','S','exam_item_cre','01','セコム連携_検体検査オーダ連携_検体検査','セコム連携_検体検査オーダ連携_検体検査','1','<root name="検体検査">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1105000.user_id"/>
<item name="緊急区分" value="const:0"/>
<item name="感染症コード1" value="$BLANK"/>
<item name="感染症コード2" value="$BLANK"/>
<item name="感染症コード3" value="$BLANK"/>
<item name="感染症コード4" value="$BLANK"/>
<item name="感染症コード5" value="$BLANK"/>
<item name="コメントコード1" value="$BLANK"/>
<item name="コメントコード2" value="$BLANK"/>
<item name="コメントコード3" value="$BLANK"/>
<item name="フリーコメント1" value="$BLANK"/>
<item name="フリーコメント2" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="項目数" value="dataset:-1105000.exam_set_cnt"/>
<item name="検体項目" value="dataset:-1105001.item_in_hospital_cd"/>
<item name="汎用フラグ1" value="dataset:-1105000.exam_timing_flag"/>
<item name="汎用フラグ2" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="汎用データ1" value="$BLANK"/>
<item name="汎用データ2" value="$BLANK"/>
<item name="汎用データ3" value="$BLANK"/>
<item name="汎用データ4" value="$BLANK"/>
<item name="汎用データ5" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
</root>','{"dataset": [{"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105001, "facilityCd": "facilityCd"}]}'::jsonb,'1','0','-1','2025-07-17T10:39:35.59',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1110100002','Secom','exam_ord','S','exam_idx_cre','01','セコム連携_検体検査オーダ連携_オーダーインデックス','セコム連携_検体検査オーダ連携_オーダーインデックス','1','<root name="オーダーインデックス">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1105000.user_id"/>
<item name="INDEX区分" value="const:2"/>
<item name="XX区分" value="const:20"/>
<item name="タイトル" value="dataset:-1105000.title"/>
<item name="診療科コード" value="dataset:-1100000.course_cd2"/>
<item name="事業所コード" value="const:000"/>
<item name="入外区分" value="dataset:-1100006.in_out_class"/>
<item name="開始日" value="dataset:-1105000.reg_exam_date"/>
<item name="終了日" value="dataset:-1105000.reg_exam_date"/>
<item name="実施時刻" value="$BLANK"/>
<item name="中止フラグ" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="中止ユーザID" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="事後入力フラグ" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}]}'::jsonb,'1','0','-1','2025-07-11T13:16:22.014',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1110100003','Secom','exam_ord','S','exam_finish','01','セコム連携_検体検査オーダ連携_ファイル作成終了','セコム連携_検体検査オーダ連携_ファイル作成終了','1','<root name="ファイル作成終了">
</root>','{"dataset": []}'::jsonb,'1','0','-1','2025-07-09T19:13:12.944',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1110200001','Secom','exam_ord','S','exam_item_del','01','セコム連携_検体検査オーダ連携_検体検査_削除','セコム連携_検体検査オーダ連携_検体検査_削除','1','<root name="検体検査">
<item name="病院ID" value="dataset:-1105005.hospital_id"/>
<item name="患者ID" value="dataset:-1105005.hosp_pat_id"/>
<item name="発生日" value="dataset:-1105005.occur_date"/>
<item name="SEQ番号" value="dataset:-1105005.occur_time"/>
<item name="ユーザID" value="dataset:-1105005.user_id"/>
<item name="緊急区分" value="const:0"/>
<item name="感染症コード1" value="$BLANK"/>
<item name="感染症コード2" value="$BLANK"/>
<item name="感染症コード3" value="$BLANK"/>
<item name="感染症コード4" value="$BLANK"/>
<item name="感染症コード5" value="$BLANK"/>
<item name="コメントコード1" value="$BLANK"/>
<item name="コメントコード2" value="$BLANK"/>
<item name="コメントコード3" value="$BLANK"/>
<item name="フリーコメント1" value="$BLANK"/>
<item name="フリーコメント2" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="項目数" value="dataset:-1105005.exam_set_cnt"/>
<item name="検査項目" value="dataset:-1105005.item_in_hospital_cd"/>
<item name="汎用フラグ1" value="dataset:-1105005.exam_timing_flag"/>
<item name="汎用フラグ2" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="汎用データ1" value="$BLANK"/>
<item name="汎用データ2" value="$BLANK"/>
<item name="汎用データ3" value="$BLANK"/>
<item name="汎用データ4" value="$BLANK"/>
<item name="汎用データ5" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105005, "facilityCd": "facilityCd"}]}'::jsonb,'1','0','-1','2025-07-11T12:47:22.462',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1110200002','Secom','exam_ord','S','exam_idx_del','01','セコム連携_検体検査オーダ連携_オーダーインデックス_削除','セコム連携_検体検査オーダ連携_オーダーインデックス_削除','1','<root name="オーダーインデックス">
<item name="病院ID" value="dataset:-1105004.hospital_id"/>
<item name="患者ID" value="dataset:-1105004.hosp_pat_id"/>
<item name="発生日" value="dataset:-1105004.occur_date"/>
<item name="SEQ番号" value="dataset:-1105004.occur_time"/>
<item name="ユーザID" value="dataset:-1105004.user_id"/>
<item name="INDEX区分" value="const:2"/>
<item name="XX区分" value="const:20"/>
<item name="タイトル" value="dataset:-1105004.title"/>
<item name="診療科コード" value="dataset:-1105004.course_cd2"/>
<item name="事業所コード" value="const:000"/>
<item name="入外区分" value="dataset:-1105004.in_out_class"/>
<item name="開始日" value="dataset:-1105004.reg_exam_date"/>
<item name="終了日" value="dataset:-1105004.reg_exam_date"/>
<item name="実施時刻" value="$BLANK"/>
<item name="中止フラグ" value="const:1"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="中止ユーザID" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="事後入力フラグ" value="const:0"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105004, "facilityCd": "facilityCd"}]}'::jsonb,'1','0','-1','2025-07-11T12:47:22.462',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1111000001','Secom','rad_ord','S','idx_top_cre','01','セコム連携_放射線オーダ','セコム連携_放射線オーダ_オーダーインデックス_cre','1','<root name="放射線オーダ_オーダーインデックス">
<item name="病院ID" len="6" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" len="12" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" len="10" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" len="8" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" len="6" value="dataset:-1106000.user_id"/>
<item name="INDEX区分" len="1" value="const:2"/>
<item name="XX区分" len="2" value="const:30"/>
<item name="タイトル" len="60" value="dataset:-1106000.title"/>
<item name="診療科コード" len="3" value="dataset:-1100000.course_cd2"/>
<item name="事業所コード" len="3" value="const:000"/>
<item name="入外区分" len="1" value="dataset:-1100006.in_out_class"/>
<item name="開始日" len="10" value="dataset:-1106000.reg_rad_date"/>
<item name="終了日" len="10" value="dataset:-1106000.reg_rad_date"/>
<item name="実施時刻" len="8" value="$BLANK"/>
<item name="中止フラグ" len="1" value="const:0"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="中止ユーザID" len="6" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="事後入力フラグ" len="1" value="const:0"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106000, "facilityCd": "facilityCd"}]}'::jsonb,'1','0','-1','2025-06-24T10:35:38.507',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1111000002','Secom','rad_ord','S','head_top_cre','01','セコム連携_放射線オーダ','セコム連携_放射線オーダ_処方ヘッダー_cre','1','<root name="放射線オーダ_処方ヘッダー">
<item name="病院ID" len="6" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" len="12" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" len="10" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" len="8" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" len="6" value="dataset:-1106000.user_id"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="検査指示数" len="1" value="const:1"/>
<item name="コメントコード3" len="0" value="$BLANK"/>
<item name="フリーコメント" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="指示フラグ20" len="8" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="緊急区分" len="1" value="const:0"/>
<item name="その他" len="0" value="$BLANK"/>
<item name="移動方法" len="0" value="$BLANK"/>
<item name="妊娠情報" len="0" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106000, "facilityCd": "facilityCd"}]}'::jsonb,'1','0','-1','2025-06-24T10:35:38.507',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1111000003','Secom','rad_ord','S','ipn_top_cre','01','セコム連携_放射線オーダ','セコム連携_放射線オーダ_実施単位_cre','1','<root name="放射線オーダ_実施単位">
<item name="病院ID" len="6" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" len="12" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" len="10" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" len="8" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" len="6" value="dataset:-1106000.user_id"/>
<item name="指示順" len="1" value="const:1"/>
<item name="部位コード" len="4" value="dataset:-1106000.part_cd"/>
<item name="修飾コード5" len="15" value="dataset:-1106000.mod_cd"/>
<item name="方向コード5" len="15" value="dataset:-1106000.direction_cd"/>
<item name="手技コード5" len="15" value="dataset:-1106000.procedure_cd"/>
<item name="フリーコメント1" len="0" value="$BLANK"/>
<item name="フリーコメント2" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106000, "facilityCd": "facilityCd"}]}'::jsonb,'1','0','-1','2025-06-24T10:35:38.507',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1111000004','Secom','rad_ord','S','idx_top_del','01','セコム連携_放射線オーダ','セコム連携_放射線オーダ_オーダーインデックス_del','1','<root name="放射線オーダ_オーダーインデックス">
<item name="病院ID" len="6" value="dataset:-1106006.hospital_id"/>
<item name="患者ID" len="12" value="dataset:-1106006.hosp_pat_id"/>
<item name="発生日" len="10" value="dataset:-1106006.occur_date"/>
<item name="SEQ番号" len="8" value="dataset:-1106006.occur_time"/>
<item name="ユーザID" len="6" value="dataset:-1106006.user_id"/>
<item name="INDEX区分" len="1" value="const:2"/>
<item name="XX区分" len="2" value="const:30"/>
<item name="タイトル" len="60" value="dataset:-1106006.title"/>
<item name="診療科コード" len="3" value="dataset:-1106006.course_cd2"/>
<item name="事業所コード" len="3" value="const:000"/>
<item name="入外区分" len="1" value="dataset:-1106006.in_out_class"/>
<item name="開始日" len="10" value="dataset:-1106006.reg_rad_date"/>
<item name="終了日" len="10" value="dataset:-1106006.reg_rad_date"/>
<item name="実施時刻" len="8" value="$BLANK"/>
<item name="中止フラグ" len="1" value="const:1"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="中止ユーザID" len="6" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="事後入力フラグ" len="1" value="const:0"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106006, "facilityCd": "facilityCd"}]}'::jsonb,'1','0','-1','2025-06-24T10:35:38.507',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1111000005','Secom','rad_ord','S','head_top_del','01','セコム連携_放射線オーダ','セコム連携_放射線オーダ_処方ヘッダー_del','1','<root name="放射線オーダ_処方ヘッダー">
<item name="病院ID" len="6" value="dataset:-1106007.hospital_id"/>
<item name="患者ID" len="12" value="dataset:-1106007.hosp_pat_id"/>
<item name="発生日" len="10" value="dataset:-1106007.occur_date"/>
<item name="SEQ番号" len="8" value="dataset:-1106007.occur_time"/>
<item name="ユーザID" len="6" value="dataset:-1106007.user_id"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="検査指示数" len="1" value="const:1"/>
<item name="コメントコード3" len="0" value="$BLANK"/>
<item name="フリーコメント" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="指示フラグ20" len="8" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
<item name="緊急区分" len="1" value="const:0"/>
<item name="その他" len="0" value="$BLANK"/>
<item name="移動方法" len="0" value="$BLANK"/>
<item name="妊娠情報" len="0" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106007, "facilityCd": "facilityCd"}]}'::jsonb,'1','0','-1','2025-06-24T10:35:38.507',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1111000006','Secom','rad_ord','S','ipn_top_del','01','セコム連携_放射線オーダ','セコム連携_放射線オーダ_実施単位_del','1','<root name="放射線オーダ_実施単位">
<item name="病院ID" len="6" value="dataset:-1106008.hospital_id"/>
<item name="患者ID" len="12" value="dataset:-1106008.hosp_pat_id"/>
<item name="発生日" len="10" value="dataset:-1106008.occur_date"/>
<item name="SEQ番号" len="8" value="dataset:-1106008.occur_time"/>
<item name="ユーザID" len="6" value="dataset:-1106008.user_id"/>
<item name="指示順" len="1" value="const:1"/>
<item name="部位コード" len="4" value="dataset:-1106008.part_cd"/>
<item name="修飾コード5" len="15" value="dataset:-1106008.mod_cd"/>
<item name="方向コード5" len="15" value="dataset:-1106008.direction_cd"/>
<item name="手技コード5" len="15" value="dataset:-1106008.procedure_cd"/>
<item name="フリーコメント1" len="0" value="$BLANK"/>
<item name="フリーコメント2" len="0" value="$BLANK"/>
<item name="未使用" len="0" value="$BLANK"/>
</root>
','{"dataset": [{"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106008, "facilityCd": "facilityCd"}]}'::jsonb,'1','0','-1','2025-06-24T10:35:38.507',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1111000007','Secom','rad_ord','S','rad_finish','01','セコム連携_放射線オーダ','セコム連携_放射線オーダ_ファイル作成終了','1','<root name="放射線オーダ_ファイル作成終了">
</root>
','{}'::jsonb,'1','0','-1','2025-07-14T01:50:08.124',CURRENT_TIMESTAMP,'Secom');
INSERT INTO ntss.mst_coop_layout_detail(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES ('-1111000008','Secom','karte_ord','S','karte_ord_all','01','セコム連携_指示変更履歴','セコム連携_指示変更履歴','1','<root name="指示変更履歴_カルテ記録ファイル" useSharedSysdate="true">
<item name="病院ID" len="6" value="dataset:-1107000.hospital_id"/>
<item name="患者ID" value="dataset:-1107000.patient_id"/>
<item name="発生日" len="10" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" len="8" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" len="6" value="dataset:-1107007.disp_user_id"/>
<item name="INDEX区分" len="1" value="const:5"/>
<item name="XX区分" len="2" value="dataset:-1107000.xx_class"/>
<item name="タイトル" value="dataset:-1107000.title"/>
<item name="診療科コード" len="2" value="dataset:-1107000.dept_code"/>
<item name="事業所コード" len="3" value="const:000"/>
<item name="入外区分" len="1" value="dataset:-1107000.in_out_class"/>
<item name="実施日" len="10" value="dataset:-1107000.execution_date"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="中止フラグ" len="1" value="const:0"/>
<item name="中止日" value="$BLANK"/>
<item name="中止時刻" value="$BLANK"/>
<item name="中止ユーザ" value="$BLANK"/>
<item name="事後入力フラグ" len="1" value="const:0"/>
<item name="カルテ記録テキスト" value="dataset:-1107004.karte_text"/>
</root>
','{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1107000, "treatDate": "treatDate", "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "content": "nullValue", "sqlCode": -1107004, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1107007, "facilityCd": "facilityCd"}]}'::jsonb,'1','0','-1','2025-07-14T01:50:08.124',CURRENT_TIMESTAMP,'Secom');
