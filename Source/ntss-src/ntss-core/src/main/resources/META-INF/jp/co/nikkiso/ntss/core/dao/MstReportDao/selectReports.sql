-- add 6156 帳票画面の帳票の表示順について 吉 start
(
-- add 6156 帳票画面の帳票の表示順について 吉 end
select
  /*%expand*/*
from
  mst_report
where
  facility_cd = /*facilityCd*/null
/*%if reportClass != null*/
and
  report_class = /*reportClass*/null
/*%end*/
/*%if reportType != null*/
and
  report_type = /*reportType*/null
/*%end*/
and
  is_disp = '1'
and
  is_del = '0'
-- add 6156 帳票画面の帳票の表示順について 吉 start
and disp_order <> 0
-- add 6156 帳票画面の帳票の表示順について 吉 end
order by disp_order asc
-- add 6156 帳票画面の帳票の表示順について 吉 start
    ,report_class asc, report_name asc
-- add 6156 帳票画面の帳票の表示順について 吉 end
-- add 6156 帳票画面の帳票の表示順について 吉 start
)
union all
(select
  /*%expand*/*
from
  mst_report
where
  facility_cd = /*facilityCd*/null
/*%if reportClass != null*/
and
  report_class = /*reportClass*/null
/*%end*/
/*%if reportType != null*/
and
  report_type = /*reportType*/null
/*%end*/
and
  is_disp = '1'
and
  is_del = '0'
and disp_order = 0
-- add 6156 帳票画面の帳票の表示順について 吉 start
order by disp_order asc,report_class asc, report_name asc
-- add 6156 帳票画面の帳票の表示順について 吉 end
)
-- add 6156 帳票画面の帳票の表示順について 吉 end
;
