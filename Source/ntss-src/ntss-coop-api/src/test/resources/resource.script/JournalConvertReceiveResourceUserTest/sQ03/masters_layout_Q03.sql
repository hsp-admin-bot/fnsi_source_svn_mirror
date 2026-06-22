DELETE FROM mst_coop_layout
WHERE ctl_no BETWEEN 3300000 AND 3399999;

INSERT INTO mst_coop_layout (
  ctl_no
  , facility_cd
  , coop_cd
  , coop_cd_index
  , direction
  , coop_cd_sub
  , coop_format
  , coop_name
  , coop_vender
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
) VALUES (
3300000,
'F_hQ03',
'user_test',
'',
'R',
'pre',
'csv',
'サンプル1',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="ユーザ情報連携" multi="true:CRLF">
  <item name="処理区分" key="shori_kbn" />

  <!-- mst_personal_user -->
  <item name="利用者種別" col="mst_personal_user.user_type" />

  <item name="利用者名_姓" col="mst_personal_user.user_last_name" />
  <item name="利用者名_名" col="mst_personal_user.user_first_name" />

  <item name="利用者カナ名_姓" col="mst_personal_user.user_last_name_kana" />
  <item name="利用者カナ名_名" col="mst_personal_user.user_first_name_kana" />

  <item name="利用者英字名_姓" col="mst_personal_user.user_last_name_alpha" />
  <item name="利用者英字名_名" col="mst_personal_user.user_first_name_alpha" />

  <item name="メールアドレス1" col="mst_personal_user.user_email_address_1" />
  <item name="メールアドレス2" col="mst_personal_user.user_email_address_2" />

  <item name="内線番号" col="mst_personal_user.extension_no" />
  <item name="自宅番号" col="mst_personal_user.home_no" />
  <item name="携帯番号" col="mst_personal_user.mobile_phone_no" />
  <item name="FAX番号" col="mst_personal_user.fax_no" />

  <item name="郵便番号3" col="mst_personal_user.zipcd_3" />
  <item name="郵便番号4" col="mst_personal_user.zipcd_4" />

  <item name="自宅住所" col="mst_personal_user.address" />
  <item name="自宅住所かな" col="mst_personal_user.address_kana" />

  <item name="職種コード" col="mst_personal_user.job_cd" />

  <item name="管理者フラグ" col="mst_personal_user.administrator" />

  <item name="表示フラグ" col="mst_personal_user.is_disp" />
  <item name="削除フラグ" col="mst_personal_user.is_del" />

  <item name="院内コード1" col="mst_personal_user.in_hospital_cd_1" />
  <item name="院内コード2" col="mst_personal_user.in_hospital_cd_2" />
  <item name="管理者への表示許可" col="mst_personal_user.info_disp_to_admin" />
  <item name="麻薬施用者免許証番号" col="mst_personal_user.anesthesiologist_license_no" />

  <!-- mst_user_authentication -->
  <item name="表示用利用者ID" col="mst_user_authentication.disp_user_id" />
  <item name="パスワード" col="mst_user_authentication.user_password" />
  <item name="サインイン失敗回数" col="mst_user_authentication.failure_cnt" />

  <!-- mst_user -->
  <item name="ユーザー設定" col="mst_user.user_settings.is_disp_menu" />
  <item name="ユーザー設定" col="mst_user.user_settings.font_size" />
  <item name="ユーザー設定" col="mst_user.user_settings.theme" />
  <item name="ユーザー設定" col="mst_user.user_settings.is_split_frame" />

  <item name="仮登録フラグ" col="mst_user.is_provisional" />
  <item name="表示フラグ" col="mst_user.is_disp" />
  <item name="削除フラグ" col="mst_user.is_del" />
  <item name="システムで管理する一意な患者ID" col="mst_user.pat_id" />
  <item name="テンプレートログ" col="mst_user.tmp_log_search_condition.idFilter" />
  <item name="テンプレートログ" col="mst_user.tmp_log_search_condition.nameFilter" />
  <item name="テンプレートログ" col="mst_user.tmp_log_search_condition.condition" />
  <item name="秘密鍵" col="mst_user.secret_key" />
  <item name="秘密キーフラグ" col="mst_user.is_set_qr_code" />
  <item name="アクセスカード番号" col="mst_user.card_idm" />
  <item name="個人情報取扱い同意フラグ" col="mst_user.is_consent" />
  <item name="個人情報取扱い同意日時" col="mst_user.consent_date" />
</root>
'),
('{"key": {"shori_kbn": {"01":"cre", "02":"upd", "03":"del"}}, ' ||
'"csv": {"delim": {"item": ","}}}')::jsonb,
'1',
'0',
12345,
'20191118',
'20191118'
);

