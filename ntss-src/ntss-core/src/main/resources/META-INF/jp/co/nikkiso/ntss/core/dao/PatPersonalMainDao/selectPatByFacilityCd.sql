select
	pat_id,
	hosp_pat_id,
	personal_info_decrypt(pat_last_name) as pat_last_name,
	personal_info_decrypt(pat_first_name) as pat_first_name,
	personal_info_decrypt(pat_last_name_kana) as pat_last_name_kana,
	personal_info_decrypt(pat_first_name_kana) as pat_first_name_kana,	
	in_out_class
from
	pat_personal_main
where
	is_del = '0'
	and facility_cd in /* facilityCdList */(null)

	-- add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応  --start
    /*%if 0 != patIds.size()*/
    and pat_id in /* patIds */(null)
    /*%end*/
    -- add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応  --end

order by
	lpad(hosp_pat_id, 12, '0'), hosp_pat_id desc
;
