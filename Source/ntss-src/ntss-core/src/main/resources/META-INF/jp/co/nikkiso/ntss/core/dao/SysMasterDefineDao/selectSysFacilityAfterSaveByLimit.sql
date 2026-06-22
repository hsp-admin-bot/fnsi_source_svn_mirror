select *
from (
         (
             select
                 /*%expand "A" */*
             from sys_facility A
             where 1 = 1
                 /*%if null != keyword */
               and A.facility_name LIKE '%' || /* keyword */null || '%'
                 /*%end*/
             order by A.medical_institution_cd
                 /*%if limit > 0*/
                 limit /*limit*/0
             /*%end*/
         )
         union
         (
             select
                 /*%expand "A" */*
             from sys_facility A
             where A.medical_institution_cd in /*medicalInstitutionCds*/(null)
         )
     ) as B
order by B.medical_institution_cd
;
