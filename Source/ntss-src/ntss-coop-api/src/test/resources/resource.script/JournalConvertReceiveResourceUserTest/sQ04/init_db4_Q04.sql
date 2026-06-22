DELETE FROM mst_user_authentication
WHERE facility_cd = 'F_hQ04';

INSERT INTO mst_user_authentication (
  user_id
, facility_cd
, disp_user_id
, user_password
, failure_cnt
, reg_date
, up_date) values (
  888
, 'F_hQ04'
, '888'
, ''
, 2
, '20200803'
, '20200803'
);
