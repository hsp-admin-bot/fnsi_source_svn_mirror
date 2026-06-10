DELETE FROM mst_coop_layout
WHERE ctl_no IN (-5010010, -5010011,-5010012, -5010013);

INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5010012, 'S_hosp', 'rep_dial', 'xml', 'S', 'del', 'xml', 'SSI 透析レポート(xml)', 'SSI', 'テスト用report', '1', '<rootNode>
  <PATIENT UPDATE_DATETIME="dataset:-400001.up_date">
    <DISP_PATID>dataset:-400001.hosp_pat_id</DISP_PATID>
    <PATID>$JOURNAL.pat_id</PATID>
    <NAME>dataset:-400001.pat_name</NAME>
    <KANA>dataset:-400001.pat_name_kana</KANA>
    <BIRTHDAY>dataset:-400001.pat_birthday</BIRTHDAY>
    <AGE>dataset:-400001.pat_age</AGE>
    <SEX>dataset:-400001.pat_sex</SEX>
    <INOUT>dataset:-400001.in_out_class</INOUT>
  </PATIENT>
  <REPORTS>
    <REPORT_DEL DIALYSIS_NO="dataset:-400019.dialysis_no" />
  </REPORTS>
</rootNode>
', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"ordNo": "ordNo", "sqlCode": -400019}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'SSI');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-5010013, 'S_hosp', 'rep_dial', 'listxml', 'S', 'del', 'xml', 'SSI 透析レポート(listxml)', 'SSI', 'テスト用report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-400010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-400001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-400001.pat_name" KANA="dataset:-400001.pat_name_kana"  SEX="dataset:-400001.pat_sex" BLOODABO="dataset:-400016.pat_blood_type_abo" BLOODRH="dataset:-400016.pat_blood_type_rh" AGE="dataset:-400001.pat_age" UPDATE_DATETIME="dataset:-400001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"sqlCode": -400010, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"patId": "patId", "sqlCode": -400016}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'SSI');