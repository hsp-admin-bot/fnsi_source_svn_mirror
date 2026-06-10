--add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao start
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
   disp_order = 0
 order by disp_order asc, report_class asc, report_name asc
)
;
--add #12650 登録済み紹介状が帳票マスタ削除の影響を受けるのは不適切 zhao end