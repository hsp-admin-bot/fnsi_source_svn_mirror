DELETE FROM mst_coop_layout_detail WHERE ctl_no IN 
(-1207100002,-1207100001);

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1207100002, 'F_SX', 'rst_dial', 'S', '薬剤', 'blank', '日機装標準', 'S', '1', '<root name="薬剤">
<item  name="薬剤コード" len="8" value="$BLANK"/>
<item  name="薬剤数量" len="8" value="$BLANK"/>
<item  name="薬剤回数" len="2" value="$BLANK"/>
<item  name="薬剤単位" len="8" value="$BLANK"/>
</root>', '{}'::jsonb, '1', '0', 4, '2020-04-10 17:24:24.924', '2020-04-10 17:24:28.151', 'F_SX');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1207100001, 'F_SX', 'rst_dial', 'S', '薬剤', '薬剤', '日機装標準', 'S', '1', '<root name="薬剤">
  <item name="薬剤コード" len="8" value="dataset:-1201006.hosp_cd"/>
  <item name="薬剤数量" len="8" value="dataset:-1201006.amount" padding_format="blank" padding_position="left"/>
  <item name="薬剤回数" len="2" value="dataset:-1201006.count" padding_format="blank" padding_position="left"/>
  <item name="薬剤単位" len="8" value="dataset:-1201006.unit"/>
</root>
', '{}'::jsonb, '1', '0', 4, '2020-04-10 17:24:24.924', '2023-06-16 17:46:22.550', 'F_SX');
