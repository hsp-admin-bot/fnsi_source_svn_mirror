DELETE FROM sys_coop_journal
WHERE ctl_no = 10000002;

INSERT INTO sys_coop_journal (
ctl_no
, facility_cd
, coop_cd
, coop_cd_index
, crud
, direction
, ord_no
, coop_ord_no
, hosp_pat_id
, pat_id
, accept_no
, ana_result
, in_ana_date
, out_ana_date
, coop_result
, in_reg_date
, out_reg_date
, dump_path
, dump
, is_editable
, is_del
, user_id
, reg_date
, up_date
) VALUES (
10000002, 'XML002', 'ini_dial', '1','C','R',1,1,1,1,0,
'0','20191119','20191119',
'9','20191119','20191119',
'',
'<SsiData Type="KARTE_NOFITY">
  <NotifyDate>20200417</NotifyDate>
  <NotifyTime>134000</NotifyTime>

  <Karte>
    <PatientID>12345678</PatientID>
    <AccessionNumber>000000000001</AccessionNumber>
    <OperateMode>NW</OperateMode>
    <Class>CA01</Class>

    <Document>
      <Content>
$PAT_BASIC_INFO/DISP_PATID$
      </Content>
    </Document>
  </Karte>
</SsiData>
',
'0', '0', 12345,'20191119','20191119'
);
