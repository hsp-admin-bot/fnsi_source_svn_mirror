delete from mnt_batch_manager where ctl_no in (1, 2);

Insert into mnt_batch_manager(
  ctl_no
  , batch_name
  , division
  , status
  , description
  , start_time
  , end_time
  , reg_date
  , up_date
) values (
    1
  , '入外区分更新'
  , '1'
  , '0'
  , '日次で2時に起動'
  , null
  , null
  , current_timestamp
  , current_timestamp
);

Insert into mnt_batch_manager(
  ctl_no
  , batch_name
  , division
  , status
  , description
  , start_time
  , end_time
  , reg_date
  , up_date
) values (
    2
  , 'スケジュール自動延長'
  , '1'
  , '0'
  , '日次で2時に起動'
  , null
  , null
  , current_timestamp
  , current_timestamp
);
