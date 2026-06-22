insert into mst_coop_layout (
  facility_cd
  , coop_cd
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
) values ('F_hosp','ini_dial','R','pre','text','富士通想定透析初回申し込み','Egmain-GX','テスト用','1','
<root name="透析初回申し込み">
    <item name="電文種別" len="2" col="電文.電文種別" type="string" key="shori_kbn" />
    <item name="レコード継続指示" len="1" col="電文.レコード継続指示" type="string"/>
    <item name="送信先システムコード" len="2" col="電文.送信先システムコード" type="string"/>
    <item name="発信元システムコード" len="2" col="電文.発信元システムコード" type="string"/>
    <item name="処理情報.処理年月日" len="8" col="電文.処理情報.処理年月日" type="string"/>
    <item name="処理情報.処理時刻" len="6" col="電文.処理情報.処理時刻" type="string"/>
    <item name="端末名" len="8" col="電文.端末名" type="string"/>
    <item name="利用者番号" len="8" col="電文.利用者番号" type="string"/>
    <item name="処理区分" len="2" col="電文.処理区分" type="string"/>
    <item name="応答種別" len="2" col="電文.応答種別" type="string"/>
    <item name="電文長" len="6" col="電文.電文長" type="string"/>
    <item name="エラーコード" len="5" col="電文.エラーコード" type="string"/>
    <item name="予備" len="12" col="電文.予備" type="string"/>
    <item name="患者情報.患者番号" len="10" col="患者情報.患者番号" type="string"/>
    <item name="伝票情報.オーダ番号" len="8" col="伝票情報.オーダ番号" type="string"/>
    <item name="伝票情報.親文書番号" len="30" col="伝票情報.親文書番号" type="string"/>
    <item name="伝票情報.文書番号" len="30" col="伝票情報.文書番号" type="string"/>
    <item name="伝票情報.文書版数" len="2" col="伝票情報.文書版数" type="string"/>
    <item name="伝票情報.関連オーダ番号" len="8" col="伝票情報.関連オーダ番号" type="string"/>
    <item name="伝票情報.実施番号" len="8" col="伝票情報.実施番号" type="string"/>
    <item name="伝票情報.更新後実施日時.実施日" len="8" col="伝票情報.更新後実施日時.実施日" type="string"/>
    <item name="伝票情報.更新後実施日時.実施時間" len="6" col="伝票情報.更新後実施日時.実施時間" type="string"/>
    <item name="伝票情報.更新前実施日時.実施日" len="8" col="伝票情報.更新前実施日時.実施日" type="string"/>
    <item name="伝票情報.更新前実施日時.実施日実施時間" len="6" col="伝票情報.更新前実施日時.実施日実施時間" type="string"/>
    <item name="伝票情報.終了日時.終了日付" len="8" col="伝票情報.終了日時.終了日付" type="string"/>
    <item name="伝票情報.終了日時.終了日付終了時間" len="6" col="伝票情報.終了日時.終了日付終了時間" type="string"/>
    <item name="伝票情報.オーダ作成日.オーダ日付" len="8" col="伝票情報.オーダ作成日.オーダ日付" type="string"/>
    <item name="伝票情報.オーダ作成日.オーダ時間" len="6" col="伝票情報.オーダ作成日.オーダ時間" type="string"/>
    <item name="伝票情報.保険パターン番号" len="2" col="伝票情報.保険パターン番号" type="string"/>
    <item name="伝票情報.入外区分" len="1" col="伝票情報.入外区分" type="string"/>
    <item name="伝票情報.診療科コード" len="3" col="伝票情報.診療科コード" type="string"/>
    <item name="伝票情報.診療科名称" len="32" col="伝票情報.診療科名称" type="string"/>
    <item name="伝票情報.病棟コード" len="3" col="伝票情報.病棟コード" type="string"/>
    <item name="伝票情報.病棟名称" len="32" col="伝票情報.病棟名称" type="string"/>
    <item name="伝票情報.オーダ発行利用者番号" len="8" col="伝票情報.オーダ発行利用者番号" type="string"/>
    <item name="伝票情報.オーダ発行利用者名" len="20" col="伝票情報.オーダ発行利用者名" type="string"/>
    <item name="伝票情報.依頼医利用者番号" len="8" col="伝票情報.依頼医利用者番号" type="string"/>
    <item name="伝票情報.依頼医名" len="20" col="伝票情報.依頼医名" type="string"/>
    <item name="伝票情報.伝票種別" len="1" col="伝票情報.伝票種別" type="string"/>
    <item name="伝票情報.伝票コード" len="4" col="伝票情報.伝票コード" type="string"/>
    <occ name="明細行数" len="4">
      <item name="ダミー" len="1" />
    </occ>
    <item name="新規変更の区分" len="0"/>
    <item name="終端" len="1" term="true"/>
</root>
'
,json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del')))
,'1','0',4126,'2019/12/13 5:44:54','2019/12/13 5:44:54');

