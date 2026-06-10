DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-1210100004;

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1210100004, 'F_SX', 'exam_ord', 'S', '検査項目_削除', '検査項目_削除', 'SX連携', '依頼送信', '1', '<root name="明細詳細(検査項目)">
  <item name="詳細項目" len="258" value="dataset:-1202010.data"/>
</root>
', '{}'::jsonb, '1', '0', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
