INSERT INTO pat_personal_main
(pat_id, fn_pat_id, hosp_pat_id, nkk_pat_id, facility_cd, pat_last_name, pat_first_name, pat_last_name_kana, pat_first_name_kana, pat_last_name_alpha, pat_first_name_alpha, pat_birth_name, pat_birth_name_kana, pat_birth_name_alpha, pat_birthday, pat_sex, nationality, pat_blood_type_abo, pat_blood_type_rh, pat_blood_type_serovar, in_out_class, is_die, die_cd, die_date, dial_diff_com_info, severity_cd, transport_cd, pat_contact_info, other_contact_info, vendor_contact_info, insurance_info, is_del, up_date, reg_date)
VALUES(8, NULL, '000000000008', NULL, '009999', 'c9715bcb6d17', 'c9730bc97703cb4957', 'c70715c70557c70571c7073d', 'c7055fc70717c70555', NULL, NULL, NULL, NULL, NULL, '19761225', 1, NULL, 3, 1, 0, NULL, '0', NULL, NULL, '[]', NULL, NULL, '{"fax": null, "tel1": null, "tel2": null, "memo1": null, "memo2": null, "e_mail": null, "zip_cd": null, "address": null, "work_tel": null, "work_name": null, "work_address": null}', '[]', '[]', '[]', '0', '2019-04-15 10:51:37.006', '2019-04-15 10:51:39.000')
;


SELECT setval('pat_personal_main_pat_id_seq', 8, true);