insert into mst_coop_layout (
  facility_cd
  , coop_cd
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
) values ('F_hosp','ini_dial','R','cre','text','富士通想定透析初回申し込み','Egmain-GX','テスト用','1','
<root name="透析初回申し込み">
    <item name="電文種別" len="2" col="電文.電文種別" type="string"/>
    <item name="レコード継続指示" len="1" col="電文.レコード継続指示" type="string"/>
    <item name="送信先システムコード" len="2" col="電文.送信先システムコード" type="string"/>
    <item name="発信元システムコード" len="2" col="電文.発信元システムコード" type="string"/>
    <item name="処理情報.処理年月日" len="8" col="電文.処理情報.処理年月日" type="string"/>
    <item name="処理情報.処理時刻" len="6" col="電文.処理情報.処理時刻" type="string"/>
    <item name="端末名" len="8" col="電文.端末名" type="string"/>
    <item name="利用者番号" len="8" col="電文.利用者番号" type="string"/>
    <item name="処理区分" len="2" col="電文.処理区分" type="string"/>
    <item name="応答種別" len="2" col="電文.応答種別" type="string"/>
    <item name="電文長" len="6" col="電文.電文長" type="string"/>
    <item name="エラーコード" len="5" col="電文.エラーコード" type="string"/>
    <item name="予備" len="12" col="電文.予備" type="string"/>
    <item name="患者情報.患者番号" len="10" col="患者情報.患者番号" type="string"/>
    <item name="伝票情報.オーダ番号" len="8" col="伝票情報.オーダ番号" type="string"/>
    <item name="伝票情報.親文書番号" len="30" col="伝票情報.親文書番号" type="string"/>
    <item name="伝票情報.文書番号" len="30" col="伝票情報.文書番号" type="string"/>
    <item name="伝票情報.文書版数" len="2" col="伝票情報.文書版数" type="string"/>
    <item name="伝票情報.関連オーダ番号" len="8" col="伝票情報.関連オーダ番号" type="string"/>
    <item name="伝票情報.実施番号" len="8" col="伝票情報.実施番号" type="string"/>
    <item name="伝票情報.更新後実施日時.実施日" len="8" col="伝票情報.更新後実施日時.実施日" type="string"/>
    <item name="伝票情報.更新後実施日時.実施時間" len="6" col="伝票情報.更新後実施日時.実施時間" type="string"/>
    <item name="伝票情報.更新前実施日時.実施日" len="8" col="伝票情報.更新前実施日時.実施日" type="string"/>
    <item name="伝票情報.更新前実施日時.実施日実施時間" len="6" col="伝票情報.更新前実施日時.実施日実施時間" type="string"/>
    <item name="伝票情報.終了日時.終了日付" len="8" col="伝票情報.終了日時.終了日付" type="string"/>
    <item name="伝票情報.終了日時.終了日付終了時間" len="6" col="伝票情報.終了日時.終了日付終了時間" type="string"/>
    <item name="伝票情報.オーダ作成日.オーダ日付" len="8" col="伝票情報.オーダ作成日.オーダ日付" type="string"/>
    <item name="伝票情報.オーダ作成日.オーダ時間" len="6" col="伝票情報.オーダ作成日.オーダ時間" type="string"/>
    <item name="伝票情報.保険パターン番号" len="2" col="伝票情報.保険パターン番号" type="string"/>
    <item name="伝票情報.入外区分" len="1" col="伝票情報.入外区分" type="string"/>
    <item name="伝票情報.診療科コード" len="3" col="伝票情報.診療科コード" type="string"/>
    <item name="伝票情報.診療科名称" len="32" col="伝票情報.診療科名称" type="string"/>
    <item name="伝票情報.病棟コード" len="3" col="伝票情報.病棟コード" type="string"/>
    <item name="伝票情報.病棟名称" len="32" col="伝票情報.病棟名称" type="string"/>
    <item name="伝票情報.オーダ発行利用者番号" len="8" col="伝票情報.オーダ発行利用者番号" type="string"/>
    <item name="伝票情報.オーダ発行利用者名" len="20" col="伝票情報.オーダ発行利用者名" type="string"/>
    <item name="伝票情報.依頼医利用者番号" len="8" col="伝票情報.依頼医利用者番号" type="string"/>
    <item name="伝票情報.依頼医名" len="20" col="伝票情報.依頼医名" type="string"/>
    <item name="伝票情報.伝票種別" len="1" col="伝票情報.伝票種別" type="string"/>
    <item name="伝票情報.伝票コード" len="4" col="伝票情報.伝票コード" type="string"/>
    <occ name="明細行数" len="4">
      <item name="ダミー" len="1" />
    </occ>
    <item name="新規変更の区分" len="0"/>
    <item name="終端" len="1" term="true"/>
</root>
  ','{}','1','0',4126,'2019/12/13 5:44:54','2019/12/13 5:44:54');

insert into mst_coop_layout(
  facility_cd
  , coop_cd
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
)  values ('F_hosp','profile','R','pre','text','富士通想定患者プロファイル','Egmain-GX','テスト用','1','
<root name="患者プロファイル">
<item name="電文種別" len="2" type="string"/>
<item name="レコード継続指示" len="1" type="string"/>
<item name="送信先システムコード" len="2" type="string"/>
<item name="発信元システムコード" len="2" type="string"/>
<item name="処理情報.処理年月日" len="8" type="string"/>
<item name="処理情報.処理時刻" len="6" type="string"/>
<item name="端末名" len="8" type="string"/>
<item name="利用者番号" len="8" type="string"/>
<item name="処理区分" len="2" type="string"/>
<item name="応答種別" len="2" type="string"/>
<item name="電文長" len="6" type="string"/>
<item name="エラーコード" len="5" type="string"/>
<item name="予備" len="12" type="string"/>
<item name="患者番号" len="10" type="string"/>
<item name="患者漢字氏名" len="30" type="string"/>
<item name="患者カナ氏名" len="60" type="string"/>
<item name="患者性別" len="1" type="string"/>
<item name="患者生年月日" len="8" type="string"/>
<item name="郵便番号１" len="3" type="string"/>
<item name="郵便番号２" len="4" type="string"/>
<item name="患者住所" len="40" type="string"/>
<item name="患者住所詳細" len="60" type="string"/>
<item name="電話番号" len="15" type="string"/>
<item name="入外区分" len="1" col="入院情報" type="string"/>
<item name="入院診療科コード" len="3" type="string"/>
<item name="入院中病棟" len="3" type="string"/>
<item name="入院中部屋" len="5" type="string"/>
<item name="入院中ベッドコード" len="2" type="string"/>
<occ name="保険テーブル" len="0" type="string" repeat="30" detail="insurance"/>
<occ name="患者プロファイル情報数" len="2" type="string" detail="prof_info"/>
<item name="終端" len="1" term="true" type="string"/>
</root>
','{}','1','0',4126,'2019/12/23 5:44:54','2019/12/23 5:44:54');

insert into mst_coop_layout(
  facility_cd
  , coop_cd
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
)  values ('F_hosp','profile','R','cre','text','富士通想定患者プロファイル','Egmain-GX','テスト用','1','
<root name="患者プロファイル">
<item name="電文種別" len="2" type="string"/>
<item name="レコード継続指示" len="1" type="string"/>
<item name="送信先システムコード" len="2" type="string"/>
<item name="発信元システムコード" len="2" type="string"/>
<item name="処理情報.処理年月日" len="8" type="string"/>
<item name="処理情報.処理時刻" len="6" type="string"/>
<item name="端末名" len="8" type="string"/>
<item name="利用者番号" len="8" type="string"/>
<item name="処理区分" len="2" type="string"/>
<item name="応答種別" len="2" type="string"/>
<item name="電文長" len="6" type="string"/>
<item name="エラーコード" len="5" type="string"/>
<item name="予備" len="12" type="string"/>
<item name="患者番号" len="10" type="string"/>
<item name="患者漢字氏名" len="30" type="string"/>
<item name="患者カナ氏名" len="60" type="string"/>
<item name="患者性別" len="1" type="string"/>
<item name="患者生年月日" len="8" type="string"/>
<item name="郵便番号１" len="3" type="string"/>
<item name="郵便番号２" len="4" type="string"/>
<item name="患者住所" len="40" type="string"/>
<item name="患者住所詳細" len="60" type="string"/>
<item name="電話番号" len="15" type="string"/>
<item name="入外区分" len="1" col="入院情報" type="string"/>
<item name="入院診療科コード" len="3" type="string"/>
<item name="入院中病棟" len="3" type="string"/>
<item name="入院中部屋" len="5" type="string"/>
<item name="入院中ベッドコード" len="2" type="string"/>
<occ name="保険テーブル" len="0" type="string" repeat="30" detail="insurance"/>
<occ name="患者プロファイル情報数" len="2" type="string" detail="prof_info"/>
<item name="終端" len="1" term="true" type="string"/>
</root>
  ','{}','1','0',4126,'2019/12/23 5:44:54','2019/12/23 5:44:54');

insert into mst_coop_layout(
  facility_cd
  , coop_cd
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
)  values ('F_hosp','profile','R','pre','text','富士通想定患者プロファイル','Egmain-GX','テスト用','1','
<root name="患者プロファイル">
<item name="電文種別" len="2" col="ヘッダ.ヘッダ種別" key="電文種別" type="string" value="const;XI"/>
<item name="レコード継続指示" len="1" col="ヘッダ.レコード継続指示" type="string"/>
<item name="送信先システムコード" len="2" col="ヘッダ.送信先システムコード" type="string"/>
<item name="発信元システムコード" len="2" col="ヘッダ.発信元システムコード" type="string"/>
<item name="処理情報.処理年月日" len="8" col="ヘッダ.処理情報.処理年月日" type="string"/>
<item name="処理情報.処理時刻" len="6" col="ヘッダ.処理情報.処理時刻" type="string"/>
<item name="端末名" len="8" col="ヘッダ.端末名" type="string"/>
<item name="利用者番号" len="8" col="ヘッダ.利用者番号" type="string"/>
<item name="処理区分" len="2" col="ヘッダ.処理区分" type="string"/>
<item name="応答種別" len="2" col="ヘッダ.応答種別" type="string"/>
<item name="電文長" len="6" col="ヘッダ.ヘッダ長" type="string"/>
<item name="エラーコード" len="5" col="ヘッダ.エラーコード" type="string"/>
<item name="予備" len="12" col="ヘッダ.予備" type="string"/>
<item name="患者番号" len="10" type="string"/>
<item name="患者漢字氏名" len="30" type="string"/>
<item name="患者カナ氏名" len="30" type="string"/>
<item name="患者性別" len="1" type="string"/>
<item name="患者生年月日" len="8" type="string"/>
<item name="郵便番号１" len="3" type="string"/>
<item name="郵便番号２" len="4" type="string"/>
<item name="患者住所" len="40" type="string"/>
<item name="患者住所詳細" len="60" type="string"/>
<item name="電話番号" len="15" type="string"/>
<item name="入外区分" len="1" col="入院情報" type="string"/>
<item name="入院診療科コード" len="3" type="string"/>
<item name="入院中病棟" len="3" type="string"/>
<item name="入院中部屋" len="5" type="string"/>
<item name="入院中ベッドコード" len="2" type="string"/>
<occ name="保険テーブル" len="0" type="string" repeat="30"/>
<occ name="患者プロファイル情報数" len="2" type="string"/>
<item name="終端" len="1" type="string"/>
</root>
','{"key": ""}','1','0',4126,'2019/12/23 6:35:38','2019/12/23 6:35:38');

insert into mst_coop_layout(
  facility_cd
  , coop_cd
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
)  values ('F_hosp','profile','R','cre','text','富士通想定患者プロファイル','Egmain-GX','テスト用','1','
<root name="患者プロファイル">
<item name="電文種別" len="2" col="ヘッダ.ヘッダ種別" key="電文種別" type="string" value="const;XI"/>
<item name="レコード継続指示" len="1" col="ヘッダ.レコード継続指示" type="string"/>
<item name="送信先システムコード" len="2" col="ヘッダ.送信先システムコード" type="string"/>
<item name="発信元システムコード" len="2" col="ヘッダ.発信元システムコード" type="string"/>
<item name="処理情報.処理年月日" len="8" col="ヘッダ.処理情報.処理年月日" type="string"/>
<item name="処理情報.処理時刻" len="6" col="ヘッダ.処理情報.処理時刻" type="string"/>
<item name="端末名" len="8" col="ヘッダ.端末名" type="string"/>
<item name="利用者番号" len="8" col="ヘッダ.利用者番号" type="string"/>
<item name="処理区分" len="2" col="ヘッダ.処理区分" type="string"/>
<item name="応答種別" len="2" col="ヘッダ.応答種別" type="string"/>
<item name="電文長" len="6" col="ヘッダ.ヘッダ長" type="string"/>
<item name="エラーコード" len="5" col="ヘッダ.エラーコード" type="string"/>
<item name="予備" len="12" col="ヘッダ.予備" type="string"/>
<item name="患者番号" len="10" type="string"/>
<item name="患者漢字氏名" len="30" type="string"/>
<item name="患者カナ氏名" len="30" type="string"/>
<item name="患者性別" len="1" type="string"/>
<item name="患者生年月日" len="8" type="string"/>
<item name="郵便番号１" len="3" type="string"/>
<item name="郵便番号２" len="4" type="string"/>
<item name="患者住所" len="40" type="string"/>
<item name="患者住所詳細" len="60" type="string"/>
<item name="電話番号" len="15" type="string"/>
<item name="入外区分" len="1" col="入院情報" type="string"/>
<item name="入院診療科コード" len="3" type="string"/>
<item name="入院中病棟" len="3" type="string"/>
<item name="入院中部屋" len="5" type="string"/>
<item name="入院中ベッドコード" len="2" type="string"/>
<occ name="保険テーブル" len="0" type="string" repeat="30"/>
<occ name="患者プロファイル情報数" len="2" type="string"/>
<item name="終端" len="1" type="string"/>
</root>
','{"key": ""}','1','0',4126,'2019/12/23 6:35:38','2019/12/23 6:35:38');

-- mst_coop_layout_detail
insert into mst_coop_layout_detail(
  facility_cd
  , coop_cd
  , direction
  , coop_cd_detail
  , coop_cd_detail_sub
  , coop_name
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
)  values ('F_hosp','ini_dial','R','ini_dial_meisai','pre','富士通想定透析初回申込-申込詳細','For test','1','
<root name="透析申込詳細">
    <item name="明細.項目コード" len="8"/>
    <item name="明細.項目属性" len="3" key="項目属性"/> <!-- TODO この値がcoop_cd_detail_subとなる。-->
    <item name="明細.項目名称" len="50"/>
    <item name="明細.数量" len="11"/>
    <item name="明細.選択単位フラグ" len="1"/>
    <item name="明細.単位コード" len="3"/>
    <item name="明細.単位名称" len="4"/>
    <item name="明細.第２単位コード" len="3"/>
    <item name="明細.第２単位名称" len="4"/>
    <item name="明細.単位換算量" len="11"/>
</root>
','{"key": {"項目属性": {"VAB": "障害者加算", "VB1": "原疾患", "VC1": "治療方法", "VF3": "明細", "XXX": "コメント"}}}'
,'1','0',4126,'2019/12/13 6:16:24','2019/12/13 6:16:24');

insert into mst_coop_layout_detail(
  facility_cd
  , coop_cd
  , direction
  , coop_cd_detail
  , coop_cd_detail_sub
  , coop_name
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
)  values ('F_hosp','ini_dial','R','ini_dial_meisai','原疾患','富士通想定透析初回申込-申込詳細','For test','1','
<root name="透析申込詳細">"
<item name="明細.項目コード" len="8" col="pat_unique.medical_hst_info.disease_cd" type="string"/>
<item name="明細.項目属性" len="3" type="string"/>
<item name="明細.項目名称" len="50" type="string"/>
<item name="明細.数量" len="11" type="string"/>
<item name="明細.選択単位フラグ" len="1" type="string"/>
<item name="明細.単位コード" len="3" type="string"/>
<item name="明細.単位名称" len="4" type="string"/>
<item name="明細.第２単位コード" len="3" type="string"/>
<item name="明細.第２単位名称" len="4" type="string"/>
<item name="明細.単位換算量" len="11" type="string"/>
</root>
','{}','1','0',4126,'2019/12/13 9:30:47','2019/12/13 9:30:47');

insert into mst_coop_layout_detail(
  facility_cd
  , coop_cd
  , direction
  , coop_cd_detail
  , coop_cd_detail_sub
  , coop_name
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
)  values ('F_hosp','ini_dial','R','ini_dial_meisai','障害者加算','富士通想定透析初回申込-申込詳細','For test','1','
<root name="透析申込詳細">"
<item name="明細.項目コード" len="8" col="pat_personal_main.dial_diff_com_info.dial_diff_com_info" type="string"/>
<item name="明細.項目属性" len="3" type="string"/>
<item name="明細.項目名称" len="50" type="string"/>
<item name="明細.数量" len="11" type="string"/>
<item name="明細.選択単位フラグ" len="1" type="string"/>
<item name="明細.単位コード" len="3" type="string"/>
<item name="明細.単位名称" len="4" type="string"/>
<item name="明細.第２単位コード" len="3" type="string"/>
<item name="明細.第２単位名称" len="4" type="string"/>
<item name="明細.単位換算量" len="11" type="string"/>
</root>
','{}','1','0',4126,'2019/12/13 9:31:33','2019/12/13 9:31:33');

insert into mst_coop_layout_detail(
  facility_cd
  , coop_cd
  , direction
  , coop_cd_detail
  , coop_cd_detail_sub
  , coop_name
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
)  values ('F_hosp','ini_dial','R','ini_dial_meisai','コメント','富士通想定透析初回申込-申込詳細','For test','1','
<root name="透析申込詳細">
<item name="明細.項目コード" len="8" type="string"/>
<item name="明細.項目属性" len="3" type="string"/>
<item name="明細.項目名称" len="50" col="pat_main.pat_memo_info.content" type="string"/>
<item name="明細.数量" len="11" type="string"/>
<item name="明細.選択単位フラグ" len="1" type="string"/>
<item name="明細.単位コード" len="3" type="string"/>
<item name="明細.単位名称" len="4" type="string"/>
<item name="明細.第２単位コード" len="3" type="string"/>
<item name="明細.第２単位名称" len="4" type="string"/>
<item name="明細.単位換算量" len="11" type="string"/>
</root>
','{}','1','0',4126,'2019/12/13 9:32:15','2019/12/13 9:32:15');

insert into mst_coop_layout_detail(
  facility_cd
  , coop_cd
  , direction
  , coop_cd_detail
  , coop_cd_detail_sub
  , coop_name
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
)  values ('F_hosp','ini_dial','R','ini_dial_meisai','治療方法','富士通想定透析初回申込-申込詳細','For test','1','
<root name="透析申込詳細">"
<item name="明細.項目コード" len="8" col="pat_order_data.vender_1_info.treat_cd" type="string"/>
<item name="明細.項目属性" len="3" type="string"/>
<item name="明細.項目名称" len="50" col="pat_order_data.vender_1_info.treat_name" type="string"/>
<item name="明細.数量" len="11" type="string"/>
<item name="明細.選択単位フラグ" len="1" type="string"/>
<item name="明細.単位コード" len="3" type="string"/>
<item name="明細.単位名称" len="4" type="string"/>
<item name="明細.第２単位コード" len="3" type="string"/>
<item name="明細.第２単位名称" len="4" type="string"/>
<item name="明細.単位換算量" len="11" type="string"/>
</root>
','{}','1','0',4126,'2019/12/13 9:32:52','2019/12/13 9:32:52');

insert into mst_coop_layout_detail(
  facility_cd
  , coop_cd
  , direction
  , coop_cd_detail
  , coop_cd_detail_sub
  , coop_name
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
)  values ('F_hosp','ini_dial','R','ini_dial_meisai','明細','富士通想定透析初回申込-申込詳細','For test','1','
<root name="透析申込詳細">
<item name="明細.項目コード" len="8" col="pat_order_data.vender_1_info.treat_cd" type="string"/>
<item name="明細.項目属性" len="3" type="string"/>
<item name="明細.項目名称" len="50" col="pat_order_data.vender_1_info.treat_name" type="string"/>
<item name="明細.数量" len="11" type="string"/>
<item name="明細.選択単位フラグ" len="1" type="string"/>
<item name="明細.単位コード" len="3" type="string"/>
<item name="明細.単位名称" len="4" type="string"/>
<item name="明細.第２単位コード" len="3" type="string"/>
<item name="明細.第２単位名称" len="4" type="string"/>
<item name="明細.単位換算量" len="11" type="string"/>
</root>
','{}','1','0',4126,'2019/12/13 9:34:15','2019/12/13 9:34:15');

insert into mst_coop_layout_detail(
  facility_cd
  , coop_cd
  , direction
  , coop_cd_detail
  , coop_cd_detail_sub
  , coop_name
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
) values ('F_hosp','profile','R','prof_info','pre','富士通想定患者プロファイル患者プロファイル項目','患者プロファイル項目','1','
<root name="患者プロファイル項目">
<item name="患者プロファイル項目属性" len="5" key="項目属性" type="string"/>
<item name="患者プロファイル項目ID" len="30" type="string"/>
<item name="患者プロファイル項目名称" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイル" len="1590" type="string"/>
<item name="患者プロファイル更新使用者ID" len="8" type="string"/>
<item name="患者プロファイル更新日" len="8" type="string"/>
<item name="患者プロファイル更新時間" len="6" type="string"/>
</root>
','{"key": {"項目属性": {"DBY20": "感染症", "DBY21": "感染症", "DBY22": "感染症", "DBY23": "感染症", "DBY77": "ICT", "NBS14": "緊急連絡先", "NBS15": "緊急連絡先", "OTS21": "生存有無"}}}'
,'1','0',4126,'2019/12/23 7:03:12','2019/12/23 7:03:12');

insert into mst_coop_layout_detail(
  facility_cd
  , coop_cd
  , direction
  , coop_cd_detail
  , coop_cd_detail_sub
  , coop_name
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
)  values ('F_hosp','profile','R','prof_info','緊急連絡先','富士通想定患者プロファイル患者プロファイル項目緊急連絡先','患者プロファイル項目','1','
<root name="患者プロファイル項目緊急連絡先">
<item name="患者プロファイル項目属性" len="5" type="string"/>
<item name="患者プロファイル項目ID" len="30" type="string"/>
<item name="患者プロファイル項目名称" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１" len="50" col="other_contact_info.tel1" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ２" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム２" len="50" col="other_contact_info.memo1" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ３" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム３" len="50" col="other_contact_info.relation_name" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ４" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム４" len="50" col="other_contact_info.tel2" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ５" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム５" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ６" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム６" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ７" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム７" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ８" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム８" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ９" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム９" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１０" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１０" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１１" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１１" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１２" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１２" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１３" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１３" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１４" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１４" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１５" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１５" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１６" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１６" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１７" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１７" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１８" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１８" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１９" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１９" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ２０" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム２０" len="50" type="string"/>
<item name="患者プロファイル更新使用者ID" len="8" type="string"/>
<item name="患者プロファイル更新日" len="8" type="string"/>
<item name="患者プロファイル更新時間" len="6"/>
</root>
','{}','1','0',4126,'2019/12/23 7:16:05','2019/12/23 7:16:05');

insert into mst_coop_layout_detail(
  facility_cd
  , coop_cd
  , direction
  , coop_cd_detail
  , coop_cd_detail_sub
  , coop_name
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
)  values ('F_hosp','profile','R','prof_info','緊急連絡先','富士通想定患者プロファイル患者プロファイル項目生存有無','患者プロファイル項目','1','
<root name="生存有無">
<item name="患者プロファイル項目属性" len="5" type="string"/>
<item name="患者プロファイル項目ID" len="30" type="string"/>
<item name="患者プロファイル項目名称" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１" len="50" col="pat_personal_main.is_die" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ２" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム２" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ３" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム３" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ４" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム４" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ５" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム５" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ６" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム６" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ７" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム７" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ８" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム８" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ９" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム９" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１０" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１０" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１１" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１１" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１２" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１２" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１３" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１３" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１４" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１４" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１５" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１５" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１６" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１６" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１７" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１７" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１８" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１８" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１９" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１９" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ２０" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム２０" len="50" type="string"/>
<item name="患者プロファイル更新使用者ID" len="8" type="string"/>
<item name="患者プロファイル更新日" len="8" type="string"/>
<item name="患者プロファイル更新時間" len="6" type="string"/>
</root>
','{}','1','0',4126,'2019/12/23 7:16:48','2019/12/23 7:16:48');

insert into mst_coop_layout_detail(
  facility_cd
  , coop_cd
  , direction
  , coop_cd_detail
  , coop_cd_detail_sub
  , coop_name
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
)  values ('F_hosp','profile','R','prof_info','感染症','富士通想定患者プロファイル患者プロファイル項目感染症','患者プロファイル項目','1','
<root name="感染症">
<item name="患者プロファイル項目属性" len="5" col="infect_info.infection_cd" type="string"/>
<item name="患者プロファイル項目ID" len="30" type="string"/>
<item name="患者プロファイル項目名称" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ２" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム２" len="50" col="infect_info.infect" type="string" value="json:{&quot;+&quot;&#xA0;:&#xA0;&quot;1&quot;,&#xA0;&#xA0;&#xA0;&#xA0;&quot;-&quot;&#xA0;:&#xA0;&quot;0&quot;}"/>
<item name="患者プロファイル項目情報プロファイルタイプ３" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム３" len="50" col="infect_info.exam_date" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ４" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム４" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ５" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム５" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ６" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム６" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ７" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム７" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ８" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム８" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ９" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム９" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１０" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１０" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１１" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１１" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１２" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１２" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１３" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１３" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１４" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１４" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１５" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１５" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１６" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１６" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１７" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１７" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１８" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１８" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ１９" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム１９" len="50" type="string"/>
<item name="患者プロファイル項目情報プロファイルタイプ２０" len="3" type="string"/>
<item name="患者プロファイル項目情報プロファイルアイテム２０" len="50" type="string"/>
<item name="患者プロファイル更新使用者ID" len="8" type="string"/>
<item name="患者プロファイル更新日" len="8" type="string"/>
<item name="患者プロファイル更新時間" len="6"/>
</root>
','{}','1','0',4126,'2019/12/23 7:18:31','2019/12/23 7:18:31');

INSERT INTO sys_coop_journal VALUES(
2001,'F_hosp','ini_dial','22','C','R',1,1,1,1,0,
'0','20191224','20191224',
'9','20191224','20191224',
'',
--'01C112220191224153600ABCDEFGHabcdefgh010299999900000abcdefghijkl01234567890123456712345678901234567890123456789012345678901234567890123456789001201912241530000120191223100000201912241520002019122411300020191224114000A10103ABCDEFGHABCDEFGHABCDEFGHABCDEFGH204ABCDEFGHABCDEFGHABCDEFGHABCDEFGH09876543abcdefghijabcdefghij01234567abcdefghijabcdefghij610240010pqrstpqrstZ',
decode('30314331313232323031393132323431353336303082a082a282a482a661626364656667683031303239393939393930303030306162636465666768696a6b6c30313233343536373839303132333435363731323334353637383930313233343536373839303132333435363738393031323334353637383930313233343536373839303132333435363738393030313230313931323234313533303030303132303139313232333130303030303230313931323234313532303030323031393132323431313330303032303139313232343131343030304131303130334142434445464748414243444546474841424344454647484142434445464748323034414243444546474841424344454647484142434445464748414243444546474830393837363534336162636465666768696a6162636465666768696a30313233343536376162636465666768696a6162636465666768696a363130323430303130707172737470717273740d', 'hex'),
'0','0',4126,'20191224','20191224'
);