DELETE FROM mst_coop_layout
WHERE ctl_no = 10000001;

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
10000001,
'XML001',
'ini_dial',
'1',
'R',
'pre',
'text',
'サンプル1',
'TEX-SOL',
'動作確認用(cre)',
'0',
'<SsiData Type="DIALYSISPLAN">
  <PlanData>
    <PatientID>col:pat_personal_main.pat_id</PatientID>
    <DIALYSIS_DATE>col:pat_exam_main.reg_exam_date</DIALYSIS_DATE>
    <DIALYSIS_NO>col:pat_exam_main.cop_order_no1</DIALYSIS_NO>
    <DIALYSIS_TIME>col:pat_exam_main.cop_order_no2</DIALYSIS_TIME>

    <DIALYSIS_COND>
      <COND_INFO CTL_NO="col:pat_exam_main.exam_order_info.ctl_no">
        <DIALYSIS_ITEM_NAME>col:pat_exam_main.exam_order_info.dialysis_item_name</DIALYSIS_ITEM_NAME>
        <VALUE>col:pat_exam_main.exam_order_info.value</VALUE>
        <VALUE_NAME>col:pat_exam_main.exam_order_info.value_name</VALUE_NAME>
        <UNIT>col:pat_exam_main.exam_order_info.unit</UNIT>
      </COND_INFO>
    </DIALYSIS_COND>
  </PlanData>
</SsiData>
',
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191118',
'20191118'
);
