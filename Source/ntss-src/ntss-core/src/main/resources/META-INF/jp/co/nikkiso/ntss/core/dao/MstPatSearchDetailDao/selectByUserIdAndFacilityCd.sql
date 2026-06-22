select
   /*%expand "A" */*
from
   mst_pat_search_detail A
where
   A.user_id = /*userId*/null
and
   facility_cd = /*facilityCd*/'1'
and
   A.is_disp = '1'
and
   A.is_del = '0'
   -- add 5784 患者検索＞カスタム検索の選択肢の表示順不正 吉 start*/
ORDER BY up_date asc
-- add 5784 患者検索＞カスタム検索の選択肢の表示順不正 吉 end*/
;
