UPDATE
  mst_device_set_info_default
SET
/*%if null != hostNotificationInfo*/
  host_notification_info = jsonb_merge_recursive(host_notification_info::jsonb, /*hostNotificationInfo*/'{}'::jsonb),
/*%end*/
  up_date = /*upDate*/'0000-00-00 00:00:00.000'
WHERE
  facility_cd = /*facilityCd*/'000000'