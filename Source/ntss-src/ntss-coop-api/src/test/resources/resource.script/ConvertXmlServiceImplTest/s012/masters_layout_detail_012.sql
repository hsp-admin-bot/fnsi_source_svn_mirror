DELETE FROM mst_coop_layout_detail
WHERE ctl_no IN (10000120, 10000121, 10000122);

INSERT INTO ntss.mst_coop_layout_detail (
ctl_no
, facility_cd
, coop_cd
, direction
, coop_cd_detail
, coop_cd_detail_sub
, coop_name
, description
, is_editable
, coop_setting
, coop_ext_setting
, is_disp
, is_del
, user_id
, reg_date
, up_date
) VALUES (10000120,'XML012','ini_dial','R','ini_dial_meisai','int','富士通想定透析初回申込-申込詳細','For test','1','
<MEDI_INFO CTL_NO="col:pat_coop_detail.save_4.ctl_no">
  <MEDICINE_CD>col:pat_coop_detail.save_4.medicine_cd</MEDICINE_CD>
  <MEDICINE_NAME>col:pat_coop_detail.save_4.medicine_name</MEDICINE_NAME>
  <MEDI_CLASS_NAME>col:pat_coop_detail.save_4.medi_class_name</MEDI_CLASS_NAME>
</MEDI_INFO>
','{}',
'1','0','4126','2019/12/13 6:16:24','2019/12/13 6:16:24');

INSERT INTO ntss.mst_coop_layout_detail (
ctl_no
, facility_cd
, coop_cd
, direction
, coop_cd_detail
, coop_cd_detail_sub
, coop_name
, description
, is_editable
, coop_setting
, coop_ext_setting
, is_disp
, is_del
, user_id
, reg_date
, up_date
) VALUES (10000121,'XML012','ini_dial','R','ini_dial_meisai','ext','富士通想定透析初回申込-申込詳細','For test','1','
<MEDI_INFO CTL_NO="col:pat_coop_detail.save_4.ctl_no">
  <MEDICINE_CD>col:pat_coop_detail.save_4.medicine_cd</MEDICINE_CD>
  <MEDICINE_NAME>col:pat_coop_detail.save_4.medicine_name</MEDICINE_NAME>
  <MEDI_CLASS_NAME>col:pat_coop_detail.save_4.medi_class_name</MEDI_CLASS_NAME>
  <MEDI_APPLI_CD>col:pat_coop_detail.save_5.medi_appli_cd</MEDI_APPLI_CD>
  <MEDI_APPLI_DESC>col:pat_coop_detail.save_5.medi_appli_desc</MEDI_APPLI_DESC>
</MEDI_INFO>
','{}',
'1','0','4126','2019/12/13 6:16:24','2019/12/13 6:16:24');

INSERT INTO ntss.mst_coop_layout_detail (
ctl_no
, facility_cd
, coop_cd
, direction
, coop_cd_detail
, coop_cd_detail_sub
, coop_name
, description
, is_editable
, coop_setting
, coop_ext_setting
, is_disp
, is_del
, user_id
, reg_date
, up_date
) VALUES (10000122,'XML012','ini_dial','R','ini_dial_meisai','other','富士通想定透析初回申込-申込詳細','For test','1','
<!--コメント-->
<MEDI_INFO CTL_NO="col:pat_coop_detail.save_4.ctl_no">
  <MEDICINE_CD>col:pat_coop_detail.save_4.medicine_cd</MEDICINE_CD>
  <MEDICINE_NAME>col:pat_coop_detail.save_4.medicine_name</MEDICINE_NAME>
  <FINDINGS>col:pat_coop_detail.save_6.findings</FINDINGS>
</MEDI_INFO>
','{}',
'1','0','4126','2019/12/13 6:16:24','2019/12/13 6:16:24');
