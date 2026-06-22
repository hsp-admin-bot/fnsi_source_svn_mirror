SELECT /*%expand "a" */*
FROM mst_coop_layout AS a
WHERE a.is_del = '0'
/*%if mstCoopLayout.facilityCd != null */
AND a.facility_cd = /*mstCoopLayout.facilityCd*/null
/*%end*/
/*%if mstCoopLayout.coopCdSub != null */
AND a.coop_cd_sub = /*mstCoopLayout.coopCdSub*/null
/*%end*/
/*%if mstCoopLayout.coopCd != null */
AND a.coop_cd = /*mstCoopLayout.coopCd*/null
/*%end*/
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
/*%if mstCoopLayout.coopCdIndex != null */
AND a.coop_cd_index = /*mstCoopLayout.coopCdIndex*/''
/*%end*/
/*%if mstCoopLayout.coopVersion != null */
AND a.coop_version = /*mstCoopLayout.coopVersion*/''
/*%end*/
-- add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
/*%if mstCoopLayout.direction != null */
AND a.direction = /*mstCoopLayout.direction*/null
/*%end*/
AND a.is_disp = '1';
