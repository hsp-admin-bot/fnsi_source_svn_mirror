DELETE FROM sys_coop_journal
WHERE facility_cd = 'F_h003';

insert into sys_coop_journal
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
 values ('F_h003','ini_dial','','C','R','0','0','0','0','0',NULL,NULL,'9',NULL,'2020-01-14',NULL,

 --'VIEVNXX20131004123550DK002056EGMAIN0001
decode('564945564e58583230313331303034313233353530444b30303230353645474d41494e30303031','hex')
,'1','0',NULL,'2020-01-14','2020-01-14');
