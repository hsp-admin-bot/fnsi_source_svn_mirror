UPDATE
  sys_coop_no a
SET
  facility_cd = /* scn.facilityCd */null,
  coop_ord_cd = /* scn.coopOrdCd */null,
  cur_coop_ord_no = /* scn.curCoopOrdNo */null,
  no_of_digit = /* scn.noOfDigit */null,
  padding_char = /* scn.paddingChar */null,
  padding_pos = /* scn.paddingPos */null,
  range_max = /* scn.rangeMax */null,
  range_min = /* scn.rangeMin */null,
  prefix_char = /* scn.prefixChar */null,
  suffix_char = /* scn.suffixChar */null,
  is_disp = /* scn.isDisp */null,
  is_del = /* scn.isDel */null,
  user_id = /* scn.userId */null,
-- add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  coop_version = /* scn.coopVersion */'',
-- add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  up_date = to_timestamp(/* scn.upDate */null, 'YYYY-MM-DD HH24:MI:SS')
WHERE
  a.ctl_no = /* scn.ctlNo */'999999'
