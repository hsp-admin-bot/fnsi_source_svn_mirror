select
  t.report_id
  , t.treatment_cd
  , t.treatment_name
  , o.rst_treatment_cd
  , o.rst_treatment_name
  --FNSI-改修内容背景色 房 start
  , t.treatment_condition_setting
  --FNSI-改修内容背景色 房 end
from
  mst_treatment t
    inner join ord_main o on
      o.rst_treatment_cd = t.treatment_cd
where
  o.ord_no = /*ordNo*/1
and
  o.is_del = '0'
;
