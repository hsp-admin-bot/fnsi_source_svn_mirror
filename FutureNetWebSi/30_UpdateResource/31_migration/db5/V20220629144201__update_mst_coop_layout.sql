DELETE FROM "ntss"."mst_coop_layout" WHERE ctl_no IN (-1010012,-1010013,-1010014);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-1010012, 'nkknkk', 'rep_dial', 'xml', 'S', 'del', 'xml', '日機装 透析レポート(xml)', '日機装', 'テスト用report', '1', '<rootNode>
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
  <REPORTS _detail="report" _sqlCode="-400000">
  </REPORTS>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"sqlCode": -400000}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-1010013, 'nkknkk', 'rep_dial', 'listxml', 'S', 'del', 'xml', '日機装 透析レポート(listxml)', '日機装', 'テスト用report', '1', '<rootNode DISP_PATID_LENGTH="dataset:-400010.hosp_pat_id_len">
<PATIENT DISP_PATID="dataset:-400001.hosp_pat_id" PATID="$JOURNAL.pat_id"  NAME="dataset:-400001.pat_name" KANA="dataset:-400001.pat_name_kana"  SEX="dataset:-400001.pat_sex" BLOODABO="dataset:-400001.pat_blood_type_abo" BLOODRH="dataset:-400001.pat_blood_type_rh" AGE="dataset:-400001.pat_age" UPDATE_DATETIME="dataset:-400001.up_date"></PATIENT>
</rootNode>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"sqlCode": -400010, "facilityCd": "facilityCd"}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-1010014, 'nkknkk', 'rep_dial', 'pdf', 'S', 'del', 'pdf', '日機装 透析レポート(pdf)', '日機装', 'テスト用report', '1', NULL, NULL, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
