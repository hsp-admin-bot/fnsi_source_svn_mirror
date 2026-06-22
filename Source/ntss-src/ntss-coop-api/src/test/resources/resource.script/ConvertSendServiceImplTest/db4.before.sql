delete from mst_user_authentication
where user_id = 1001;

insert into mst_user_authentication
( user_id
, facility_cd
, disp_user_id
, user_password
, failure_cnt
, reg_date
) values (
  1001
, 'TEST02'
, 'dispUser'
, 'test'
, 0
, current_timestamp
);