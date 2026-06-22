delete from mst_coop_facility
where facility_cd in ('000001', '000002', '000003');

insert into mst_coop_facility
( ctl_no
, facility_cd
, description
, is_disp
, is_del
, if_edge_setting
, common_setting
, user_id
, reg_date
, up_date) VALUES (
  100
, '000001'
, null
, '1'
, '0'
, null
, null
, '101'
, CURRENT_TIMESTAMP(3)
, CURRENT_TIMESTAMP(3)
),
(
  101
, '000002'
, null
, '1'
, '0'
, null
, '{ "ins_mode": "0" }'
, '101'
, CURRENT_TIMESTAMP(3)
, CURRENT_TIMESTAMP(3)
),
(
  102
, '000003'
, null
, '1'
, '0'
, null
, '{ "ins_mode": "0", "coop_ord_cd": [{"ord_cd": "0", "createIndex": "true"}, {"ord_cd": "1"}], "dataset_limit": 10 }'
, '101'
, CURRENT_TIMESTAMP(3)
, CURRENT_TIMESTAMP(3)
);