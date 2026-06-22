DELETE FROM mst_coop_layout
WHERE ctl_no = 10000100;

INSERT INTO mst_coop_layout (
ctl_no
, facility_cd
, coop_cd
, coop_cd_index
, direction
, coop_cd_sub
, coop_format
, coop_name
, coop_vender
, description
, is_editable
, coop_setting
, coop_ext_setting
, is_disp
, is_del
, user_id
, reg_date
, up_date
) VALUES (
10000100,
'XML010',
'ini_dial',
'1',
'R',
'pre',
'text',
'サンプル1',
'TEX-SOL',
'動作確認用(cre)',
'0',
'<SsiData Type="DIALYSISRST">
  <RSTData>
    <PatientID>col:pat_personal_main.pat_id</PatientID>
    <DIALYSIS_DATE>col:pat_coop_detail.save_1.dialysis_date</DIALYSIS_DATE>
    <DIALYSIS_NO>col:pat_coop_detail.save_1.dialysis_no</DIALYSIS_NO>
    <WEIGHT_BEFORE>col:pat_coop_detail.save_2.weight_before</WEIGHT_BEFORE>
    <WEIGHT_AFTER>col:pat_coop_detail.save_2.weight_after</WEIGHT_AFTER>

    <DIALYSIS_MEDI repeat="true">
      <MEDI_INFO CTL_NO="col:pat_coop_detail.save_4.ctl_no">
        <MEDICINE_CD>col:pat_coop_detail.save_4.medicine_cd</MEDICINE_CD>
        <MEDICINE_NAME>col:pat_coop_detail.save_4.medicine_name</MEDICINE_NAME>
        <MEDI_CLASS_NAME>col:pat_coop_detail.save_4.medi_class_name</MEDI_CLASS_NAME>
      </MEDI_INFO>
    </DIALYSIS_MEDI>
  </RSTData>
</SsiData>
',
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191118',
'20191118'
);
