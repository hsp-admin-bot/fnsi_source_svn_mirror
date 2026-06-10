  select
        A.master_cd as master_cd
        ,A.facility_cd as facility_cd
        ,A.favorite_facility_cd as favorite_facility_cd 
        ,A.medical_institution_cd
        ,B.facility_name as favorite_facility_name
        ,B.prefectures_cd as pref_cd
        ,C.pref_name as pref_name
        ,B.address as address
        ,B.phone_no1 as phone_no
        ,B.fax_no1 as fax_no
        ,A.is_disp as is_disp
        ,A.is_del as is_fav_del
        ,B.is_del as is_sys_del
  from 
        mst_favorite_facility A 
        inner join sys_facility B  
         on( A.favorite_facility_cd = B.facility_cd) or (A.favorite_facility_cd is null and A.medical_institution_cd= B.medical_institution_cd)
         left join sys_prefectures C
         on B.prefectures_cd = C.pref_cd
  where 
        A.is_disp = '1' 
        and B.is_disp = '1' 
        /*%if facilityCd != null */  
        and A.facility_cd = /* facilityCd*/'0'
        /*%end */
;
