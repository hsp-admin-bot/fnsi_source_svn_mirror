select
  machine_record_cd
from
 mnt_motion_record
where
  data_type = 1
and
  facility_cd = /* facilityCd */null
and
  machine_type_cd = /*machineTypeCd*/null
and
  machine_serial = /*machineSerial*/null
and
      --mod #10063 by zhangruixue 2023-11-17  rollback 7192--start
-- mod FNSI redmine 7192 共通プロトコルV4の自己診断結果が正しく登録されない 劉祥霖 start
(machine_record_cd = 'G100' or machine_record_cd = 'G101' or machine_record_cd = 'G102')
--   (machine_record_cd = '- ' or machine_record_cd = '-   ' or machine_record_cd = '-  ')
-- mod FNSI redmine 7192 共通プロトコルV4の自己診断結果が正しく登録されない 劉祥霖 end
--mod #10063 by zhangruixue 2023-11-17  rollback 7192--end
order by
  motion_record_no desc LIMIT 1
;
