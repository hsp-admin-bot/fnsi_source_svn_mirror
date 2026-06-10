update mnt_machine_state
set
  ord_no = next_ord_no, -- 装置に条件送信された時点で、実績展開成功を待たずに治療対象を登録する
  pat_id = next_patid, -- 装置に条件送信された時点で、実績展開成功を待たずに治療対象を登録する
  machine_status = /*param.machineStatus*/0,
  cond_send_date = /*param.condSendDate*/'1970/01/01 00:00:00',
  up_date = /*param.upDate*/'1970/01/01 00:00:00'
where
  facility_cd = /*param.facilityCd*/'1' and
  machine_type_cd = /*param.machineTypeCd*/'1' and
  machine_serial = trim(/*param.machineSerial*/'1')
  ;
