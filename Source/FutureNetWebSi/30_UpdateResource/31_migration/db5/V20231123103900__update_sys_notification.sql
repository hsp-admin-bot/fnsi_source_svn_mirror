DELETE FROM sys_notification WHERE notification_no = 37;

INSERT INTO "ntss"."sys_notification" VALUES (37, 100, '帳票印刷失敗通知', '帳票印刷が失敗しました。ご確認ください。
【帳票種別】[REPORTTYPE]
【帳票名】[REPORTNAME]
【失敗日時】[UP_DATE]', '{"FUNC": "019"}', 23, '[REPORTTYPE]：帳票区分、[REPORTNAME]：帳票名、[UP_DATE]：リリース時間、[NOTIFICATIONNO]：ベッド名、[FACILITYCD]：施設コード', '1', '0', '2021-04-23 09:59:17.356', CURRENT_TIMESTAMP, '帳票の印刷失敗を通知します。');
