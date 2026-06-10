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
 values ('F_hN10','ini_dial','','C','R','0','0','0','0','0',NULL,NULL,'9',NULL,'2020/01/14 18:13:42',NULL,
 decode('30313031323334353637383931313131313131313031', 'hex')
 ,'1','0',NULL,'2020/01/14 18:13:42','2020/01/14 18:13:42');

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
 values ('F_hN10','ini_dial','','C','R','0','0','0','0','0',NULL,NULL,'9',NULL,'2020/01/14 18:13:42',NULL,
 decode('30313131323334353637383935353535353535353032', 'hex')
 ,'1','0',NULL,'2020/01/14 18:13:42','2020/01/14 18:13:42');

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
 values ('F_hN10','ini_dial','','C','R','0','0','0','0','0',NULL,NULL,'9',NULL,'2020/01/14 18:13:42',NULL,
 decode('30313231323334353637383936363636363636363033', 'hex')
 ,'1','0',NULL,'2020/01/14 18:13:42','2020/01/14 18:13:42');
