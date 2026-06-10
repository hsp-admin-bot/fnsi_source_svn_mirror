--施設マスタのキーワード検索
select
    /*%expand "A" */*
from
    sys_facility A
where
    A.is_del = '0'
and A.is_disp = '1'
/*%if prefecturesCd != null*/
and A.prefectures_cd = /*prefecturesCd*/'0'
/*%end*/
/*%if keyword != null*/
and A.facility_name like '%' || /*keyword*/null || '%'
/*%end*/
order by
   	A.medical_institution_cd
/*%if limit != null && limit > 0*/
limit /*limit*/100
/*%else */
limit 100
/*%end*/
/*%if page != null && page > 0 && limit != null && limit > 0*/
offset /*page * limit*/0
/*%elseif page != null && page > 0*/
offset /*page * 100*/0
/*%end*/
;
