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
--   add 10309 治療記録画面での透析レポートの表示に時間かかる場合がある 吉 start
  and
  facility_cd = /*facilityCd*/''
--   add 10309 治療記録画面での透析レポートの表示に時間かかる場合がある 吉 end
  and
  /*%if 0 != dataTypeList.size() */
  data_type in /*dataTypeList*/(1)
  /*%elseif 0 == dataTypeList.size() */
  data_type in (1)
  /*%end*/
  /*%if 0 != sysMonitorItemList.size() */
  and
	(
	/*%for sysMonitorItem : sysMonitorItemList */
-- 	/*%if sysMonitorItem.moniDataNo == null */
	     monitor_data->>/*sysMonitorItem.moniDataName*/'0' is not null
-- 	/*%elseif sysMonitorItem.moniDataNo != null */
	  or   monitor_data->>/*sysMonitorItem.moniDataNo*/'0' is not null
--     /*%end*/

		/*%if sysMonitorItem_has_next */
    /*# "or" */
    /*%end */
	/*%end*/
	)
  /*%end*/
  and
    is_del = '0'
order by
  occur_date
  -- add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 start
  ,data_type
  -- add #11899 帳票のバイタルグラフが余分な値をプロットしている 吉 end
;
