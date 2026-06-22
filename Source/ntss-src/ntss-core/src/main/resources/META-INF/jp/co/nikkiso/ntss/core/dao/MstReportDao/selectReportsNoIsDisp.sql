--add #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
(
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
    is_del = '0'
    and
    disp_order <> 0
  order by disp_order asc, report_class asc, report_name asc
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
   is_del = '0'
   and
   disp_order = 0
 order by disp_order asc, report_class asc, report_name asc
)
;
--add #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end
