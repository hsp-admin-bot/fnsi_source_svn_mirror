UPDATE
  mst_coop_apilink A
SET
  facility_cd = /*mca.facilityCd*/null,
  coop_cd = /*mca.coopCd*/null,
  coop_cd_index = /*mca.coopCdIndex*/null,
-- add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  coop_version = /*mca.coopVersion*/'',
-- add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  crud = /*mca.crud*/null,
  direction = /*mca.direction*/null,
  api_timing_io = /*mca.apiTimingIo*/null,
  api_timing_ba = /*mca.apiTimingBa*/null,
  api_timing_seq = /*mca.apiTimingSeq*/null,
  api_uri = /*mca.apiUri*/null,
  api_method = /*mca.apiMethod*/null,
  api_body = /*mca.apiBody*/null,
  continue_api_status = /*mca.continueApiStatus*/null,
  after_api_status = /*mca.afterApiStatus*/null,
  api_type = /*mca.apiType*/null,
  sql_setting = /*mca.sqlSetting*/null,
  is_del = /*mca.isDel*/null,
  up_date = to_timestamp(/*mca.upDate*/null, 'YYYY-MM-DD HH24:MI:SS')
WHERE
  A.ctl_no = /*mca.ctlNo */'999999'
