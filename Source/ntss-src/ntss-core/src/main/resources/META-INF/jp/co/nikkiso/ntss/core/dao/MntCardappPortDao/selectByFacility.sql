select port
  from (
  select
    port,max(up_date) as up_date
  from
    mnt_cardapp_port
  where
    facility_cd = /*facilityCd*/'000000'
  group by port
) as T
order by up_date desc;
