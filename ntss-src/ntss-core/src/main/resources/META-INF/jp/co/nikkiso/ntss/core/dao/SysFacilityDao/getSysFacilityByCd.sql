select
  /*%expand "A" */*
from
  sys_facility A
where
  /*%if medicalInstitutionCds != null*/
   A.medical_institution_cd = /*medicalInstitutionCds*/null
  /*%end*/
;
