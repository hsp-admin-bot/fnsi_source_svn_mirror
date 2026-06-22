DELETE FROM pat_personal_main;

INSERT INTO pat_personal_main(pat_id, hosp_pat_id, facility_cd, pat_last_name, pat_first_name, is_del)
  VALUES(10, '100010002000', 'TK2019',
  personal_info_encrypt('aaa'),
  personal_info_encrypt('zzz'),
  '0');
