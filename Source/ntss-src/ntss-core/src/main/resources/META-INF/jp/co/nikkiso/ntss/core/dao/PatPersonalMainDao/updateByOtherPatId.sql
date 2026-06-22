UPDATE pat_personal_main A SET 
(
	pat_last_name_kana,
    pat_first_name_kana,
    pat_last_name_alpha,
    pat_first_name_alpha,
    pat_birth_name,
    pat_birth_name_kana,
    pat_birth_name_alpha,
    pat_birthday,
    pat_sex,
    nationality,
    pat_blood_type_abo,
    pat_blood_type_rh,
    pat_blood_type_serovar,
    in_out_class,
    transport_cd,
    pat_contact_info
) = (SELECT 
	 pat_last_name_kana,
    pat_first_name_kana,
    pat_last_name_alpha,
    pat_first_name_alpha,
    pat_birth_name,
    pat_birth_name_kana,
    pat_birth_name_alpha,
    pat_birthday,
    pat_sex,
    nationality,
    pat_blood_type_abo,
    pat_blood_type_rh,
    pat_blood_type_serovar,
    in_out_class,
    transport_cd,
    pat_contact_info
     FROM pat_personal_main B
     WHERE B.pat_id = /*patIdSrc*/0)
	 
where A.pat_id = /*patIdDst*/0