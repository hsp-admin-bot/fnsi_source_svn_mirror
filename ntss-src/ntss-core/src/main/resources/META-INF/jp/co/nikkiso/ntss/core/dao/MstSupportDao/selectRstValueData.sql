SELECT
  sum(to_number(ind_rst_value, '9999999999.99')) ind_rst_value
FROM
  ord_material_save
WHERE
  facility_cd = /*facilityCd*/'996996'
  AND pat_id = /*patId*/'33'
  --FNSI-修正 #6557 一期間のデータを取得に変更 ljx add start
  AND supplies_base_date >= /*startDate*/'20200609'
  AND supplies_base_date <= /*endDate*/'20200609'
  --FNSI-修正 #6557 一期間のデータを取得に変更 ljx add end
  AND supplies_cd = /*suppliesCd*/'7000'
  --FNSI-修正 #6557 指示/実績別(1:指示、2：実績)のデータを取得に変更 ljx add start
  AND ind_rst_class = /*rstClass*/'2'
  --FNSI-修正 #6557 指示/実績別(1:指示、2：実績)のデータを取得に変更 ljx add end
--     add  5527 除外期間が適用されていない。張 start
      /*%if listExceptionPeriod != null && listExceptionPeriod.size() != 0*/
          /*%for exceptionPeriod : listExceptionPeriod*/
                AND supplies_base_date NOT BETWEEN /*exceptionPeriod.exceptionPeriodFrom*/'20200201' AND /*exceptionPeriod.exceptionPeriodTo*/'20210131'
          /*%end*/
      /*%end*/
--     add  5527 除外期間が適用されていない。張 end