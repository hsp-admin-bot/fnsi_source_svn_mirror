UPDATE
  ord_main
SET
  rst_device_set_info = jsonb_merge_recursive(rst_device_set_info::jsonb, /*deviceInfo*/'{}'::jsonb),
  -- CURRENT_TIMESTAMPを使用せずDeviceSetInfo.Resouceで定義したものを使用する
  up_date = CURRENT_TIMESTAMP
WHERE
/*%if null != ordNo*/
  ord_no = /*ordNo*/0
/*%else*/
  pat_id = /*patId*/0
AND
  facility_cd = /*facilityCd*/'000000'
  /*%if null != startDate*/
AND
  treat_date >= /*startDate*/'20180401'
  /*%end*/ 
  /*%if null != endDate*/
AND
  treat_date <= /*endDate*/'20180431'
  /*%end*/
  /*%if 0 != week.size()*/
AND
  treat_week in /*week*/(0)
  /*%end*/
  /*%if 0 != treatMethod.size()*/
AND
  ind_treatment_cd in /*treatMethod*/()
  /*%end*/
  /*%if 0 != kurCd.size()*/
AND
  ind_kur_cd in /*kurCd*/(0)
  /*%end*/
/*%end*/