with phy_class as (
select
	count(1)
from
	mst_facility F,
	jsonb_array_elements(F.advanced_settings->'func_advcds') func
where
	F.facility_cd = /* facilityCd */null
	and func->>'func_advcd'= 'A12'
)
SELECT
A.exam_set_cd,
A.facility_cd,
A.fn_exam_set_cd,
A.set_class,
A.exam_set_name,
A.exam_set_short_name,
A.exam_set_class,
-- del 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm start
-- A.is_in_hospital,
-- del 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm end
A.can_emergency,
A.other_exam_time,
A.exam_item_info,
A.in_hospital_cd1,
A.sbt_cd1,
A.in_hospital_cd2,
A.sbt_cd2,
A.in_hospital_cd3,
A.sbt_cd3,
A.label_info,
A.is_disp,
A.is_del,
A.reg_date,
-- add FNSI-No664 グラフ表示 関 start
A.graph_set,
-- add FNSI-No664 グラフ表示 関 end
A.up_date
FROM mst_exam_set A
WHERE
/*%if null != facilityCd */
  A.facility_cd = /* facilityCd */null
/*%end */
-- 7025 削除済みの検査セットが表示される 関俊楠 start
  and is_disp = '1'
-- 7025 削除済みの検査セットが表示される 関俊楠 end
  and (
    A.exam_set_class = '0'
    /*%if requestFlg */
    or A.exam_set_class = '1'
    /*%end */
    /*%if recodeFlg */
    or A.exam_set_class = '2'
    /*%end */
    or ( (select * from phy_class) > 0 and A.exam_set_class = '3')
)
ORDER BY exam_set_cd
;
