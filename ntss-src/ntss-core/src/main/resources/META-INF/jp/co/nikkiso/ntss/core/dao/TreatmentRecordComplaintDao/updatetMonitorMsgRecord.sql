   update mnt_motion_record
      set report_disp_flg = /*mntMonitorMsgRecord.reportDispFlg*/1
         ,up_date = /*mntMonitorMsgRecord.upDate*/''
    where motion_record_no = /*mntMonitorMsgRecord.motionRecordNo*/0