INSERT INTO mst_coop_layout (
  ctl_no
  , facility_cd
  , coop_cd
  , coop_cd_index
  , direction
  , coop_cd_sub
  , coop_format
  , coop_name
  , coop_vender
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
) VALUES (
3300001,
'F_hQ03',
'user_test',
'',
'R',
'cre',
'csv',
'サンプル1',
'TEX-SOL',
'動作確認用(cre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="ユーザ情報連携">
  <item name="処理区分" />

  <!-- mst_personal_user -->
  <item name="利用者種別" col="mst_personal_user.user_type" />

  <item name="利用者名_姓" col="mst_personal_user.user_last_name" />
  <item name="利用者名_名" col="mst_personal_user.user_first_name" />

  <item name="利用者カナ名_姓" col="mst_personal_user.user_last_name_kana" />
  <item name="利用者カナ名_名" col="mst_personal_user.user_first_name_kana" />

  <item name="利用者英字名_姓" col="mst_personal_user.user_last_name_alpha" />
  <item name="利用者英字名_名" col="mst_personal_user.user_first_name_alpha" />

  <item name="メールアドレス1" col="mst_personal_user.user_email_address_1" />
  <item name="メールアドレス2" col="mst_personal_user.user_email_address_2" />

  <item name="内線番号" col="mst_personal_user.extension_no" />
  <item name="自宅番号" col="mst_personal_user.home_no" />
  <item name="携帯番号" col="mst_personal_user.mobile_phone_no" />
  <item name="FAX番号" col="mst_personal_user.fax_no" />

  <item name="郵便番号3" col="mst_personal_user.zipcd_3" />
  <item name="郵便番号4" col="mst_personal_user.zipcd_4" />

  <item name="自宅住所" col="mst_personal_user.address" />
  <item name="自宅住所かな" col="mst_personal_user.address_kana" />

  <item name="職種コード" col="mst_personal_user.job_cd" />

  <item name="管理者フラグ" col="mst_personal_user.administrator" />

  <item name="表示フラグ" col="mst_personal_user.is_disp" />
  <item name="削除フラグ" col="mst_personal_user.is_del" />

  <item name="院内コード1" col="mst_personal_user.in_hospital_cd_1" />
  <item name="院内コード2" col="mst_personal_user.in_hospital_cd_2" />
  <item name="管理者への表示許可" col="mst_personal_user.info_disp_to_admin" />
  <item name="麻薬施用者免許証番号" col="mst_personal_user.anesthesiologist_license_no" />

  <!-- mst_user_authentication -->
  <item name="表示用利用者ID" col="mst_user_authentication.disp_user_id" />
  <item name="パスワード" col="mst_user_authentication.user_password" />
  <item name="サインイン失敗回数" col="mst_user_authentication.failure_cnt" />

  <!-- mst_user -->
  <item name="ユーザー設定" col="mst_user.user_settings.is_disp_menu" />
  <item name="ユーザー設定" col="mst_user.user_settings.font_size" />
  <item name="ユーザー設定" col="mst_user.user_settings.theme" />
  <item name="ユーザー設定" col="mst_user.user_settings.is_split_frame" />

  <item name="仮登録フラグ" col="mst_user.is_provisional" />
  <item name="表示フラグ" col="mst_user.is_disp" />
  <item name="削除フラグ" col="mst_user.is_del" />
  <item name="システムで管理する一意な患者ID" col="mst_user.pat_id" />
  <item name="テンプレートログ" col="mst_user.tmp_log_search_condition.idFilter" />
  <item name="テンプレートログ" col="mst_user.tmp_log_search_condition.nameFilter" />
  <item name="テンプレートログ" col="mst_user.tmp_log_search_condition.condition" />
  <item name="秘密鍵" col="mst_user.secret_key" />
  <item name="秘密キーフラグ" col="mst_user.is_set_qr_code" />
  <item name="アクセスカード番号" col="mst_user.card_idm" />
  <item name="個人情報取扱い同意フラグ" col="mst_user.is_consent" />
  <item name="個人情報取扱い同意日時" col="mst_user.consent_date" />
</root>
'),
'{}',
'1',
'0',
12345,
'20191118',
'20191118'
);

