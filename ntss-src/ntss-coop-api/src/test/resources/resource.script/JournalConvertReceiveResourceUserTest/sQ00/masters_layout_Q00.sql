DELETE FROM mst_coop_layout
WHERE ctl_no BETWEEN 3000000 AND 3099999;

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
3000000,
'F_hQ00',
'user_test',
'1001',
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
3000001,
'F_hQ00',
'user_test',
'1001',
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
</root>
'),
'{}',
'1',
'0',
12345,
'20191118',
'20191118'
);
