DELETE FROM sys_coop_journal;
DELETE FROM mst_coop_layout;

INSERT INTO
  sys_coop_journal (
  facility_cd
, coop_cd
, coop_cd_index
, crud
, direction
, ord_no
, coop_ord_no
, hosp_pat_id
, pat_id
, accept_no
, ana_result
, in_ana_date
, out_ana_date
, coop_result
, in_reg_date
, out_reg_date
, message
, report_cd
, dump_path
, dump
, is_editable
, is_del
, user_id
, reg_date
, up_date
  )
  VALUES
 ('TEST01', 'rep_dial', 'pdf', 'C', 'S', 0, null, '101', 101, null, '0', null, null, '0', null, null, null, 10, 'TEST.pdf', null, '1', '0', 1, '2020-06-22 10:00:00', '2020-06-22 10:00:00')
;

INSERT INTO
  mst_coop_layout
  (
  facility_cd
  , coop_cd
  , coop_cd_index
  , direction
  , coop_cd_sub
  , coop_format
  , coop_name
  , coop_vender
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
  )
  VALUES
('TEST01', 'rep_dial', 'pdf', 'S', 'cre', 'pdf', '', '', '', '1', null, null, '1', '0', 123, '2020-06-22 10:00:00', '2020-06-22 10:00:00' )
;