INSERT INTO mst_coop_layout (
  ctl_no
  , facility_cd
  , coop_cd
  , coop_cd_index
  , direction
  , coop_cd_sub
  , coop_format
  , coop_name
  , coop_vender
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
) VALUES (
3300002,
'F_hQ03',
'user_test',
'',
'R',
'upd',
'csv',
'サンプル1',
'TEX-SOL',
'動作確認用(upd)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="ユーザ情報連携">
  <item name="処理区分" />

  <!-- mst_personal_user -->
  <item name="利用者種別" col="mst_personal_user.user_type" />

  <item name="利用者名_姓" col="mst_personal_user.user_last_name" />
  <item name="利用者名_名" col="mst_personal_user.user_first_name" />

  <item name="利用者カナ名_姓" col="mst_personal_user.user_last_name_kana" />
  <item name="利用者カナ名_名" col="mst_personal_user.user_first_name_kana" />

  <item name="利用者英字名_姓" col="mst_personal_user.user_last_name_alpha" />
  <item name="利用者英字名_名" col="mst_personal_user.user_first_name_alpha" />

  <item name="メールアドレス1" col="mst_personal_user.user_email_address_1" />
  <item name="メールアドレス2" col="mst_personal_user.user_email_address_2" />

  <item name="内線番号" col="mst_personal_user.extension_no" />
  <item name="自宅番号" col="mst_personal_user.home_no" />
  <item name="携帯番号" col="mst_personal_user.mobile_phone_no" />
  <item name="FAX番号" col="mst_personal_user.fax_no" />

  <item name="郵便番号3" col="mst_personal_user.zipcd_3" />
  <item name="郵便番号4" col="mst_personal_user.zipcd_4" />

  <item name="自宅住所" col="mst_personal_user.address" />
  <item name="自宅住所かな" col="mst_personal_user.address_kana" />

  <item name="職種コード" col="mst_personal_user.job_cd" />

  <item name="管理者フラグ" col="mst_personal_user.administrator" />

  <item name="表示フラグ" col="mst_personal_user.is_disp" />
  <item name="削除フラグ" col="mst_personal_user.is_del" />

  <item name="院内コード1" col="mst_personal_user.in_hospital_cd_1" />
  <item name="院内コード2" col="mst_personal_user.in_hospital_cd_2" />
  <item name="管理者への表示許可" col="mst_personal_user.info_disp_to_admin" />
  <item name="麻薬施用者免許証番号" col="mst_personal_user.anesthesiologist_license_no" />

  <!-- mst_user_authentication -->
  <item name="表示用利用者ID" col="mst_user_authentication.disp_user_id" />
  <item name="パスワード" col="mst_user_authentication.user_password" />
  <item name="サインイン失敗回数" col="mst_user_authentication.failure_cnt" />

  <!-- mst_user -->
  <item name="ユーザー設定" col="mst_user.user_settings.is_disp_menu" />
  <item name="ユーザー設定" col="mst_user.user_settings.font_size" />
  <item name="ユーザー設定" col="mst_user.user_settings.theme" />
  <item name="ユーザー設定" col="mst_user.user_settings.is_split_frame" />

  <item name="仮登録フラグ" col="mst_user.is_provisional" />
  <item name="表示フラグ" col="mst_user.is_disp" />
  <item name="削除フラグ" col="mst_user.is_del" />
  <item name="システムで管理する一意な患者ID" col="mst_user.pat_id" />
  <item name="テンプレートログ" col="mst_user.tmp_log_search_condition.idFilter" />
  <item name="テンプレートログ" col="mst_user.tmp_log_search_condition.nameFilter" />
  <item name="テンプレートログ" col="mst_user.tmp_log_search_condition.condition" />
  <item name="秘密鍵" col="mst_user.secret_key" />
  <item name="秘密キーフラグ" col="mst_user.is_set_qr_code" />
  <item name="アクセスカード番号" col="mst_user.card_idm" />
  <item name="個人情報取扱い同意フラグ" col="mst_user.is_consent" />
  <item name="個人情報取扱い同意日時" col="mst_user.consent_date" />
</root>
'),
'{}',
'1',
'0',
12345,
'20191118',
'20191118'
);

