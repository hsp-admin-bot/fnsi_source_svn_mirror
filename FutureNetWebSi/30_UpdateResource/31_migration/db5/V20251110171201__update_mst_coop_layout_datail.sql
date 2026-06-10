DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-1107000031);

DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-1107000033);

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000031, 'Secom', 'rst_dial', 'S', 'trt_unit_top_del', '02', 'セコム連携_透析実績連携', '処置実績ファイル_処置単位', '1', '<root name="セコム連携_透析実績_処置実績ファイル_処置単位">
<record detail="trt_unit_del" sqlCode="-1103003"/>
</root>
', '{
    "dataset": [
        {
            "crud": "del",
            "key0": "key0",
            "ctlNo": "ctl_no",
            "ordNo": "ord_no",
            "patId": "pat_id",
            "coopCd": "rst_dial",
            "sqlCode": -1103003,
            "facilityCd": "facility_cd"
        }
    ]
}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000033, 'Secom', 'rst_dial', 'S', 'trt_item_top_del', '02', 'セコム連携_透析実績連携', '処置実績ファイル_処置項目', '1', '<root name="セコム連携_透析実績_処置実績ファイル_実施項目">
<record detail="trt_item_del" sqlCode="-1103001"/>
</root>
', '{
    "dataset": [
        {
            "crud": "del",
            "key0": "key0",
            "ctlNo": "ctl_no",
            "ordNo": "ord_no",
            "patId": "pat_id",
            "coopCd": "rst_dial",
            "sqlCode": -1103001,
            "facilityCd": "facility_cd"
        }
    ]
}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
