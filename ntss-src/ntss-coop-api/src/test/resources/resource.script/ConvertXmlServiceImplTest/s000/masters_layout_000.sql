DELETE FROM mst_coop_layout
WHERE ctl_no = 10000000;

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
10000000,
'XML000',
'ini_dial',
'1',
'R',
'pre',
'text',
'サンプル1',
'TEX-SOL',
'動作確認用(cre)',
'0',
'<SsiData Type="PAT_INF">
  <PatientData>
    <PatientID>col:pat_personal_main.pat_id</PatientID>
    <PatientDIALYSISInfo>
      <Doctor Code="col:pat_personal_main.doctor.doctor_cd" />
      <DialysisDoctor Code="col:pat_personal_main.doctor.dialysis_doctor_cd" />
      <DialysisNurse Code="col:pat_personal_main.doctor.dialysis_nurse_cd"/>
    </PatientDIALYSISInfo>
  </PatientData>
</SsiData>
',
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191118',
'20191118'
);