INSERT INTO mst_coop_layout (
  ctl_no
  , facility_cd
  , coop_cd
  , coop_cd_index
  , direction
  , coop_cd_sub
  , coop_format
  , coop_name
  , coop_vender
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
) VALUES (
3300003,
'F_hQ03',
'user_test',
'',
'R',
'del',
'csv',
'サンプル1',
'TEX-SOL',
'動作確認用(del)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="ユーザ情報連携">
  <item name="処理区分" />

  <!-- mst_personal_user -->
  <item name="利用者種別" col="mst_personal_user.user_type" />

  <item name="利用者名_姓" col="mst_personal_user.user_last_name" />
  <item name="利用者名_名" col="mst_personal_user.user_first_name" />

  <item name="利用者カナ名_姓" col="mst_personal_user.user_last_name_kana" />
  <item name="利用者カナ名_名" col="mst_personal_user.user_first_name_kana" />

  <item name="利用者英字名_姓" col="mst_personal_user.user_last_name_alpha" />
  <item name="利用者英字名_名" col="mst_personal_user.user_first_name_alpha" />

  <item name="メールアドレス1" col="mst_personal_user.user_email_address_1" />
  <item name="メールアドレス2" col="mst_personal_user.user_email_address_2" />

  <item name="内線番号" col="mst_personal_user.extension_no" />
  <item name="自宅番号" col="mst_personal_user.home_no" />
  <item name="携帯番号" col="mst_personal_user.mobile_phone_no" />
  <item name="FAX番号" col="mst_personal_user.fax_no" />

  <item name="郵便番号3" col="mst_personal_user.zipcd_3" />
  <item name="郵便番号4" col="mst_personal_user.zipcd_4" />

  <item name="自宅住所" col="mst_personal_user.address" />
  <item name="自宅住所かな" col="mst_personal_user.address_kana" />

  <item name="職種コード" col="mst_personal_user.job_cd" />

  <item name="管理者フラグ" col="mst_personal_user.administrator" />

  <item name="表示フラグ" col="mst_personal_user.is_disp" />
  <item name="削除フラグ" col="mst_personal_user.is_del" />

  <item name="院内コード1" col="mst_personal_user.in_hospital_cd_1" />
  <item name="院内コード2" col="mst_personal_user.in_hospital_cd_2" />
  <item name="管理者への表示許可" col="mst_personal_user.info_disp_to_admin" />
  <item name="麻薬施用者免許証番号" col="mst_personal_user.anesthesiologist_license_no" />

  <!-- mst_user_authentication -->
  <item name="表示用利用者ID" col="mst_user_authentication.disp_user_id" />
  <item name="パスワード" col="mst_user_authentication.user_password" />
  <item name="削除フラグ" col="mst_user_authentication.is_del" />

  <!-- mst_user -->
  <item name="ユーザー設定" col="mst_user.user_settings.is_disp_menu" />
  <item name="ユーザー設定" col="mst_user.user_settings.font_size" />
  <item name="ユーザー設定" col="mst_user.user_settings.theme" />
  <item name="ユーザー設定" col="mst_user.user_settings.is_split_frame" />

  <item name="仮登録フラグ" col="mst_user.is_provisional" />
  <item name="表示フラグ" col="mst_user.is_disp" />
  <item name="削除フラグ" col="mst_user.is_del" />
  <item name="システムで管理する一意な患者ID" col="mst_user.pat_id" />
  <item name="テンプレートログ" col="mst_user.tmp_log_search_condition.idFilter" />
  <item name="テンプレートログ" col="mst_user.tmp_log_search_condition.nameFilter" />
  <item name="テンプレートログ" col="mst_user.tmp_log_search_condition.condition" />
  <item name="秘密鍵" col="mst_user.secret_key" />
  <item name="秘密キーフラグ" col="mst_user.is_set_qr_code" />
  <item name="アクセスカード番号" col="mst_user.card_idm" />
  <item name="個人情報取扱い同意フラグ" col="mst_user.is_consent" />
  <item name="個人情報取扱い同意日時" col="mst_user.consent_date" />
</root>
'),
'{}',
'1',
'0',
12345,
'20191118',
'20191118'
);

