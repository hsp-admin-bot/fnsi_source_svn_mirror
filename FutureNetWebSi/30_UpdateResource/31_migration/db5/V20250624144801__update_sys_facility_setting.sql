-- #11747 【因島：改良】治療状況マップのインジケータの表示
-- 表示順の変更
UPDATE sys_facility_setting SET disp_order = '141', up_date = now() WHERE facility_setting_no = '1071'; -- 治療状況
UPDATE sys_facility_setting SET disp_order = '142', up_date = now() WHERE facility_setting_no = '1072'; -- スケジュール
