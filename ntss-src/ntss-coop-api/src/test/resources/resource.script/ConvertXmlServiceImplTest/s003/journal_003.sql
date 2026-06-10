DELETE FROM sys_coop_journal
WHERE ctl_no = 10000003;

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
10000003, 'XML003', 'ini_dial', '1','C','R',1,1,1,1,0,
'0','20191119','20191119',
'9','20191119','20191119',
'',
--<SsiData Type="DIALYSISRST">
--  <RSTData>
--    <PatientID>12345678</PatientID>
--    <DIALYSIS_DATE>20200417</DIALYSIS_DATE>
--    <DIALYSIS_NO>112233</DIALYSIS_NO>
--    <WEIGHT_BEFORE>72.3</WEIGHT_BEFORE>
--    <WEIGHT_AFTER>71.0</WEIGHT_AFTER>
--
--    <DISPOSE>
--      <DISPOSE_INFO CTL_NO="9988">
--        <TENCD>753
--        </TENCD>
--        <TKJNAM>TKJNAM</TKJNAM>
--        <AMOUNT>12</AMOUNT>
--        <UNIT>個</UNIT>
--      </DISPOSE_INFO>
--    </DISPOSE>
--
--    <DIALYSIS_MEDI>
--      <MEDI_INFO CTL_NO="7777">
--        <MEDICINE_CD>1111</MEDICINE_CD>
--        <MEDICINE_NAME>アスピリンダイアルミネート</MEDICINE_NAME>
--        <MEDI_CLASS_NAME>NSAIDs</MEDI_CLASS_NAME>
--      </MEDI_INFO>
--    </DIALYSIS_MEDI>
--  </RSTData>
--</SsiData>
decode('3c5373694461746120547970653d224449414c59534953525354223e', 'hex') ||
decode('3c525354446174613e', 'hex') ||
decode('3c50617469656e7449443e31323334353637383c2f50617469656e7449443e', 'hex') ||
decode('3c4449414c595349535f444154453e32303230303431373c2f4449414c595349535f444154453e', 'hex') ||
decode('3c4449414c595349535f4e4f3e3131323233333c2f4449414c595349535f4e4f3e', 'hex') ||
decode('3c5745494748545f4245464f52453e37322e333c2f5745494748545f4245464f52453e', 'hex') ||
decode('3c5745494748545f41465445523e37312e303c2f5745494748545f41465445523e', 'hex') ||
decode('3c444953504f53453e', 'hex') ||
decode('3c444953504f53455f494e464f2043544c5f4e4f3d2239393838223e', 'hex') ||
decode('3c54454e43443e373533', 'hex') ||
decode('3c2f54454e43443e', 'hex') ||
decode('3c544b4a4e414d3e544b4a4e414d3c2f544b4a4e414d3e', 'hex') ||
decode('3c414d4f554e543e31323c2f414d4f554e543e', 'hex') ||
decode('3c554e49543e8cc23c2f554e49543e', 'hex') ||
decode('3c2f444953504f53455f494e464f3e', 'hex') ||
decode('3c2f444953504f53453e', 'hex') ||
decode('3c4449414c595349535f4d4544493e', 'hex') ||
decode('3c4d4544495f494e464f2043544c5f4e4f3d2237373737223e', 'hex') ||
decode('3c4d45444943494e455f43443e313131313c2f4d45444943494e455f43443e', 'hex') ||
decode('3c4d45444943494e455f4e414d453e834183588373838a8393835f83438341838b837e836c815b83673c2f4d45444943494e455f4e414d453e', 'hex') ||
decode('3c4d4544495f434c4153535f4e414d453e4e53414944733c2f4d4544495f434c4153535f4e414d453e', 'hex') ||
decode('3c2f4d4544495f494e464f3e', 'hex') ||
decode('3c2f4449414c595349535f4d4544493e', 'hex') ||
decode('3c2f525354446174613e', 'hex') ||
decode('3c2f537369446174613e', 'hex')
,
'0', '0', 12345,'20191119','20191119'
);
