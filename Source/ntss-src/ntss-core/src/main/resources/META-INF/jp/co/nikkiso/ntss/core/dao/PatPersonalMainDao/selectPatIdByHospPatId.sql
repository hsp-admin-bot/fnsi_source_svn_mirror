select
  pat_id
from
	pat_personal_main
where
  is_del = '0'
and
-- mod 2021-11-12 #5896:SSI連携ができない(オーダ受け) 孫 start
-- mod #8111 コンバートデータの患者の過去のrep_dial連携の内容が出力されない 王永吉 start
--  hosp_pat_id = /*hospPatId*/'000000000001'
--  ltrim(hosp_pat_id, '0') = ltrim(/*hospPatId*/'000000000001', '0')
  hosp_pat_id = /*hospPatId*/'000000000001'
-- mod #8111 コンバートデータの患者の過去のrep_dial連携の内容が出力されない 王永吉 end
-- mod 2021-11-12 #5896:SSI連携ができない(オーダ受け) 孫 end
and
  facility_cd = /*facilityCd*/'000001'
;
