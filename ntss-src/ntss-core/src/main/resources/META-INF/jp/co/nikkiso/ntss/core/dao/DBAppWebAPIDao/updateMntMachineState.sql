update mnt_machine_state set
--- facility_cd=/*facility_cd*/, --- 施設コード
--- machine_type_cd=/*machine_type_cd*/, --- 型式コード
--- machine_serial=/*machine_serial*/, --- 製造番号
--- model=/*model*/, --- 機種
--- machine_name=/*machine_name*/, --- 装置名
--- bed_cd=/*bed_cd*/, --- ベッドコード
--- bed_name=/*bed_name*/, --- ベッド名
--- process_state=/*process_state*/, --- 工程状態
--- m_notice_cnt=/*m_notice_cnt*/, --- 緊急発報件数
--- preventive_mainte_cnt=/*preventive_mainte_cnt*/, --- 予防保守件数
--- is_preventive_mainte=/*is_preventive_mainte*/, --- 通信不良有無
--- use_time=/*use_time*/, --- 部品運転時間
--- machine_status=/*machine_status*/, --- 装置ステータス
--- alarm_moni=/*alarm_moni*/, --- 警報監視状態
is_offline=/*mntMachineState.isOffline*/'', --- オフラインフラグ
ord_no=/*mntMachineState.ordNo*/0, --- システムで管理する一意なオーダ番号
--- next_ord_no=/*next_ord_no*/, --- 次回透析オーダ番号
pat_id=/*mntMachineState.patId*/0, --- システムで管理する一意な患者ID
--- next_patid=/*next_patid*/, --- 次患者ID
--- next_kur_cd=/*next_kur_cd*/, --- 次患者クールCD
--- start_plan_date=/*start_plan_date*/, --- 透析開始予定日時
--- end_plan_date=/*end_plan_date*/, --- 透析終了予定日時
--- weigh_before_date=/*weigh_before_date*/, --- 前体重測定日時
--- cond_send=/*cond_send*/, --- 条件送信データ
/*%if mntMachineState.condSendDate != null */  --nullの時は何もしない
cond_send_date=/*mntMachineState.condSendDate*/'', --- 条件送信日時
/*%end*/
cond_set_date=/*mntMachineState.condSetDate*/'', --- 条件確認日時
start_date=/*mntMachineState.startDate*/'', --- 透析開始日時
end_date=/*mntMachineState.endDate*/'', --- 透析終了日時
weigh_after_date=/*mntMachineState.weighAfterDate*/'', --- 後体重測定日時
--- alarm_list=/*alarm_list*/, --- 警報、注意発生中リスト
--- reg_date=/*reg_date*/, --- 登録日時
  up_date = transaction_timestamp() --- 更新日時
where
  facility_cd=/*mntMachineState.facilityCd*/'' --- 施設コード
  and
  machine_type_cd=/*mntMachineState.machineTypeCd*/'' --- 型式コード
  and
  machine_serial=/*mntMachineState.machineSerial*/'' --- 製造番号
