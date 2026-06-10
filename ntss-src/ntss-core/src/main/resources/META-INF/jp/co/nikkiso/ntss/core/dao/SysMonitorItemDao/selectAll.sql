select
  /*%expand "A" */*
from
  sys_monitor_item A
order by
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
