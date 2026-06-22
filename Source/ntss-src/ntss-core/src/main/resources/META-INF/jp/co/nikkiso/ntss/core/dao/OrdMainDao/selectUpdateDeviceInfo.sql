SELECT
  ord_no
FROM
  ord_main
where
/*%if null != ordNo*/
    ord_no = /*ordNo*/0
/*%else*/
  pat_id = /*patId*/0
and
  facility_cd = /*facilityCd*/'000001'
  --startDateがnullなら処理を行わないとしているが後で変更必要!!!!!!!!!
  /*%if null != startDate*/
and
  treat_date >= /*startDate*/'20180220'
  /*%end*/
  /*%if null != endDate*/
and
  treat_date <= /*endDate*/'20191231'
  /*%end*/
  /*%if 0 != week.size()*/
and
  treat_week in /* week */(1,2,3)
  /*%end*/
  /*%if 0 != treatMethod.size()*/
and
  ind_treatment_cd in /*treatMethod*/(1,2,3)
  /*%end*/
  /*%if 0 != kurCd.size()*/
and
  ind_kur_cd in /*kurCd*/(1,2,3)
/*%end*/
/*%end*/
