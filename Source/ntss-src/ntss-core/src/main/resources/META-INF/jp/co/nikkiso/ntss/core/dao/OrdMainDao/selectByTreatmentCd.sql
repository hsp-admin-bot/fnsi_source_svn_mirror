SELECT
  /*%expand "A" */*
FROM
  ord_main A
WHERE
  facility_cd = /*facilityCd*/'000000'
/*%if null != treats*/
AND
  ind_treatment_cd = /*treats*/'0'
/*%end*/
/*%if isNotSent*/
and
  A.rst_dialysis_state = '0'
/*%end*/
and
  A.ord_no in /*ordNoList*/(null)
--add 7325 治療方法マスタで治療方法を変更してもイベント作成されない zhaoqi 20221103 start
and A.treat_date >= to_char(now(), 'YYYYMMDD')
--add 7325 治療方法マスタで治療方法を変更してもイベント作成されない zhaoqi 20221115 start
and A.ind_kur_cd > 0
--add 7325 治療方法マスタで治療方法を変更してもイベント作成されない zhaoqi 20221115 end
--add 7325 治療方法マスタで治療方法を変更してもイベント作成されない zhaoqi 20221103 end
ORDER BY treat_date, ord_no
