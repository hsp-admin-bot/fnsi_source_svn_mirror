DELETE FROM mst_coop_layout
WHERE ctl_no = 10000002;

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
10000002,
'XML002',
'ini_dial',
'1',
'R',
'pre',
'text',
'サンプル1',
'TEX-SOL',
'動作確認用(cre)',
'0',
'<SsiData Type="KARTE_NOFITY">
  <NotifyDate>col:pat_obs_rec.rec_date</NotifyDate>
  <NotifyTime></NotifyTime>

  <Karte>
    <PatientID>col:pat_personal_main.pat_id</PatientID>
    <AccessionNumber>col:pat_obs_rec.bbs_ctl_no</AccessionNumber>
    <OperateMode>col:pat_obs_rec.kind_info.kind_name</OperateMode>
    <Class>col:pat_obs_rec.kind_info.class</Class>

    <Document>
      <Content>
col:pat_obs_rec.obs_rec_info.detail
      </Content>
    </Document>
  </Karte>
</SsiData>
',
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191118',
'20191118'
);
