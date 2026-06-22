select
  /*%expand "A" */*
from
  sys_monitor_item A
where
  /*%if moniDataType != null*/
  A.moni_data_type = /*moniDataType*/'0'
  and
  /*%else*/
  A.moni_data_type is null
  and
  /*%end*/
  A.vital_monitor_class = /*vitalMonitorClass*/'0'
order by
-- 9312 MOD Add Sort case
--  case
--    when moni_data_type ='Z' then right(moni_data_no, 1) || lpad(substring(moni_data_no, 2, length(moni_data_no) - 2), 3, '0')
--    else lpad(moni_data_no, 5, '0')
--  end
  case
    moni_data_no ~ '^[-+]?\d+$'
  when true
    then to_number(moni_data_no, '9999999')
  else
    case
      when left(moni_data_no, 1) = 'Z'
        then to_number( '1' || right (moni_data_no, 1) || lpad( substring(moni_data_no, 2, length(moni_data_no) - 1), 4,	'0') , '9999999')
      else
        to_number(
          ascii(left(moni_data_no, 1)) || lpad(right(moni_data_no, length(moni_data_no) - 1) , 4, '0'), '9999999'
        )
    end
  end
;
