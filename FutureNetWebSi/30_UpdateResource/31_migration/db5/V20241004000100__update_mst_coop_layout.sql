delete from mst_coop_layout where ctl_no = '-1010012';
INSERT INTO ntss.mst_coop_layout (ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES (-1010012, 'nkknkk', 'rep_dial', 'xml', 'S', 'del', 'xml', '日機装 透析レポート(xml)', '日機装', 'テスト用report', '1', e'<rootNode>
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
    <REPORT_DEL DIALYSIS_NO="$JOURNAL.ord_no" />
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}]}', '1', '0', -1, '2022-07-04 12:22:10.543', CURRENT_TIMESTAMP, 'NKK');
