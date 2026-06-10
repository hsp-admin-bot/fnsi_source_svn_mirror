with query1 as (
  --- 指示情報から治療時間を取得する(int:単位は分)
  select 
	  case
	    when 
	         replace((((ind_cond_info::jsonb->'1')::jsonb->'value')::text),'"','')::Int is null 
	         then 
	           0
	         else 
	           replace((((ind_cond_info::jsonb->'1')::jsonb->'value')::text),'"','')::Int
	  end as mininute
  from
    ord_main
  where
    ord_no = /*ord_no*/0
)
update 
  mnt_machine_state mms1
set 
  --- query1の値を分として開始予定時刻に加算する
  end_plan_date = mms2.start_plan_date + interval '1minute' * q1.mininute,
  up_date = transaction_timestamp()
from
  mnt_machine_state mms2,
  query1 q1
where
  mms1.facility_cd = mms2.facility_cd
  and
  mms1.machine_type_cd  = mms2.machine_type_cd
  and
  mms1.machine_serial = mms2.machine_serial
  and
  mms2.facility_cd = /*facility_cd*/''
  and
  mms2.machine_type_cd = /*machine_type_cd*/''
  and
  mms2.machine_serial = /*machine_serial*/''
  