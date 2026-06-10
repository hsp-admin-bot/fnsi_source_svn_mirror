SELECT DISTINCT patient_id, facility_cd
FROM (
SELECT
    COALESCE(from_pat_id, to_pat_id) AS patient_id,
    CASE
        WHEN from_pat_id IS NOT NULL THEN from_facility_cd
        ELSE to_facility_cd
    END AS facility_cd
FROM shr_pat_info
  WHERE is_del = '0'
    AND is_disp = '1'

       AND (
        share_direction = '1'
        OR (
            is_pat_consent<> '9'
            AND is_to_consent <> '9'
        )
        	 OR from_pat_id IS NOT NULL
      )
    /*%if patInsuranceConditionsSharing.getFromFacilityCd() != null
        && !patInsuranceConditionsSharing.getFromFacilityCd().isEmpty()
        && (patInsuranceConditionsSharing.getToFacilityCd() == null
            || patInsuranceConditionsSharing.getToFacilityCd().isEmpty()) */
      AND 1 = 0
    /*%end*/

    /*%if !(patInsuranceConditionsSharing.getFromFacilityCd() != null
           && !patInsuranceConditionsSharing.getFromFacilityCd().isEmpty()
           && (patInsuranceConditionsSharing.getToFacilityCd() == null
               || patInsuranceConditionsSharing.getToFacilityCd().isEmpty())) */
      AND from_facility_cd = /*patInsuranceConditionsSharing.getFacilityCd()*/''
    /*%end*/

    /*%if patInsuranceConditionsSharing.getToFacilityCd() != null
        && !patInsuranceConditionsSharing.getToFacilityCd().isEmpty() */
      AND to_facility_cd = /*patInsuranceConditionsSharing.getToFacilityCd()*/''
    /*%end*/

  UNION ALL

  SELECT to_pat_id AS patient_id,from_facility_cd AS facility_cd
  FROM shr_pat_info
  WHERE is_del = '0'
   AND is_disp = '1'
   AND (
        share_direction = '2'
        OR (
            is_pat_consent <> '9'
            AND is_from_consent <> '9'
        )
        OR to_pat_id IS NOT NULL
      )

       /*%if patInsuranceConditionsSharing.getToFacilityCd() != null
           && !patInsuranceConditionsSharing.getToFacilityCd().isEmpty()
           && (patInsuranceConditionsSharing.getFromFacilityCd() == null
               || patInsuranceConditionsSharing.getFromFacilityCd().isEmpty()) */
         AND 1 = 0
       /*%end*/


    /*%if !(patInsuranceConditionsSharing.getToFacilityCd() != null
           && !patInsuranceConditionsSharing.getToFacilityCd().isEmpty()
           && (patInsuranceConditionsSharing.getFromFacilityCd() == null
               || patInsuranceConditionsSharing.getFromFacilityCd().isEmpty())) */

   AND to_facility_cd = /*patInsuranceConditionsSharing.getFacilityCd() */''
       /*%end*/

    /*%if patInsuranceConditionsSharing.getFromFacilityCd() != null && !patInsuranceConditionsSharing.getFromFacilityCd().isEmpty() */
    AND from_facility_cd = /*patInsuranceConditionsSharing.getFromFacilityCd()*/''
     /*%end*/
  UNION ALL

    SELECT from_pat_id AS patient_id,from_facility_cd AS facility_cd
    FROM shr_pat_info
    WHERE is_del = '0'
      AND is_disp = '1'
      AND is_pat_consent <> '9'
      AND is_from_consent <> '9'
       /*%if patInsuranceConditionsSharing.getToFacilityCd() != null
           && !patInsuranceConditionsSharing.getToFacilityCd().isEmpty()
           && (patInsuranceConditionsSharing.getFromFacilityCd() == null
               || patInsuranceConditionsSharing.getFromFacilityCd().isEmpty()) */
         AND 1 = 0
       /*%end*/


    /*%if !(patInsuranceConditionsSharing.getToFacilityCd() != null
           && !patInsuranceConditionsSharing.getToFacilityCd().isEmpty()
           && (patInsuranceConditionsSharing.getFromFacilityCd() == null
               || patInsuranceConditionsSharing.getFromFacilityCd().isEmpty())) */

   AND to_facility_cd = /*patInsuranceConditionsSharing.getFacilityCd() */''
       /*%end*/

    /*%if patInsuranceConditionsSharing.getFromFacilityCd() != null && !patInsuranceConditionsSharing.getFromFacilityCd().isEmpty() */
    AND from_facility_cd = /*patInsuranceConditionsSharing.getFromFacilityCd()*/''
     /*%end*/
      AND to_pat_id is null
) all_patients
WHERE patient_id IS NOT NULL
ORDER BY patient_id;

