DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-1104000043);

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, description, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000043, 'Secom', 'ind_dial', 'S', 'trt_unit_top_del', '02', '処置依頼ファイル_処置単位', '<root name="セコム連携_透析指示_処置依頼ファイル_実施単位">
  <record detail="trt_unit_del" sqlCode="-1102015"/>
</root>
', '{"dataset": [{"crud": "del", "key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102015, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');