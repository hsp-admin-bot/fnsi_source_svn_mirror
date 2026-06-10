DELETE from ntss.sys_coop_journal
WHERE ctl_no > 0;

insert into ntss.sys_coop_journal
(
 facility_cd
 , coop_cd
 , coop_cd_index
 , crud
 , direction
 , ord_no
 , coop_ord_no
 , hosp_pat_id
 , pat_id
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
)
 values ('F_hN11','ini_dial','','C','R','0','0','0','0','0',NULL,NULL,'9',NULL,'2020/01/14 18:13:42',NULL,
 decode('30313233343536373839', 'hex')
 || decode('31', 'hex')
 || decode('31', 'hex')
 || decode('2D', 'hex')
 || decode('2B', 'hex')
 ,'1','0',NULL,'2020/01/14 18:13:42','2020/01/14 18:13:42');
