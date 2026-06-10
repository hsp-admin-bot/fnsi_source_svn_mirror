-- レコード削除
DELETE FROM sys_system_define WHERE ctl_no = 1;
-- レコード挿入
INSERT INTO sys_system_define (ctl_no, service_cd, name, value, description, is_enable, up_date) VALUES (1,'000','緊急発報用デフォルトメールテンプレート','{"mail_template": "[緊急発報_共通テンプレート]\n　異常が発生しています。\n　確認して下さい", "mail_alive_template": "各位 \n\n装置からの警報発生を以下の通り連絡致します。\n\n■施設名：[施設名]\n■装置名：[装置名]\n■発生日時：[発生日時]\n■型式：[型式]\n■製造番号：[製造番号]\n■装置記録メッセージ：[装置記録メッセージ] \n\n■発報対象者名：[発報対象者名] \n\n[URL]\n\nサービスダイレクトコール\n固定電話からの場合：0120-444-278\n携帯電話・PHSからの場合：03-4520-5297\n"}','緊急発報用デフォルトメールテンプレート','1', now());
