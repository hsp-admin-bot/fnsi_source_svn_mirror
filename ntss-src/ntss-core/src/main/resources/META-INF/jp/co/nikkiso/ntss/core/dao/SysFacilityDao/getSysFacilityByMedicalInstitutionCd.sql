select
    /*%expand "A" */*
from
    sys_facility A
where
  -- modify by chamaojia 2025-05-26 [11871] --start  
  -- The main purpose is to translate names without the condition of 【is_disp】  
--         A.is_disp = '1'
--   and medical_institution_cd in /* medicalInstitutionCds */(null)
    medical_institution_cd in /* medicalInstitutionCds */(null)
  -- modify by chamaojia 2025-05-26 [11871] --end  
;
