DELETE FROM sys_coop_journal
WHERE ctl_no = 3300003;

INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date) VALUES(
3300003,'F_hQ03','user_test','','C','R',1,1,1,1,0,
'0', null, null,
'9','20200601','20200601',
'',
--03,,,,,,,,,,
decode('30332c2c2c2c2c2c2c2c2c2c', 'hex') ||
--,,,,,,,,
decode('2c2c2c2c2c2c2c2c', 'hex') ||
--,,1,1,TEX-ENG_001,,,,
decode('2c2c312c312c5445582d454e475f3030312c2c2c2c', 'hex') ||
--TEX-ENG_001,ppaasssswwoorrddd,1,
decode('5445582d454e475f3030312c707061617373737377776f6f72726464642c312c', 'hex') ||
--,,,,
decode('2c2c2c2c', 'hex') ||
--,,1,
decode('2c2c312c', 'hex') ||
--,
decode('2c', 'hex') ||
--,,,
decode('2c2c2c', 'hex') ||
--,1,,,,
decode('2c312c2c2c2c', 'hex'),
'0','0',12345,'20200601','20200601'
);
