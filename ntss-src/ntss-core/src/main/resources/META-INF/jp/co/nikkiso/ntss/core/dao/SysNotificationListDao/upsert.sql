insert into sys_notification_list
values (
  /*notification.terminalUniqueString*/null,
  /*notification.facilityCd*/null,
  /*notification.userId*/null,
  /*notification.notificationData*/null,
  current_timestamp,
  current_timestamp)
on conflict (terminal_unique_string) do
update set 
  facility_cd = /*notification.facilityCd*/null,
  user_id = /*notification.userId*/null,
  notification_data = /*notification.notificationData*/null,
  reg_date = current_timestamp,
  up_date= current_timestamp
;