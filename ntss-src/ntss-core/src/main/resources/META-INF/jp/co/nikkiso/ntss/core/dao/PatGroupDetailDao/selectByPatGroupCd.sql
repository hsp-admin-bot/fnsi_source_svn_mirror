select
-- mod FNSI-改修内容 * -> /*%expand */* dou start
-- *
-- mod FNSI-改修内容画面が正常表示できないとメッセージ不正修正 任 start
--  /*%expand **/
pat_group_cd,pat_id,facility_cd
-- mod FNSI-改修内容画面が正常表示できないとメッセージ不正修正 任 end
-- mod FNSI-改修内容 * -> /*%expand */* dou end
from
  pat_group_detail
where
  pat_group_cd = /*patGroupCd*/null
  ;
