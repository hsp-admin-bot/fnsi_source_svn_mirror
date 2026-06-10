select
    A.facility_cd
     ,A.prefectures_cd as pref_cd
     ,A.medical_institution_cd
     ,A.facility_name
     ,A.facility_short_name
     ,A.address
     ,A.phone_no1 as phone_no
     ,A.fax_no1 as fax_no
     ,B.pref_name
from
    sys_facility A   --テーブル名
        left join sys_prefectures B
                  on A.prefectures_cd = B.pref_cd
WHERE (A.is_disp = '1' or A.is_disp is null)
    and A.is_del = '0'
/*%if selectedInsCdList.size() != 0 */
    and A.medical_institution_cd not in /*selectedInsCdList*/(1)
/*%end*/
/*%if "" != prefCd && null != prefCd*/
    and A.prefectures_cd = /*prefCd*/null
/*%end*/
/*%if "" != freeWord && null != freeWord*/
    and (UPPER(A.facility_name) LIKE '%' || UPPER(/* freeWord */null) || '%'
        or UPPER(A.address) LIKE '%' || UPPER(/* freeWord */null) || '%'
        or UPPER(A.phone_no1) LIKE '%' || UPPER(/* freeWord */null) || '%'
        or UPPER(A.fax_no1) LIKE '%' || UPPER(/* freeWord */null) || '%'
        or UPPER(B.pref_name) LIKE '%' || UPPER(/* freeWord */null) || '%')
/*%end*/
order by
    A.medical_institution_cd
    limit /*limit*/0
    offset /*offsetIer*/0
;
-- add by ztc 2023-03-01 [Optimize runtime No.8372]  /
