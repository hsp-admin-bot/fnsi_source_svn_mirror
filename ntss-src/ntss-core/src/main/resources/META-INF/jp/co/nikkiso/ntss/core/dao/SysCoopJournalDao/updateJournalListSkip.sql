update sys_coop_journal  set
--#8348 mod 2023-02-15 卓 start
    ana_result = /*journalList.anaResult*/'0',
    coop_result = /*journalList.coopResult*/'0',
    message = /*journalList.message*/'',
    up_date = CURRENT_TIMESTAMP

/*%if journalList.inAnaDate != null*/
    ,in_ana_date=/*journalList.inAnaDate*/'2019-11-10 11:00:00'
/*%end*/
/*%if journalList.outAnaDate != null*/
    ,out_ana_date=/*journalList.outAnaDate*/'2019-11-10 11:00:00'
/*%end*/
/*%if journalList.inRegDate != null*/
    ,in_reg_date=/*journalList.inRegDate*/'2019-11-10 11:00:00'
/*%end*/
/*%if journalList.outRegDate != null*/
    ,out_reg_date=/*journalList.outRegDate*/'2019-11-10 11:00:00'
/*%end*/
--#8348 mod 2023-02-15 卓 end
where ctl_no = /*journalList.ctlNo*/0
;

