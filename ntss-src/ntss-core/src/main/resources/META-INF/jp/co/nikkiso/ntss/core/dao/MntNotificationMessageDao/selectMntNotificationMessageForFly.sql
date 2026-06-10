select
    n.notification_message_no
from
  mnt_notification_message n inner join
  (select s.notification_message_no as notification_message_no
   from mnt_notification_status s inner join mnt_notification_message m on
      s.notification_message_no = m.notification_message_no
   where s.user_id = /*entity.notificationMessageNo*/null and s.facility_cd = /*entity.facilityCd*/null
      and m.notification_no = /*entity.notificationNo*/null and m.additional_info = /*entity.additionalInfo*/null
      order by s.reg_date desc limit 1) t
  on n.notification_message_no = t.notification_message_no
where
  content = /*entity.content*/null
;
