-- ホスト報知通知定義を追加
delete from sys_notification where notification_no in (17,18,19,20);

insert into sys_notification (notification_no, notification_category, setting_name, message, additional_info, disp_order, available_keys, is_disp, is_del, reg_date, up_date, help) values ('17', '20', 'ホスト報知', '[BEDNAME]：[LASTNAME] [FIRSTNAME]さん が[CONTENTS]。', '{"FUNC": "006", "PATID": "[PATID]", "FACILITYCD": "[FACILITYCD]", "ORDNO": "[ORDNO]"}', '16', '[BEDNAME]：ベッド名、
[LASTNAME]：患者名(姓)、
[FIRSTNAME]：患者名(名)、
[CONTENTS]：通知内容、
[PATID]：内部患者ID、
[FACILITYCD]：施設コード、
[ORDNO]：オーダ番号', '1', '0', current_timestamp, current_timestamp, '治療中患者のホスト報知が発生すると通知します。');

insert into sys_notification (notification_no, notification_category, setting_name, message, additional_info, disp_order, available_keys, is_disp, is_del, reg_date, up_date, help) values ('18', '20', '条件送信失敗通知', '[BEDNAME]：[LASTNAME] [FIRSTNAME]さん の条件送信に失敗しました。', '{"FUNC": "014", "PATID": "[PATID]", "FACILITYCD": "[FACILITYCD]"}', '17', '[BEDNAME]：ベッド名、
[LASTNAME]：患者名(姓)、
[FIRSTNAME]：患者名(名)、
[PATID]：内部患者ID、
[FACILITYCD]：施設コード', '1', '0', current_timestamp, current_timestamp, '患者の条件送信に失敗すると通知します。');

insert into sys_notification (notification_no, notification_category, setting_name, message, additional_info, disp_order, available_keys, is_disp, is_del, reg_date, up_date, help) values ('19', '20', '投薬タイミング通知', '[BEDNAME]：[LASTNAME] [FIRSTNAME]さん に [MEDICINENAME] を投与する時間になりました。', '{"FUNC": "006", "PATID": "[PATID]", "FACILITYCD": "[FACILITYCD]", "ORDNO": "[ORDNO]"}', '18', '[BEDNAME]：ベッド名、
[LASTNAME]：患者名(姓)、
[FIRSTNAME]：患者名(名)、
[MEDICINENAME]：薬剤/調整薬剤名
[PATID]：内部患者ID、
[FACILITYCD]：施設コード、
[ORDNO]：オーダ番号', '1', '0', current_timestamp, current_timestamp, '治療中患者の投薬タイミングで通知します。');

insert into sys_notification (notification_no, notification_category, setting_name, message, additional_info, disp_order, available_keys, is_disp, is_del, reg_date, up_date, help) values ('20', '20', '？？？？患者発生通知', '[BEDNAME]で？？？？患者治療が開始されました。', '{"FUNC": "011", "FACILITYCD": "[FACILITYCD]"}', '19', '[BEDNAME]：ベッド名、
[FACILITYCD]：施設コード', '1', '0', current_timestamp, current_timestamp, '？？？？患者が発生すると通知します。');
