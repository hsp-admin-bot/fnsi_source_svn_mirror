DELETE FROM mst_coop_layout WHERE ctl_no IN 
(-11070001);
DELETE FROM mst_coop_layout_detail WHERE ctl_no IN 
(-1107000018);

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11070001, 'Secom', 'rst_dial', '', 'S', 'del', 'csv', 'セコム連携_透析実績連携', 'Secom', '透析実績連携（rootレイアウト）', '1', '<root name="透析実績電文" useSharedSysdate="true">
  <file name="処置実績" detail="trt_top_del" sqlCode="-1103017"/>
  <file name="注射実績" detail="inj_top_del" sqlCode="-1103018"/>
  <file name="カルテ記録" detail="med_top_del" sqlCode="-1100010"/>
  <file name="注射中止" detail="inj_cancel_top_del" sqlCode="-1103013"/>
</root>
', '
{
    "dataset": [
        {
            "ordNo": "ord_no",
            "patId": "pat_id",
            "coopCd": "rst_dial",
            "sqlCode": -1103017,
            "facilityCd": "facility_cd",
            "fileSubKind": "trt_item"
        },
        {
            "crud": "del",
            "key0": "key0",
            "ordNo": "ord_no",
            "patId": "pat_id",
            "coopCd": "rst_dial",
            "sqlCode": -1103018,
            "facilityCd": "facility_cd",
            "fileSubKind": "inj_index"
        },
        {
            "crud": "del",
            "key0": "key0",
            "key1": "SCM_DIALYSISSEND",
            "key2": "KARTE_FILE_STR",
            "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss",
            "ctlNo": "ctlNo",
            "ordNo": "ordNo",
            "patId": "patId",
            "coopCd": "rst_dial",
            "sqlCode": -1100010,
            "fileKind": "medical",
            "facilityCd": "facilityCd",
            "file_extension": "txt"
        },
        {
            "crud": "del",
            "key0": "key0",
            "ctlNo": "ctl_no",
            "ordNo": "ord_no",
            "patId": "pat_id",
            "coopCd": "rst_dial",
            "sqlCode": -1103013,
            "facilityCd": "facility_cd",
            "fileSubKind": "inj_index"
        }
    ]
}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000018, 'Secom', 'rst_dial', 'S', 'inj_top_del', '01', 'セコム連携_透析実績連携', 'セコム連携_透析実績_注射実績_del', '1', '<root name="透析実績_注射実績" useSharedSysdate="true" updateSharedSysdate="true">
<file name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス" detail="inj_index_del" sqlCode="-1103010"/>
<file name="セコム連携_透析実績_注射実績ファイル_処置項目" detail="inj_item_top_del" sqlCode="-1103011"/>
<file name="セコム連携_透析実績_注射実績ファイル_ファイル作成終了" detail="inj_finish" sqlCode="-1103012"/>
</root>
', '
{
    "dataset": [
        {
            "crud": "del",
            "key0": "key0",
            "key1": "SCM_DIALYSISSEND",
            "key2": "INJECT_IDX_FILE_STR",
            "rpNo": "-1103018.rp_no",
            "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss",
            "ctlNo": "ctlNo",
            "ordNo": "ordNo",
            "patId": "patId",
            "coopCd": "rst_dial",
            "sqlCode": -1103010,
            "fileKind": "injection",
            "facilityCd": "facilityCd",
            "file_extension": "txt"
        },
        {
            "crud": "del",
            "key0": "key0",
            "key1": "SCM_DIALYSISSEND",
            "key2": "INJECT_ITEM_FILE_STR",
            "rpNo": "-1103018.rp_no",
            "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss",
            "ctlNo": "ctlNo",
            "ordNo": "ordNo",
            "patId": "patId",
            "coopCd": "rst_dial",
            "sqlCode": -1103011,
            "fileKind": "injection",
            "facilityCd": "facilityCd",
            "file_extension": "txt"
        },
        {
            "key0": "key0",
            "key1": "SCM_DIALYSISSEND",
            "key2": "NULL",
            "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss",
            "ctlNo": "ctlNo",
            "ordNo": "ordNo",
            "patId": "patId",
            "sqlCode": -1103012,
            "fileKind": "injection",
            "facilityCd": "facilityCd",
            "file_extension": "txt"
        }
    ]
}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');