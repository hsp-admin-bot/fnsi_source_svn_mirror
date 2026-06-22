DELETE FROM mst_coop_facility;
DELETE FROM mst_coop_apilink;
DELETE FROM sys_coop_journal;

insert into mst_coop_apilink (
  facility_cd
  , coop_cd
  , coop_cd_index
  , crud
  , direction
  , api_timing_io
  , api_timing_ba
  , api_timing_seq
  , api_uri
  , api_method
  , api_body
  , continue_api_status
  , after_api_status
  , is_del
  , user_id
  , reg_date
  , up_date
) values
('TEST02','0','aaaaaa','C','S','I','B',1,'http://localhost:8092/ntss-coop-api/journal/create','POST','{"crud": "C", "ord_no": 0, "pat_id": 0, "coop_cd": "0", "user_id": 12, "base_date": "", "direction": "S", "message64": "", "ana_result": "0", "coop_ord_no": 0, "coop_result": "0", "facility_cd": "999999", "hosp_pat_id": "5", "coop_cd_index": "trans"}','{"exit": [], "continue_code": [200, 204]}','{"ana_result": "W", "coop_result": "W"}','0',1001,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP)
;


INSERT INTO
  sys_coop_journal
  (
  facility_cd
  , coop_cd
  , coop_cd_index
  , crud
  , direction
  , hosp_pat_id
  , ana_result
  , out_reg_date
  , out_ana_date
  , coop_result
  , in_reg_date
  , in_ana_date
  , dump_path
  , dump
  , is_editable
  , reg_date
  , up_date
  , is_del
  )
  VALUES
  ('TEST02', '0', 'aaaaaa',  'C', 'S' , '', '0', '2019-11-12 15:00:00', '2019-11-12 15:00:00', '0' , '2019-11-12 15:00:00' , '2019-11-12 15:00:00' , 'TEST.txt' , null , '1' , '2019-11-12 15:00:00' , '2019-11-12 15:00:00' , '0')
  ;





