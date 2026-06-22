-- add #11897 治療経過表のグラフ出力が要求通りではない 高 start
select
  ord_no
     , bio_moni_ctl_no
     , occur_date
     , monitor_data
     , facility_cd
     , data_type
from
  mni_monitor
where
    ord_no = /*ordNo*/0
  and
    facility_cd = /*facilityCd*/''
  and
  /*%if 0 != dataTypeList.size() */
    data_type in /*dataTypeList*/(1)
  /*%elseif 0 == dataTypeList.size() */
  data_type in (1)
  /*%end*/
  and
    is_del = '0'
order by
  occur_date
  -- add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 start
  ,data_type
  -- add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 end
;
-- add #11897 治療経過表のグラフ出力が要求通りではない 高 end
