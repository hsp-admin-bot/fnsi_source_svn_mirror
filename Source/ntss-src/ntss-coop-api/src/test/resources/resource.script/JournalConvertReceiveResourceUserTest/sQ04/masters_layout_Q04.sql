DELETE FROM mst_coop_layout
WHERE ctl_no BETWEEN 3400000 AND 3499999;

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
3400000,
'F_hQ04',
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
  <item name="利用者名_姓" col="mst_personal_user.user_last_name" />
  <item name="利用者名_名" col="mst_personal_user.user_first_name" />

  <item name="削除フラグ" col="mst_personal_user.is_del" />

  <item name="院内コード1" col="mst_personal_user.in_hospital_cd_1" />
  <item name="院内コード2" col="mst_personal_user.in_hospital_cd_2" />

  <!-- mst_user_authentication -->
  <item name="表示用利用者ID" col="mst_user_authentication.disp_user_id" />
  <item name="パスワード" col="mst_user_authentication.user_password" />

  <!-- mst_user -->
  <item name="仮登録フラグ" col="mst_user.is_provisional" />
  <item name="削除フラグ" col="mst_user.is_del" />
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
3400001,
'F_hQ04',
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
  <item name="利用者名_姓" col="mst_personal_user.user_last_name" />
  <item name="利用者名_名" col="mst_personal_user.user_first_name" />

  <item name="削除フラグ" col="mst_personal_user.is_del" />

  <item name="院内コード1" col="mst_personal_user.in_hospital_cd_1" />
  <item name="院内コード2" col="mst_personal_user.in_hospital_cd_2" />

  <!-- mst_user_authentication -->
  <item name="表示用利用者ID" col="mst_user_authentication.disp_user_id" />
  <item name="パスワード" col="mst_user_authentication.user_password" />

  <!-- mst_user -->
  <item name="仮登録フラグ" col="mst_user.is_provisional" />
  <item name="削除フラグ" col="mst_user.is_del" />
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
