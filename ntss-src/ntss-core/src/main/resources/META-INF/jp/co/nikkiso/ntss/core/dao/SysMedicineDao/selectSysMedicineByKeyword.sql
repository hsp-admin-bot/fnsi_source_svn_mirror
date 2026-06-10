select
  /*%expand "A" */*
from
  (select
     concat_ws('---',
               B.receipt_medicine_name,
               B.sales_company,
               B.standard_unit,
               B.usage_category_class,
               B.standard_no,
               B.jan_cd,
               B.standard_medicine_cd,
               B.drug_price_standard_cd,
               B.pkg_presentation,
               B.pkg_amount,
               B.pkg_unit,
               B.pkg_total_amount,
               B.pkg_total_unit) AS keyword,
     /*%expand "B" */*
   from
     sys_medicine B ) A
where
  1 = 1
/*%if null != keyword && "isNullOrEmpty" != keyword */
  and A.keyword LIKE '%' || /* keyword */null || '%'
/*%end*/
order by
  A.standard_no
limit 100
/*%if offset > 0*/
 offset /*offset * 100*/0
/*%end*/
;
