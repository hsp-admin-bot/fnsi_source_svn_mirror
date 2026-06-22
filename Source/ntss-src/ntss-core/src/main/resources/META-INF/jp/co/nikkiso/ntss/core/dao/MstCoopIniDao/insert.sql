INSERT
INTO mst_coop_ini(
  facility_cd
  , coop_ini_memo
  , coop_ini_info
  , key_mapping
  , is_disp
  , is_del
  , reg_date
  , up_date
)
VALUES (
  /*mci.facilityCd*/null
  , /*mci.coopIniMemo*/null
  , /*mci.coopIniInfo*/null
  , /*mci.keyMapping*/null
  , /*mci.isDisp*/null
  , /*mci.isDel*/null
  , to_timestamp(/*mci.regDate*/null, 'YYYY-MM-DD HH24:MI:SS')
  , to_timestamp(/*mci.upDate*/null, 'YYYY-MM-DD HH24:MI:SS')
);
