delete from ntss.mst_coop_layout_detail where ctl_no = '-103000010';
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date) VALUES (-103000010, 'nkknkk', 'profile', 'R', '詳細項目', '原疾患', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="2" SEQ="" info="原疾患">
  <Item Code="col:$journal.detail.pat_unique_1.medical_hst_info.disease_cd">
      col:$journal.detail.pat_unique_1.medical_hst_info.name
  </Item>
  <Contents></Contents>
  <Date>col:$journal.detail.pat_unique_1.medical_hst_info.disease_date</Date>
</DetailInfo>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999', current_timestamp);
