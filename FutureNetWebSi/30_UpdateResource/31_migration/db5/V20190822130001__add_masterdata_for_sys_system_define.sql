-- システム設定
DELETE FROM sys_system_define Where ctl_no = 6;
INSERT INTO sys_system_define (ctl_no, service_cd, name, value, description, is_enable, up_date) VALUES
 (6, '000', '緊急発報送信先メーリングリスト', '{"e_mail_address":"M082-all@nikkiso.co.jp"}', '緊急発報メールの送信先となるメーリングリストを設定します。顧客側に緊急発報メールが送られる場合に、設定されたメーリングリストに対して同内容のメールを送信します。', '1', current_timestamp)
;
