-- add 9583 by kangjie start
update sys_notification
set additional_info = '{"FUNC": "031", "ORDNO": "[ORDNO]", "CTLNO": "[CTLNO]","TARGET_DATE": "[TARGET_DATE]","COOP_CD": "[COOP_CD]"}',
    message =  '正しく連携されなかった情報があります。ご確認ください。
【患者番号】[HOSP_PAT_ID]
【患者名前】[LASTNAME] [FIRSTNAME]
【連携種別】[COOP_NAME]
【対象日】[TARGET_DATE]'
where notification_no = 28;

UPDATE sys_notification
set is_del = '1',is_disp = '0' where notification_no in (2,21,24);

update sys_notification
set additional_info = '{"FUNC": "007", "PATID": "[PATID]", "FACILITYCD": "[FACILITYCD]"}'
where notification_no = 22;
-- add 9583 by kangjie end
