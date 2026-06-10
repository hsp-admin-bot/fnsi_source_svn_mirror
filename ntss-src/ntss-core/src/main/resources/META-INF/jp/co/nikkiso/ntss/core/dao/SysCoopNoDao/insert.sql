INSERT
INTO sys_coop_no(
  facility_cd
  , coop_ord_cd
  , cur_coop_ord_no
  , no_of_digit
  , padding_char
  , padding_pos
  , range_max
  , range_min
  , prefix_char
  , suffix_char
  , is_disp
  , is_del
  , user_id
-- add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  , coop_version
-- add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  , reg_date
  , up_date
)
VALUES (
  /*scn.facilityCd*/null
  , /*scn.coopOrdCd*/null
  , /*scn.curCoopOrdNo*/null
  , /*scn.noOfDigit*/null
  , /*scn.paddingChar*/null
  , /*scn.paddingPos*/null
  , /*scn.rangeMax*/null
  , /*scn.rangeMin*/null
  , /*scn.prefixChar*/null
  , /*scn.suffixChar*/null
  , /*scn.isDisp*/null
  , /*scn.isDel*/null
  , /*scn.userId*/null
-- add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  , /*scn.coopVersion*/''
-- add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  , to_timestamp(/*scn.regDate*/null, 'YYYY-MM-DD HH24:MI:SS')
  , to_timestamp(/*scn.upDate*/null, 'YYYY-MM-DD HH24:MI:SS')
);
