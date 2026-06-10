select
  m.notification_message_no
  , m.content
  , m.additional_info
  , s.is_read
  , m.reg_date
from
  mnt_notification_message m
    inner join mnt_notification_status s
      on m.notification_message_no = s.notification_message_no
where
  s.user_id = /*userId*/1
/*%if isNotified != null*/
and
  is_notified = /*isNotified*/null
/*%end*/
order by m.reg_date
/*%if isDesc == true*/
 desc
/*%end*/
;
