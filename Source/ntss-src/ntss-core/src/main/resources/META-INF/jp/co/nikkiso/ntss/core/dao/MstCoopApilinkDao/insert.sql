INSERT
INTO mst_coop_apilink(
  facility_cd
  , coop_cd
  , coop_cd_index
-- add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  , coop_version
-- add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
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
  , api_type
  , sql_setting
)
VALUES (
  /*mca.facilityCd*/null
  , /*mca.coopCd*/null
  , /*mca.coopCdIndex*/null
-- add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  , /*mca.coopVersion*/''
-- add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  , /*mca.crud*/null
  , /*mca.direction*/null
  , /*mca.apiTimingIo*/null
  , /*mca.apiTimingBa*/null
  , /*mca.apiTimingSeq*/null
  , /*mca.apiUri*/null
  , /*mca.apiMethod*/null
  , /*mca.apiBody*/null
  , /*mca.continueApiStatus*/null
  , /*mca.afterApiStatus*/null
  , /*mca.isDel*/null
  , /*mca.userId*/null
  , to_timestamp(/*mca.regDate*/null, 'YYYY-MM-DD HH24:MI:SS')
  , to_timestamp(/*mca.upDate*/null, 'YYYY-MM-DD HH24:MI:SS')
  , /*mca.apiType*/null
  , /*mca.sqlSetting*/null
);
