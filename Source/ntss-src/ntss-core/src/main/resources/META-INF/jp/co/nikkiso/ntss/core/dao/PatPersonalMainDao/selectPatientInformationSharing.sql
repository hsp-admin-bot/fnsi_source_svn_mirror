SELECT
    pat_id,
    pat_sex,
    hosp_pat_id,
    pat_birthday,
    facility_cd,
    pat_blood_type_abo,
    pat_blood_type_rh,
    in_out_class as in_out_class,
    pat_blood_type_serovar,
    personal_info_decrypt(pat_last_name)             as pat_last_name,
    personal_info_decrypt(pat_first_name)            as pat_first_name,
    personal_info_decrypt(pat_last_name) as pat_last_name,
    personal_info_decrypt(pat_first_name) as pat_first_name,
    personal_info_decrypt(pat_last_name_kana) as pat_last_name_kana,
    personal_info_decrypt(pat_first_name_kana) as pat_first_name_kana,
    personal_info_decrypt(pat_last_name_alpha) as pat_last_name_alpha,
    personal_info_decrypt(pat_first_name_alpha) as pat_first_name_alpha,
    personal_info_decrypt(pat_birth_name) as pat_birth_name,
    personal_info_decrypt(pat_birth_name_kana) as pat_birth_name_kana,
    personal_info_decrypt(pat_birth_name_alpha) as pat_birth_name_alpha,
    personal_info_decrypt_jsonb(pat_contact_info) as pat_contact_info
FROM pat_personal_main
WHERE is_del = '0'

    /*%if patInsuranceConditionsSharing.patIdList != null && !patInsuranceConditionsSharing.patIdList.isEmpty() */
    AND pat_id IN /* patInsuranceConditionsSharing.patIdList */(null)
    /*%end*/

    /*%if patInsuranceConditionsSharing.excludePatIdList != null && !patInsuranceConditionsSharing.excludePatIdList.isEmpty() */
    AND pat_id NOT IN /* patInsuranceConditionsSharing.excludePatIdList */(null)
    /*%end*/

    /*%if patInsuranceConditionsSharing.patBloodTypeAbo != null */
    AND pat_blood_type_abo = /* patInsuranceConditionsSharing.patBloodTypeAbo */1
    /*%end*/
    /*%if patInsuranceConditionsSharing.patBloodTypeRh != null */
    AND pat_blood_type_rh = /* patInsuranceConditionsSharing.patBloodTypeRh */1
    /*%end*/
    /*%if patInsuranceConditionsSharing.patBloodTypeSerovar != null */
    AND pat_blood_type_serovar = /* patInsuranceConditionsSharing.patBloodTypeSerovar */1
    /*%end*/
    /*%if patInsuranceConditionsSharing.gender != null */
    AND pat_sex = /* patInsuranceConditionsSharing.gender */1
    /*%end*/
    /*%if patInsuranceConditionsSharing.startBirthDate != null
       && patInsuranceConditionsSharing.startBirthDate != "" */
    AND pat_birthday >= /* patInsuranceConditionsSharing.startBirthDate */'19500101'
    /*%end*/

    /*%if patInsuranceConditionsSharing.endBirthDate != null
       && patInsuranceConditionsSharing.endBirthDate != "" */
    AND pat_birthday <= /* patInsuranceConditionsSharing.endBirthDate */'20001231'
    /*%end*/


    /*%if patInsuranceConditionsSharing.facilityCd != null */
     and facility_cd = /* patInsuranceConditionsSharing.facilityCd */'99999'
    /*%end*/

--- 名前・カナ(部分一致)
/*%if patInsuranceConditionsSharing.patName != null && !patInsuranceConditionsSharing.patName.isEmpty() */
  and (
    personal_info_decrypt(pat_last_name) || personal_info_decrypt(pat_first_name) like /* @infix(patInsuranceConditionsSharing.patName) */null
    or
    coalesce(personal_info_decrypt(pat_last_name_kana), '') || coalesce(personal_info_decrypt(pat_first_name_kana), '') like /* @infix(patInsuranceConditionsSharing.patName) */null
    or
    coalesce(personal_info_decrypt(pat_last_name_alpha), '') || coalesce(personal_info_decrypt(pat_first_name_alpha), '') like /* @infix(patInsuranceConditionsSharing.patName) */null
    or
    hosp_pat_id like /* @infix(patInsuranceConditionsSharing.patName) */null
  )
/*%end*/
ORDER BY
  personal_info_decrypt(pat_last_name),
  personal_info_decrypt(pat_first_name)
