select
split_part(split_part((reverse(SUBSTRING(reverse(split_part(coop_setting::text ,/*sqcCd*/'', 1)),1,55))),'name="',2),'" ',1)
FROM mst_coop_layout
where direction =/*direction*/''
 and coop_cd = /*coopcd*/''
 and coop_version = /*coopVersion*/''
 and coop_cd_sub = /*coopCdsub*/''
 and facility_cd = /*facilityCd*/''
 and is_del = '0'
 /*%if coopCdIndex != null */
 and coop_cd_index = /*coopCdIndex*/''
 /*%end*/