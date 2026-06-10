DELETE FROM sys_coop_journal
WHERE ctl_no = 10000001;

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
10000001, 'XML001', 'ini_dial', '1','C','R',1,1,1,1,0,
'0','20191119','20191119',
'9','20191119','20191119',
'',
--<SsiData Type="DIALYSISPLAN">
--  <PlanData>
--    <PatientID>12345678</PatientID>
--    <DIALYSIS_DATE>20200417</DIALYSIS_DATE>
--    <DIALYSIS_NO>0</DIALYSIS_NO>
--    <DIALYSIS_TIME>180</DIALYSIS_TIME>
--
--    <DIALYSIS_COND>
--      <COND_INFO CTL_NO="1234">
--        <DIALYSIS_ITEM_NAME>血圧管理</DIALYSIS_ITEM_NAME>
--        <VALUE>80</VALUE>
--        <VALUE_NAME>最低血圧</VALUE_NAME>
--        <UNIT>mmHg</UNIT>
--      </COND_INFO>
--    </DIALYSIS_COND>
--  </PlanData>
--</SsiData>
decode('3c5373694461746120547970653d224449414c59534953504c414e223e', 'hex') ||
decode('3c506c616e446174613e', 'hex') ||
decode('3c50617469656e7449443e31323334353637383c2f50617469656e7449443e', 'hex') ||
decode('3c4449414c595349535f444154453e32303230303431373c2f4449414c595349535f444154453e', 'hex') ||
decode('3c4449414c595349535f4e4f3e303c2f4449414c595349535f4e4f3e', 'hex') ||
decode('3c4449414c595349535f54494d453e3138303c2f4449414c595349535f54494d453e', 'hex') ||
decode('3c4449414c595349535f434f4e443e', 'hex') ||
decode('3c434f4e445f494e464f2043544c5f4e4f3d2231323334223e', 'hex') ||
decode('3c4449414c595349535f4954454d5f4e414d453e8c8c88b38ac7979d3c2f4449414c595349535f4954454d5f4e414d453e', 'hex') ||
decode('3c56414c55453e38303c2f56414c55453e', 'hex') ||
decode('3c56414c55455f4e414d453e8dc592e18c8c88b33c2f56414c55455f4e414d453e', 'hex') ||
decode('3c554e49543e6d6d48673c2f554e49543e', 'hex') ||
decode('3c2f434f4e445f494e464f3e', 'hex') ||
decode('3c2f4449414c595349535f434f4e443e', 'hex') ||
decode('3c2f506c616e446174613e', 'hex') ||
decode('3c2f537369446174613e', 'hex')
,
'0', '0', 12345,'20191119','20191119'
);
