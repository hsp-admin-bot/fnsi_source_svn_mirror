UPDATE
  pat_main
SET
/*%if null != hostNotificationInfo*/
  host_notification_info = jsonb_merge_recursive(host_notification_info::jsonb, /*hostNotificationInfo*/'{}'::jsonb),
/*%end*/
  up_date = /*upDate*/'0000-00-00 00:00:00.000'
WHERE
/*%if null != patId*/
  pat_id = /*patId*/0
/*%end*/
/*%if null != facilityCd*/
AND
  facility_cd = /*facilityCd*/'000000'
/*%end*/
