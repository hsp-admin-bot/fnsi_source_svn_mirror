--add #7859 透析レポートの出力に失敗する場合がある(500エラー） 20220803 zhaoqi start
INSERT INTO mni_monitor (facility_cd, machine_type_cd, machine_serial, ord_no, pat_id, data_type,
                         monitor_data, is_del, occur_date, reg_date, up_date, upd_staff_id)
select facility_cd,
       machine_type_cd,
       machine_serial,
       /*ordNoNew*/0,
       pat_id,
       data_type,
       monitor_data,
       is_del,
       occur_date,
       reg_date,
       up_date,
       upd_staff_id
from mni_monitor
where ord_no = /*ordNoOld*/0;
--add #7859 透析レポートの出力に失敗する場合がある(500エラー） 20220803 zhaoqi end
