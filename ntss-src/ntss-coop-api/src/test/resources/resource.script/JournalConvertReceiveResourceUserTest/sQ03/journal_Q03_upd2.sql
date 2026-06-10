DELETE FROM sys_coop_journal
WHERE ctl_no = 3300002;

INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date) VALUES(
3300002,'F_hQ03','user_test','','C','R',1,1,1,1,0,
'0', null, null,
'9','20200601','20200601',
'',
--02,,ああああ,いいいい,,,null,null,,,
decode('30322c2c82a082a082a082a02c82a282a282a282a22c2c2c2c2c2c2c', 'hex') ||
--,,090-XXXX-XXX0,,,,東京都千代田区霞が関３,トウキョウトチヨダクカスミガセキ３,
decode('2c2c3039302d585858582d585858302c2c2c2c938c8b9e937390e791e393638be689e082aa8ad682522c83678345834c83878345836783608388835f834e834a8358837e834b835a834c82522c', 'hex') ||
--,0,1,0,TEX-ENG_001,,0,,
decode('2c302c312c302c5445582d454e475f3030312c2c302c2c', 'hex') ||
--TEX-ENG_001,ppaasssswwoorrddd,1,
decode('5445582d454e475f3030312c707061617373737377776f6f72726464642c312c', 'hex') ||
--,15,,,
decode('2c31352c2c2c', 'hex') ||
--0,1,0,
decode('302c312c302c', 'hex') ||
--,
decode('2c', 'hex') ||
--,,,
decode('2c2c2c', 'hex') ||
--,1,,1,2020-08-01
decode('2c312c2c312c323032302d30382d3031', 'hex'),
'0','0',12345,'20200601','20200601'
);
