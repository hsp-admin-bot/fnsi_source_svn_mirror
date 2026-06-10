DELETE FROM mst_coop_layout_detail WHERE ctl_no IN (
  -1104000005
  );

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000005, 'Secom', 'ind_dial', 'S', 'trt_item_top_cre', '01', 'セコム連携_透析指示連携', '処置依頼ファイル_処置項目', '1', '<root name="セコム連携_透析指示_処置依頼ファイル_実施項目">
  <record detail="trt_item_cre" sqlCode="-1102027"/>
</root>
', '{
  "dataset": [
    {
      "key0": "1102019.key0",
      "ctlNo": "1102019.ctl_no",
      "ordNo": "1102019.ord_no",
      "patId": "1102019.pat_id",
      "sqlCode": -1102027,
      "facilityCd": "1102019.facility_cd"
    }
  ]
}'::jsonb, '1', '0', -1, '2025-06-27 14:08:24.400', CURRENT_TIMESTAMP, 'Secom');