SELECT /*%expand "a" */*
FROM mst_coop_distribute AS a
WHERE a.is_del = '0'
/*%if ctlNo != null */
AND a.ctl_no = /*ctlNo*/0
/*%end */
/*%if facilityCd != null */
AND a.facility_cd = /*facilityCd*/null
/*%end */
/*%if coopCd != null */
AND a.coop_cd = /*coopCd*/null
/*%end */
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
/*%if coopVersion != null */
AND a.coop_version = /*coopVersion*/''
/*%end */
-- add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
AND a.is_disp = '1';
