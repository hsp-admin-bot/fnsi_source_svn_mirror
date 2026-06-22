-- 本シナリオではpreを使用しない。
DELETE FROM mst_coop_layout
WHERE ctl_no = 10000110;

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
10000110,
'XML011',
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

    <DIALYSIS_MEDI>
      <MEDI_INFO detail="ini_dial_meisai,KIND" />
    </DIALYSIS_MEDI>
  </RSTData>
</SsiData>
',
json_build_object('key', json_build_object('ini_dial_meisai', json_build_object('1','int','2','ext','9','other'))),
'1',
'0',
12345,
'20191118',
'20191118'
);
