select pat_id,
personal_info_decrypt(pat_last_name) as pat_last_name,
personal_info_decrypt(pat_first_name) as pat_first_name,
personal_info_decrypt(pat_last_name_kana) as pat_last_name_kana,
personal_info_decrypt(pat_first_name_kana) as pat_first_name_kana,
hosp_pat_id
from pat_personal_main
where pat_id in /*patIdList*/(0);