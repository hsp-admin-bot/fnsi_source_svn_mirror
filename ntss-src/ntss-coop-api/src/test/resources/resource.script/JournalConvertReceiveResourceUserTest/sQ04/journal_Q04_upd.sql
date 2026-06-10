DELETE FROM sys_coop_journal
WHERE ctl_no = 3400000;

INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date) VALUES(
3400000,'F_hQ04','user_test','','C','R',1,1,1,1,0,
'0', null, null,
'9','20200601','20200601',
'',
--02,ああああ,いいいい,0,TEX-ENG_001,000000,
decode('30322c82a082a082a082a02c82a282a282a282a22c302c5445582d454e475f3030312c3030303030302c', 'hex') ||
--TEX-ENG_001,ppaasssswwoorrd01,
decode('5445582d454e475f3030312c707061617373737377776f6f72726430312c', 'hex') ||
--1,0,1,2020-08-20
decode('312c302c312c323032302d30382d3230', 'hex'),
'0','0',12345,'20200601','20200601'
);
