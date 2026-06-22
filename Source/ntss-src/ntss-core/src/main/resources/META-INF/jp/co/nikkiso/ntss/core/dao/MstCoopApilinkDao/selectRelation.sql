select
  /*%expand*/*
from
  mst_coop_apilink
where
  facility_cd=/*mstCoopApilink.facilityCd*/'000000'
  /*%if mstCoopApilink.coopCd != null */
  AND coop_cd=/*mstCoopApilink.coopCd*/''
  /*%end */
  /*%if mstCoopApilink.coopCdIndex != null */
  AND coop_cd_index=/*mstCoopApilink.coopCdIndex*/''
  /*%end */
-- add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /*%if mstCoopApilink.coopVersion != null */
  AND coop_version=/*mstCoopApilink.coopVersion*/''
  /*%end */
-- add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  /*%if mstCoopApilink.crud != null */
  AND crud=/*mstCoopApilink.crud*/''
  /*%end */
  /*%if mstCoopApilink.direction != null */
  AND direction=/*mstCoopApilink.direction*/''
  /*%end */
  /*%if mstCoopApilink.apiTimingIo != null */
  AND api_timing_io=/*mstCoopApilink.apiTimingIo*/'1'
  /*%end */
  /*%if mstCoopApilink.apiTimingBa != null */
  AND api_timing_ba=/*mstCoopApilink.apiTimingBa*/'A'
  /*%end */
  AND is_del='0'
order by api_timing_seq
  ;
