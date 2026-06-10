DELETE FROM pat_treatment_pattern
WHERE facility_cd = /*facilityCd*/''
  AND pat_id = /*patId*/0
  /*%if null != indTreatmentCds && indTreatmentCds.size() > 0*/
   AND ind_treatment_cd IN /*indTreatmentCds*/(0)
  /*%end*/
  /*%if indKurCds != null && !indKurCds.isEmpty() */
   AND ind_kur_cd IN /* indKurCds */(0)
  /*%end*/
  AND treat_week IN /*treatWeeks*/(0)
RETURNING *;
