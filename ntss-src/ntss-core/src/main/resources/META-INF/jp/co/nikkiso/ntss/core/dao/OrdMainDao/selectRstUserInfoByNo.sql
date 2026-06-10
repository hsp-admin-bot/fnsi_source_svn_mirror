select
  rst_puncture_user_info ->> 'date' as puncture_date,
  rst_puncture_user_info ->> 'user_id_1' as puser_id1,
  (rst_puncture_user_info ->> 'user_last_name_1') || ' ' || (rst_puncture_user_info ->> 'user_first_name_1') as  puser_name1,
  rst_puncture_user_info ->> 'date_1' as puser_date1,
  rst_puncture_user_info ->> 'user_id_2' as puser_id2,
  (rst_puncture_user_info ->> 'user_last_name_2') || ' ' || (rst_puncture_user_info ->> 'user_first_name_2') as puser_name2,
  rst_puncture_user_info ->> 'date_2' as puser_date2,
  rst_return_user_info ->> 'date' as return_date,
  rst_return_user_info ->> 'user_id_1' as ruser_id1,
  (rst_return_user_info ->> 'user_last_name_1') || ' ' || (rst_return_user_info ->> 'user_first_name_1') as ruser_name1,
  rst_return_user_info ->> 'date_1' as ruser_date1,
  rst_return_user_info ->> 'user_id_2' as ruser_id2,
  (rst_return_user_info ->> 'user_last_name_2') || ' ' || (rst_return_user_info ->> 'user_first_name_2') as ruser_name2,
  rst_return_user_info ->> 'date_2' as ruser_date2,
  rst_charge_user_info ->> 'user_id_1' as cuser_id1,
  (rst_charge_user_info ->> 'user_last_name_1') || ' ' || (rst_charge_user_info ->> 'user_first_name_1') as cuser_name1,
  rst_charge_user_info ->> 'date_1' as cuser_date1,
  rst_charge_user_info ->> 'user_id_2' as cuser_id2,
  (rst_charge_user_info ->> 'user_last_name_2') || ' ' || (rst_charge_user_info ->> 'user_first_name_2') as cuser_name2,
  -- #11827 2025.05.15 mod 必要な項目を追加 TDC米沢 start
  --rst_charge_user_info ->> 'date_2' as cuser_date2
  rst_charge_user_info ->> 'date_2' as cuser_date2,
  facility_cd,
  rst_puncture_user_info ->> 'user_last_name_1' as puser_last_name1,
  rst_puncture_user_info ->> 'user_first_name_1' as puser_first_name1,
  rst_puncture_user_info ->> 'user_last_name_2' as puser_last_name2,
  rst_puncture_user_info ->> 'user_first_name_2' as puser_first_name2,
  rst_return_user_info ->> 'user_last_name_1' as ruser_last_name1,
  rst_return_user_info ->> 'user_first_name_1' as ruser_first_name1,
  rst_return_user_info ->> 'user_last_name_2' as ruser_last_name2,
  rst_return_user_info ->> 'user_first_name_2' as ruser_first_name2,
  rst_charge_user_info ->> 'user_last_name_1' as cuser_last_name1,
  rst_charge_user_info ->> 'user_first_name_1' as cuser_first_name1,
  rst_charge_user_info ->> 'user_last_name_2' as cuser_last_name2,
  rst_charge_user_info ->> 'user_first_name_2' as cuser_first_name2
  -- #11827 2025.05.15 mod 必要な項目を追加 TDC米沢 end
from
  ord_main
where
  ord_no = /*ordNo*/1
;
