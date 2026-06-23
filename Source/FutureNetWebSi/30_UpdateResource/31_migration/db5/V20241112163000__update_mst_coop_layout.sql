delete from mst_coop_layout where ctl_no in ('-6040012','-6040013');

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6040012, 'C_hosp', 'rep_dial', 'listxml', 'S', 'del', 'xml', 'CSI透析レポート(listxml)', 'MIRAIs', 'テスト用report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-200010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-200001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-200001.pat_name" KANA="dataset:-200001.pat_name_kana"  SEX="dataset:-200001.pat_sex" BLOODABO="dataset:-200001.pat_blood_type_abo" BLOODRH="dataset:-200001.pat_blood_type_rh" AGE="dataset:-200001.pat_age" UPDATE_DATETIME="dataset:-200001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -200001}, {"sqlCode": -200010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'CSI');


INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6040013, 'C_hosp', 'rep_dial', 'xml', 'S', 'del', 'xml', 'CSI透析レポート(xml)', 'MIRAIs', 'テスト用report', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-200001.up_date">
    <DISP_PATID>dataset:-200001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-200001.pat_name</NAME>
    <KANA>dataset:-200001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-200001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-200001.pat_age</AGE>
    <SEX>dataset:-200001.pat_sex</SEX>
    <INOUT>dataset:-200001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS>
    <REPORT_DEL DIALYSIS_NO="$JOURNAL.ord_no"/>
  </REPORTS>
</rootNode>
', '{"dataset": [{"patId": "patId", "sqlCode": -200001}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'CSI');