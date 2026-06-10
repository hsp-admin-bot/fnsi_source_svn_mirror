-- システム設定

DELETE FROM sys_system_define Where ctl_no = 18;
insert into sys_system_define values (18,'003','申込メール件名','{"mail_subject": "【FNSi機能追加申込】[申込施設名]"}','申込メール件名','1',current_timestamp);

DELETE FROM sys_system_define Where ctl_no = 19;
insert into sys_system_define values (19,'003','申込メール本文','{"mail_body": "各位\n\n[申込施設名]から以下のFNSi機能追加申込がありました。\n\n申込日：[申込日時]\n申込機能：\n[申込機能一覧]\n\n詳細な内容をFNSi申込一覧からご確認いただき\n受付済みに変更してお客様との調整をお願いいたします。\n\nよろしくお願いいたします。\n"}','申込メール本文','1',current_timestamp);

DELETE FROM sys_system_define Where ctl_no = 20;
insert into sys_system_define values (20,'003','申込キャンセルメール件名','{"mail_subject": "【FNSi機能追加申込キャンセル】[申込施設名]"}','申込キャンセルメール件名','1',current_timestamp);

DELETE FROM sys_system_define Where ctl_no = 21;
insert into sys_system_define values (21,'003','申込キャンセルメール本文','{"mail_body": "各位\n\n[申込施設名]の以下のFNSi機能追加申込がキャンセルされました。\n\n申込日：[申込日時]\n申込機能：\n[申込機能一覧]\n\nよろしくお願いいたします。\n"}','申込キャンセルメール本文','1',current_timestamp);

DELETE FROM sys_system_define Where ctl_no = 22;
insert into sys_system_define values (22,'003','完了メール件名','{"mail_subject": "【FNSi機能追加完了】[申込施設名]"}','完了メール件名','1',current_timestamp);

DELETE FROM sys_system_define Where ctl_no = 23;
insert into sys_system_define values (23,'003','完了メール本文','{"mail_body": "各位\n\n[申込施設名]の以下のFNSi機能追加が適用が完了しました。\n\n申込日：[申込日時]\n申込機能：\n[申込機能一覧]\n\nよろしくお願いいたします。\n"}','完了メール本文','1',current_timestamp);