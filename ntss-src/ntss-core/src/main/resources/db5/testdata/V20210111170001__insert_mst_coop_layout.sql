DELETE FROM "mst_coop_layout" WHERE "ctl_no" >= -4130018 AND "ctl_no" <= -4130001;

INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130018, '996996', 'ini_dial', '', 'R', 'pre', 'text     ', '富士通想定透析初回申し込み', 'Egmain-GX', 'テスト用', '1', '<root name="透析申込(pre)">

    <item  name="電文種別" len="2" col="電文種別" type="string"/>

    <item  name="レコード継続指示" len="1" col="レコード継続指示" type="string"/>

    <item  name="送信先システムコード" len="2" col="送信先システムコード" type="string"/>

    <item  name="発信元システムコード" len="2" col="発信元システムコード" type="string"/>

    <item  name="処理情報.処理年月日" len="8" col="処理情報.処理年月日" type="string"/>

    <item  name="処理情報.処理時刻" len="6" col="処理情報.処理時刻" type="string"/>

    <item  name="端末名" len="8" col="端末名" type="string"/>

    <item  name="利用者番号" len="8" col="利用者番号" type="string"/>

    <item  name="処理区分" len="2" col="処理区分" key="syori_kbn" type="string"/>

    <item  name="応答種別" len="2" col="応答種別" type="string"/>

    <item  name="電文長" len="6" col="電文長" type="string"/>

    <item  name="エラーコード" len="5" col="エラーコード" type="string"/>

    <item  name="予備" len="12" col="予備" type="string"/>

    <item  name="患者情報.患者番号" len="10" col="患者情報.患者番号" type="string"/>

    <item  name="伝票情報.オーダ番号" len="8" col="伝票情報.オーダ番号" type="string"/>

    <item  name="伝票情報.親文書番号" len="30" col="伝票情報.親文書番号" type="string"/>

    <item  name="伝票情報.文書番号" len="30" col="伝票情報.文書番号" type="string"/>

    <item  name="伝票情報.文書版数" len="2" col="伝票情報.文書版数" type="string"/>

    <item  name="伝票情報.関連オーダ番号" len="8" col="伝票情報.関連オーダ番号" type="string"/>

    <item  name="伝票情報.実施番号" len="8" col="伝票情報.実施番号" type="string"/>

    <item  name="伝票情報.更新後実施日時.実施日" len="8" col="伝票情報.更新後実施日時.実施日" type="string"/>

    <item  name="伝票情報.更新後実施日時.実施時間" len="6" col="伝票情報.更新後実施日時.実施時間" type="string"/>

    <item  name="伝票情報.更新前実施日時.実施日" len="8" col="伝票情報.更新前実施日時.実施日" type="string"/>

    <item  name="伝票情報.更新前実施日時.実施日実施時間" len="6" col="伝票情報.更新前実施日時.実施日実施時間" type="string"/>

    <item  name="伝票情報.終了日時.終了日付" len="8" col="伝票情報.終了日時.終了日付" type="string"/>

    <item  name="伝票情報.終了日時.終了日付終了時間" len="6" col="伝票情報.終了日時.終了日付終了時間" type="string"/>

    <item  name="伝票情報.オーダ作成日.オーダ日付" len="8" col="伝票情報.オーダ作成日.オーダ日付" type="string"/>

    <item  name="伝票情報.オーダ作成日.オーダ時間" len="6" col="伝票情報.オーダ作成日.オーダ時間" type="string"/>

    <item  name="伝票情報.保険パターン番号" len="2" col="伝票情報.保険パターン番号" type="string"/>

    <item  name="伝票情報.入外区分" len="1" col="伝票情報.入外区分" type="string"/>

    <item  name="伝票情報.診療科コード" len="3" col="伝票情報.診療科コード" type="string"/>

    <item  name="伝票情報.診療科名称" len="32" col="伝票情報.診療科名称" type="string"/>

    <item  name="伝票情報.病棟コード" len="3" col="伝票情報.病棟コード" type="string"/>

    <item  name="伝票情報.病棟名称" len="32" col="伝票情報.病棟名称" type="string"/>

    <item  name="伝票情報.オーダ発行利用者番号" len="8" col="伝票情報.オーダ発行利用者番号" type="string"/>

    <item  name="伝票情報.オーダ発行利用者名" len="20" col="伝票情報.オーダ発行利用者名" type="string"/>

    <item  name="伝票情報.依頼医利用者番号" len="8" col="伝票情報.依頼医利用者番号" type="string"/>

    <item  name="伝票情報.依頼医名" len="20" col="伝票情報.依頼医名" type="string"/>

    <item  name="伝票情報.伝票種別" len="1" col="伝票情報.伝票種別" type="string"/>

    <item  name="伝票情報.伝票コード" len="4" col="伝票情報.伝票コード" type="string"/>

    <item  name="明細行数" len="4" col="明細行数" type="string"/>

    <item  name="終端" len="1" col="終端" type="string"/>

    <item  name="新規変更の区分" len="0" col="新規変更の区分" type="string"/>

</root>', '{"key": {"shori_kbn": {"01": "all", "02": "all", "03": "all"}}}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130017, '996996', 'ini_dial', '', 'R', 'all', 'text     ', '富士通想定透析初回申し込み', 'Egmain-GX', 'テスト用', '1', '<root name="透析申込">

    <item  name="電文種別" len="2" type="string"/>

    <item  name="レコード継続指示" len="1" type="string"/>

    <item  name="送信先システムコード" len="2" type="string"/>

    <item  name="発信元システムコード" len="2" type="string"/>

    <item  name="処理情報.処理年月日" len="8" type="string"/>

    <item  name="処理情報.処理時刻" len="6" type="string"/>

    <item  name="端末名" len="8" type="string"/>

    <item  name="利用者番号" len="8" type="string"/>

    <item  name="処理区分" len="2" type="string"/>

    <item  name="応答種別" len="2" type="string"/>

    <item  name="電文長" len="6" type="string"/>

    <item  name="エラーコード" len="5" type="string"/>

    <item  name="予備" len="12" type="string"/>

    <item  name="患者情報.患者番号" len="10" col="pat_personal_main.hosp_pat_id" type="string"/>

    <item  name="伝票情報.オーダ番号" len="8" col="pat_order_data.vender_1_info.cop_ord_no1" type="string"/>

    <item  name="伝票情報.親文書番号" len="30" col="pat_order_data.vender_1_info.cop_ord_no2" type="string"/>

    <item  name="伝票情報.文書番号" len="30" col="pat_order_data.vender_1_info.cop_ord_no3" type="string"/>

    <item  name="伝票情報.文書版数" len="2" type="string"/>

    <item  name="伝票情報.関連オーダ番号" len="8" type="string"/>

    <item  name="伝票情報.実施番号" len="8" type="string"/>

    <item  name="伝票情報.更新後実施日時.実施日" len="8" type="string"/>

    <item  name="伝票情報.更新後実施日時.実施時間" len="6" type="string"/>

    <item  name="伝票情報.更新前実施日時.実施日" len="8" type="string"/>

    <item  name="伝票情報.更新前実施日時.実施日実施時間" len="6" type="string"/>

    <item  name="伝票情報.終了日時.終了日付" len="8" type="string"/>

    <item  name="伝票情報.終了日時.終了日付終了時間" len="6" type="string"/>

    <item  name="伝票情報.オーダ作成日.オーダ日付" len="8" col="pat_order_data.vender_1_info.red_date" type="string"/>

    <item  name="伝票情報.オーダ作成日.オーダ時間" len="6" col="pat_order_data.vender_1_info.red_date" type="string"/>

    <item  name="伝票情報.保険パターン番号" len="2" col="pat_cop_detail.vender_1_info.insu_no" type="string"/>

    <item  name="伝票情報.入外区分" len="1" type="string"/>

    <item  name="伝票情報.診療科コード" len="3" col="pat_unique.medical_care_info.main_course_cd" type="string"/>

    <item  name="伝票情報.診療科名称" len="32" type="string"/>

    <item  name="伝票情報.病棟コード" len="3" col="pat_unique.medical_care_info.ward_cd" type="string"/>

    <item  name="伝票情報.病棟名称" len="32" type="string"/>

    <item  name="伝票情報.オーダ発行利用者番号" len="8" type="string"/>

    <item  name="伝票情報.オーダ発行利用者名" len="20" type="string"/>

    <item  name="伝票情報.依頼医利用者番号" len="8" col="pat_main.charge_staff_info.staff_cd" type="string"/>

    <item  name="伝票情報.依頼医名" len="20" type="string"/>

    <item  name="伝票情報.伝票種別" len="1" type="string"/>

    <item  name="伝票情報.伝票コード" len="4" type="string"/>

    <occ  name="明細行数" len="4" detail="ini_dial_meisai"/>

    <item  name="終端" len="1" type="string"/>

    <item  name="新規変更の区分" len="0" type="string"/>

</root>', '{}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130016, '996996', 'profile', '', 'R', 'pre', 'text     ', '富士通想定患者プロファイル', 'Egmain-GX', 'テスト用', '1', '<root name="患者プロファイル(pre)">

    <item  name="電文種別" len="2" col="電文種別" type="string"/>

    <item  name="レコード継続指示" len="1" col="レコード継続指示" type="string"/>

    <item  name="送信先システムコード" len="2" col="送信先システムコード" type="string"/>

    <item  name="発信元システムコード" len="2" col="発信元システムコード" type="string"/>

    <item  name="処理情報.処理年月日" len="8" col="処理情報.処理年月日" type="string"/>

    <item  name="処理情報.処理時刻" len="6" col="処理情報.処理時刻" type="string"/>

    <item  name="端末名" len="8" col="端末名" type="string"/>

    <item  name="利用者番号" len="8" col="利用者番号" type="string"/>

    <item  name="処理区分" len="2" col="処理区分" type="string"/>

    <item  name="応答種別" len="2" col="応答種別" key="応答種別" type="string"/>

    <item  name="電文長" len="6" col="電文長" type="string"/>

    <item  name="エラーコード" len="5" col="エラーコード" type="string"/>

    <item  name="予備" len="12" col="予備" type="string"/>

    <item  name="患者情報.患者番号" len="10" col="患者情報.患者番号" type="string"/>

    <item  name="患者情報.患者漢字氏名" len="30" col="患者情報.患者漢字氏名" type="string"/>

    <item  name="患者情報.患者カナ氏名" len="60" col="患者情報.患者カナ氏名" type="string"/>

    <item  name="患者情報.患者性別" len="1" col="患者情報.患者性別" type="string"/>

    <item  name="患者情報.患者生年月日" len="8" col="患者情報.患者生年月日" type="string"/>

    <item  name="患者情報.郵便番号１" len="3" col="患者情報.郵便番号１" type="string"/>

    <item  name="患者情報.郵便番号２" len="4" col="患者情報.郵便番号２" type="string"/>

    <item  name="患者情報.患者住所" len="40" col="患者情報.患者住所" type="string"/>

    <item  name="患者情報.患者住所詳細" len="60" col="患者情報.患者住所詳細" type="string"/>

    <item  name="患者情報.電話番号" len="15" col="患者情報.電話番号" type="string"/>

    <item  name="入院情報.入外区分" len="1" col="入院情報.入外区分" type="string"/>

    <item  name="入院情報.入院診療科コード" len="3" col="入院情報.入院診療科コード" type="string"/>

    <item  name="入院情報.入院中病棟" len="3" col="入院情報.入院中病棟" type="string"/>

    <item  name="入院情報.入院中部屋" len="5" col="入院情報.入院中部屋" type="string"/>

    <item  name="入院情報.入院中ベッドコード" len="2" col="入院情報.入院中ベッドコード" type="string"/>

    <occ  name="保険情報" len="0" repeat="30"/>

    <occ  name="患者プロファイル" len="0" repeat="99"/>

    <item  name="終端" len="1" col="終端" type="string"/>

</root>

', '{"key": {"応答種別": {"N1": "正常以外", "N2": "正常以外", "N3": "正常以外", "N4": "正常以外", "NG": "正常以外", "OK": "正常"}}}', '1', '0', -1, '2019-12-23 06:35:38', '2020-01-14 11:01:43.398');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130015, '996996', 'profile', '', 'R', '正常', 'text     ', '富士通想定患者プロファイル', 'Egmain-GX', 'テスト用', '1', '<root name="患者プロファイル(正常)">

    <item  name="電文種別" len="2" type="string"/>

    <item  name="レコード継続指示" len="1" type="string"/>

    <item  name="送信先システムコード" len="2" type="string"/>

    <item  name="発信元システムコード" len="2" type="string"/>

    <item  name="処理情報.処理年月日" len="8" type="string"/>

    <item  name="処理情報.処理時刻" len="6" type="string"/>

    <item  name="端末名" len="8" type="string"/>

    <item  name="利用者番号" len="8" col="pat_main.charge_user_info.staff_id" type="string"/>

    <item  name="処理区分" len="2" type="string"/>

    <item  name="応答種別" len="2" type="string"/>

    <item  name="電文長" len="6" type="string"/>

    <item  name="エラーコード" len="5" type="string"/>

    <item  name="予備" len="12" type="string"/>

    <item  name="患者情報.患者番号" len="10" col="pat_personal_main.hosp_pat_id" type="string"/>

    <item  name="患者情報.患者漢字氏名" len="30" col="pat_personal_main.pat_last_name" type="string"/>

    <item  name="患者情報.患者カナ氏名" len="60" col="pat_personal_main.pat_last_name_kana" type="string"/>

    <item  name="患者情報.患者性別" len="1" col="pat_personal_main.pat_sex" type="string"/>

    <item  name="患者情報.患者生年月日" len="8" col="pat_personal_main.pat_birthday" type="string"/>

    <item  name="患者情報.郵便番号１" len="3" col="pat_personal_main.pat_contact_info.zip_cd" type="string"/>

    <item  name="患者情報.郵便番号２" len="4" col="pat_personal_main.pat_contact_info.zip_cd" type="string"/>

    <item  name="患者情報.患者住所" len="40" col="pat_personal_main.pat_contact_info.address" type="string"/>

    <item  name="患者情報.患者住所詳細" len="60" col="pat_personal_main.pat_contact_info.address" type="string"/>

    <item  name="患者情報.電話番号" len="15" col="pat_personal_main.pat_contact_info.tel1" type="string"/>

    <item  name="入院情報.入外区分" len="1" col="pat_personal_main.in_out_class" type="string"/>

    <item  name="入院情報.入院診療科コード" len="3" col="pat_unique.medical_care_info.main_course_cd" type="string"/>

    <item  name="入院情報.入院中病棟" len="3" col="pat_unique.medical_care_info.ward_cd" type="string"/>

    <item  name="入院情報.入院中部屋" len="5" type="string"/>

    <item  name="入院情報.入院中ベッドコード" len="2" type="string"/>

    <occ  name="保険情報" len="0" repeat="30" detail="保険情報詳細"/>

    <occ  name="患者プロファイル" len="0" repeat="99" detail="患者プロファイル詳細"/>

    <item  name="終端" len="1" type="string"/>

</root>

', '{}', '1', '0', -1, '2019-12-23 06:35:38', '2020-01-14 11:01:43.398');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130014, '996996', 'profile', '', 'R', '正常以外', 'text     ', '富士通想定患者プロファイル', 'Egmain-GX', 'テスト用', '1', '<root name="患者プロファイル(接続異常)">

    <item  name="電文種別" len="2" type="string"/>

    <item  name="レコード継続指示" len="1" type="string"/>

    <item  name="送信先システムコード" len="2" type="string"/>

    <item  name="発信元システムコード" len="2" type="string"/>

    <item  name="処理情報.処理年月日" len="8" type="string"/>

    <item  name="処理情報.処理時刻" len="6" type="string"/>

    <item  name="端末名" len="8" type="string"/>

    <item  name="利用者番号" len="8" type="string"/>

    <item  name="処理区分" len="2" type="string"/>

    <item  name="応答種別" len="2" type="string"/>

    <item  name="電文長" len="6" type="string"/>

    <item  name="エラーコード" len="5" type="string"/>

    <item  name="予備" len="12" type="string"/>

    <item  name="患者情報.患者番号" len="10" type="string"/>

    <item  name="患者情報.患者漢字氏名" len="30" type="string"/>

    <item  name="患者情報.患者カナ氏名" len="60" type="string"/>

    <item  name="患者情報.患者性別" len="1" type="string"/>

    <item  name="患者情報.患者生年月日" len="8" type="string"/>

    <item  name="患者情報.郵便番号１" len="3" type="string"/>

    <item  name="患者情報.郵便番号２" len="4" type="string"/>

    <item  name="患者情報.患者住所" len="40" type="string"/>

    <item  name="患者情報.患者住所詳細" len="60" type="string"/>

    <item  name="患者情報.電話番号" len="15" type="string"/>

    <item  name="入院情報.入外区分" len="1" type="string"/>

    <item  name="入院情報.入院診療科コード" len="3" type="string"/>

    <item  name="入院情報.入院中病棟" len="3" type="string"/>

    <item  name="入院情報.入院中部屋" len="5" type="string"/>

    <item  name="入院情報.入院中ベッドコード" len="2" type="string"/>

    <item  name="保険情報" len="3270" type="string"/>

    <item  name="患者プロファイル" len="10593" type="string"/>

    <item  name="終端" len="1" type="string"/>

</root>

', '{}', '1', '0', -1, '2019-12-23 06:35:38', '2020-01-14 11:01:43.398');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130013, '996996', 'rep_dial', '', 'S', 'cre', 'text', 'fujitsu', 'fujitsu', 'report', '1', '<root name="透析レポート">

    <item  name="電文種別" len="2" value="const:VR"/>

    <item  name="レコード継続指示" len="1" value="const:E"/>

    <item  name="送信先システムコード" len="2" value="const:XX"/>

    <item  name="発信元システムコード" len="2" value="const:VN"/>

    <item  name="処理年月日" len="8" value="$sysdate"/>

    <item  name="処理時刻" len="6" value="$systime"/>

    <item  name="端末名" len="8" value="const:VOSERVER"/>

    <item  name="利用者番号" len="8" value="dataset:-22.staff_cd"/>

    <item  name="処理区分" len="2" value="const:01"/>

    <item  name="応答種別" len="2" value="$BLANK"/>

    <item  name="電文長" len="6" value="$length"/>

    <item  name="エラーコード" len="5" value="$BLANK"/>

    <item  name="予備" len="12" value="$BLANK"/>

    <item  name="患者番号" len="10" value="dataset:1.hosp_pat_id"/>

    <item  name="実施日時" len="14" value="dataset:-11.start_date"/>

    <item  name="オーダ番号" len="8" value="$journal.coop_ord_no"/>

    <item  name="部門発生文書番号(文書種別）" len="4" value="const:RP01"/>

    <item  name="部門発生文書番号（オーダ番号）" len="8" value="$journal.coop_ord_no"/>

    <item  name="部門発生文書番号（末尾）" len="18" value="$journal.ord_no"/>

    <item  name="オーダ番号発番日" len="8" value="const:00000000"/>

    <item  name="結果状態" len="1" value="const:1"/>

    <item  name="報告書状態" len="1" value="const:1"/>

    <item  name="入外区分" len="1" value="dataset:-11.in_out_class"/>

    <item  name="部署（診療科）" len="3" value="dataset:-11.course_cd"/>

    <item  name="病棟" len="3" value="dataset:-11.ward_cd"/>

    <item  name="文書種別" len="4" value="const:RP01"/>

    <item  name="文書タイトル" len="50" value="const:透析レポート"/>

    <item  name="コメント" len="50" value="const:コメント"/>

    <item  name="フォーマットタイプ" len="3" value="const:HTM"/>

    <item  name="ツールパラメタ" len="512" value="$BLANK"/>

    <item  name="イメージフラグ" len="1" value="const:1"/>

    <item  name="ブラウザツールID" len="4" value="$BLANK"/>

    <item  name="報告者" len="20" value="auth_id:-22.staff_cd"/>

    <item  name="報告者ID" len="8" value="dataset:-22.staff_cd"/>

    <item  name="報告部署" len="3" value="const:1"/>

    <item  name="報告日時" len="14" value="dataset:-11.up_date14"/>

    <item  name="実施者" len="20" value="auth_id:-22.staff_cd"/>

    <item  name="実施者ID" len="8" value="dataset:-22.staff_cd"/>

    <item  name="実施部署" len="3" value="const:1"/>

    <item  name="実施日時" len="14" value="dataset:-11.up_date14"/>

    <item  name="承認者" len="20" value="auth_id:-22.staff_cd"/>

    <item  name="承認者ID" len="8" value="dataset:-22.staff_cd"/>

    <item  name="承認日時" len="14" value="dataset:-11.up_date14"/>

    <item  name="承認状態" len="1" value="const:1"/>

    <item  name="ComLib連携フラグ" len="1" value="const:0"/>

    <item  name="レポート情報" len="12" value="const:&lt;EMBED src=&quot;"/>

    <item  name="レポート情報" len="20" value="dataset:-104.pdf_file"/>

    <item  name="レポート情報" len="29" value="const:&quot; width=&quot;100%&quot; height=&quot;100%&quot;&gt;"/>

    <item  name="終端" len="1" value="$XD"/>

</root>', '{"dataset": [{"patId": "patId", "sqlCode": 1}, {"patId": "patId", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -22}, {"ordNo": "ordNo", "sqlCode": -104}]}', '1', '0', 4, '2020-05-25 18:26:36.811', '2020-05-25 18:26:41.871');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130012, '996996', 'exam_rst', '', 'R', 'pre', 'text     ', '富士通想定透析初回申し込み', 'Egmain-GX', 'テスト用', '1', '<root name="検査結果(pre)">

    <item  name="電文種別" len="2" type="string"/>

    <item  name="レコード継続指示" len="1" type="string"/>

    <item  name="送信先システムコード" len="2" type="string"/>

    <item  name="発信元システムコード" len="2" type="string"/>

    <item  name="処理情報.処理年月日" len="8" type="string"/>

    <item  name="処理情報.処理時刻" len="6" type="string"/>

    <item  name="端末名" len="8" type="string"/>

    <item  name="利用者番号" len="8" type="string"/>

    <item  name="処理区分" len="2" type="string"/>

    <item  name="応答種別" len="2" type="string"/>

    <item  name="電文長" len="6" type="string"/>

    <item  name="エラーコード" len="5" type="string"/>

    <item  name="予備" len="12" type="string"/>

    <item  name="検査状態" len="2" type="string"/>

    <item  name="伝票情報.レポート種別" len="4" key="レポート種別" type="string"/>

    <item  name="伝票情報.文書番号" len="30" type="string"/>

    <item  name="版数" len="2" type="string"/>

    <item  name="枝番" len="4" type="string"/>

    <item  name="オーダ番号" len="8" type="string"/>

    <item  name="依頼日" len="8" type="string"/>

    <item  name="患者番号" len="10" type="string"/>

    <item  name="科コード" len="3" type="string"/>

    <item  name="入外区分" len="1" type="string"/>

    <item  name="病棟コード" len="3" type="string"/>

    <item  name="採取日" len="8" type="string"/>

    <item  name="採取時間" len="6" type="string"/>

    <item  name="依頼コメントコード" len="20" type="string"/>

    <item  name="ドクタコード" len="8" type="string"/>

    <item  name="フリーコメント" len="50" type="string"/>

    <item  name="フリーコメント" len="50" type="string"/>

    <item  name="画像フラグ" len="1" type="string"/>

    <item  name="生体情報.身長" len="5" type="string"/>

    <item  name="生体情報.体重" len="5" type="string"/>

    <item  name="生体情報.畜尿量" len="5" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <occ  name="検体情報" len="0" repeat="50"/>

    <occ  name="結果情報" len="0" repeat="300"/>

    <item  name="終端" len="1" type="string"/>

</root>', '{"key": {"レポート種別": {"ER01": "検体検査", "ER02": "一般細菌", "ER03": "抗酸菌", "ER04": "その他細菌"}}}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130011, '996996', 'exam_rst', '', 'R', '検体検査', 'text     ', '富士通想定透析初回申し込み', 'Egmain-GX', 'テスト用', '1', '<root name="検査結果(検体検査)">

    <item  name="電文種別" len="2" type="string"/>

    <item  name="レコード継続指示" len="1" type="string"/>

    <item  name="送信先システムコード" len="2" type="string"/>

    <item  name="発信元システムコード" len="2" type="string"/>

    <item  name="処理情報.処理年月日" len="8" type="string"/>

    <item  name="処理情報.処理時刻" len="6" type="string"/>

    <item  name="端末名" len="8" type="string"/>

    <item  name="利用者番号" len="8" type="string"/>

    <item  name="処理区分" len="2" col="pat_exam_main.is_del" type="string" value="json:{&quot;01&quot;:&quot;&quot;,&quot;02&quot;:&quot;&quot;,&quot;03&quot;:&quot;1&quot;}"/>

    <item  name="応答種別" len="2" type="string"/>

    <item  name="電文長" len="6" type="string"/>

    <item  name="エラーコード" len="5" type="string"/>

    <item  name="予備" len="12" type="string"/>

    <item  name="検査状態" len="2" col="pat_exam_main.reg_order_class" type="string"/>

    <item  name="伝票情報.レポート種別" len="4" type="string"/>

    <item  name="伝票情報.文書番号" len="30" type="string"/>

    <item  name="版数" len="2" type="string"/>

    <item  name="枝番" len="4" type="string"/>

    <item  name="オーダ番号" len="8" col="pat_exam_main.cop_order_no1" type="string"/>

    <item  name="依頼日" len="8" type="string"/>

    <item  name="患者番号" len="10" col="pat_personal_main.hosp_pat_id" type="string"/>

    <item  name="科コード" len="3" type="string"/>

    <item  name="入外区分" len="1" type="string"/>

    <item  name="病棟コード" len="3" type="string"/>

    <item  name="採取日" len="8" col="pat_exam_main.result_exam_date" type="string"/>

    <item  name="採取時間" len="6" col="pat_exam_main.result_exam_date" type="string"/>

    <item  name="依頼コメントコード" len="20" type="string"/>

    <item  name="ドクタコード" len="8" col="pat_exam_main.ind_user_id" type="string"/>

    <item  name="フリーコメント" len="50" col="pat_exam_main.result_comment" type="string"/>

    <item  name="フリーコメント" len="50" type="string"/>

    <item  name="画像フラグ" len="1" type="string"/>

    <item  name="生体情報.身長" len="5" type="string"/>

    <item  name="生体情報.体重" len="5" type="string"/>

    <item  name="生体情報.畜尿量" len="5" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <occ  name="検体情報" len="0" repeat="50" detail="検体情報詳細"/>

    <occ  name="結果情報" len="0" repeat="300" detail="結果情報詳細"/>

    <item  name="終端" len="1" type="string"/>

</root>', '{}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130010, '996996', 'exam_rst', '', 'R', '一般細菌', 'text     ', '富士通想定透析初回申し込み', 'Egmain-GX', 'テスト用', '1', '<root name="検査結果(一般細菌)">

    <item  name="電文種別" len="2" type="string"/>

    <item  name="レコード継続指示" len="1" type="string"/>

    <item  name="送信先システムコード" len="2" type="string"/>

    <item  name="発信元システムコード" len="2" type="string"/>

    <item  name="処理情報.処理年月日" len="8" type="string"/>

    <item  name="処理情報.処理時刻" len="6" type="string"/>

    <item  name="端末名" len="8" type="string"/>

    <item  name="利用者番号" len="8" type="string"/>

    <item  name="処理区分" len="2" type="string"/>

    <item  name="応答種別" len="2" type="string"/>

    <item  name="電文長" len="6" type="string"/>

    <item  name="エラーコード" len="5" type="string"/>

    <item  name="予備" len="12" type="string"/>

    <item  name="検査状態" len="2" type="string"/>

    <item  name="伝票情報.レポート種別" len="4" type="string"/>

    <item  name="伝票情報.文書番号" len="30" type="string"/>

    <item  name="版数" len="2" type="string"/>

    <item  name="枝番" len="4" type="string"/>

    <item  name="オーダ番号" len="8" type="string"/>

    <item  name="依頼日" len="8" type="string"/>

    <item  name="患者番号" len="10" type="string"/>

    <item  name="科コード" len="3" type="string"/>

    <item  name="入外区分" len="1" type="string"/>

    <item  name="病棟コード" len="3" type="string"/>

    <item  name="採取日" len="8" type="string"/>

    <item  name="採取時間" len="6" type="string"/>

    <item  name="依頼コメントコード" len="20" type="string"/>

    <item  name="ドクタコード" len="8" type="string"/>

    <item  name="フリーコメント" len="50" type="string"/>

    <item  name="フリーコメント" len="50" type="string"/>

    <item  name="画像フラグ" len="1" type="string"/>

    <item  name="生体情報.身長" len="5" type="string"/>

    <item  name="生体情報.体重" len="5" type="string"/>

    <item  name="生体情報.畜尿量" len="5" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <occ  name="検体情報" len="0" repeat="50" detail="検体情報詳細"/>

    <occ  name="結果情報" len="0" repeat="300" detail="結果情報詳細_空"/>

    <item  name="終端" len="1" type="string"/>

</root>', '{}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130009, '996996', 'exam_rst', '', 'R', '抗酸菌', 'text     ', '富士通想定透析初回申し込み', 'Egmain-GX', 'テスト用', '1', '<root name="検査結果(抗酸菌)">

    <item  name="電文種別" len="2" type="string"/>

    <item  name="レコード継続指示" len="1" type="string"/>

    <item  name="送信先システムコード" len="2" type="string"/>

    <item  name="発信元システムコード" len="2" type="string"/>

    <item  name="処理情報.処理年月日" len="8" type="string"/>

    <item  name="処理情報.処理時刻" len="6" type="string"/>

    <item  name="端末名" len="8" type="string"/>

    <item  name="利用者番号" len="8" type="string"/>

    <item  name="処理区分" len="2" type="string"/>

    <item  name="応答種別" len="2" type="string"/>

    <item  name="電文長" len="6" type="string"/>

    <item  name="エラーコード" len="5" type="string"/>

    <item  name="予備" len="12" type="string"/>

    <item  name="検査状態" len="2" type="string"/>

    <item  name="伝票情報.レポート種別" len="4" type="string"/>

    <item  name="伝票情報.文書番号" len="30" type="string"/>

    <item  name="版数" len="2" type="string"/>

    <item  name="枝番" len="4" type="string"/>

    <item  name="オーダ番号" len="8" type="string"/>

    <item  name="依頼日" len="8" type="string"/>

    <item  name="患者番号" len="10" type="string"/>

    <item  name="科コード" len="3" type="string"/>

    <item  name="入外区分" len="1" type="string"/>

    <item  name="病棟コード" len="3" type="string"/>

    <item  name="採取日" len="8" type="string"/>

    <item  name="採取時間" len="6" type="string"/>

    <item  name="依頼コメントコード" len="20" type="string"/>

    <item  name="ドクタコード" len="8" type="string"/>

    <item  name="フリーコメント" len="50" type="string"/>

    <item  name="フリーコメント" len="50" type="string"/>

    <item  name="画像フラグ" len="1" type="string"/>

    <item  name="生体情報.身長" len="5" type="string"/>

    <item  name="生体情報.体重" len="5" type="string"/>

    <item  name="生体情報.畜尿量" len="5" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <occ  name="検体情報" len="0" repeat="50" detail="検体情報詳細"/>

    <occ  name="結果情報" len="0" repeat="300" detail="結果情報詳細_空"/>

    <item  name="終端" len="1" type="string"/>

</root>', '{}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130008, '996996', 'exam_ord', '', 'S', 'cre', 'text', '富士通検査依頼', 'fujitsu', '検体検査依頼', '1', '<root name="検査依頼">

    <item  name="電文種別" value="const:VO"/>

    <item  name="レコード継続指示" value="const:E"/>

    <item  name="送信先システムコード" value="const:XX"/>

    <item  name="発信元システムコード" value="const:VN"/>

    <item  name="処理情報.処理年月日" value="$SYSDATE"/>

    <item  name="処理情報.処理時刻" value="$SYSTIME"/>

    <item  name="端末名" value="const:VOSERVER"/>

    <item  name="利用者番号" value="dataset:-26.staff_id"/>

    <item  name="処理区分" value="const:01"/>

    <item  name="応答種別" value="$BLANK"/>

    <item  name="電文長" value="$LENGTH"/>

    <item  name="エラーコード" value="$BLANK"/>

    <item  name="予備" value="$BLANK"/>

    <item  name="情報種別" value="const:03"/>

    <item  name="患者情報.患者番号" value="dataset:1.hosp_pat_id"/>

    <item  name="伝票情報.オーダ番号" value="$journal.coop_ord_no" padding_format="0"/>

    <item  name="伝票情報.文書番号(先頭8文字）" value="const:VOSERVER"/>

    <item  name="伝票情報.文書番号" value="$journal.ord_no" padding_format="0" padding_position="right"/>

    <item  name="伝票情報.文書番号(後2文字）" value="const:00"/>

    <item  name="伝票情報.文書版数" value="const:00"/>

    <item  name="伝票情報.関連オーダ番号" value="$BLANK"/>

    <item  name="伝票情報.オーダ日付" value="dataset:-23.exam_date"/>

    <item  name="伝票情報.オーダ時間" value="dataset:-23.exam_start_time"/>

    <item  name="伝票情報.保険パターン番号" value="const:10"/>

    <item  name="伝票情報.入外区分" value="dataset:-20.exam_in_out"/>

    <item  name="伝票情報.診療科コード" value="dataset:-11.course_cd"/>

    <item  name="伝票情報.病棟コード" value="dataset:-11.ward_cd"/>

    <item  name="伝票情報.利用者番号" value="dataset:-26.staff_id"/>

    <item  name="伝票情報.伝票コード" value="const:E001"/>

    <item  name="伝票情報.伝票名称" value="const:透析発生検査"/>

    <item  name="予約情報.予約グループCD" value="$BLANK"/>

    <item  name="予約情報.予約枠コード(頭）" value="$BLANK"/>

    <item  name="予約情報.予約枠コード" value="$BLANK"/>

    <item  name="予約情報.予約開始日" value="$BLANK"/>

    <item  name="予約情報.予約開始時間" value="$BLANK"/>

    <item  name="予約情報.予約終了日" value="$BLANK"/>

    <item  name="予約情報.予約終了時間" value="$BLANK"/>

    <occ  name="明細行数" len="4" detail="検査項目詳細" sqlCode="-25"/>

    <item  name="終端" value="$XOD"/>

</root>', '{"dataset": [{"patId": "patId", "sqlCode": 1}, {"patId": "patId", "sqlCode": -20}, {"ordNo": "ordNo", "sqlCode": -26}, {"ordNo": "ordNo", "sqlCode": -23}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -26}, {"ordNo": "ordNo", "sqlCode": -25}], "dumpFileName": {"patId": "patId", "sqlCode": -102}}', NULL, NULL, NULL, NULL, NULL);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130007, '996996', 'exam_rst', '', 'R', 'その他細菌', 'text     ', '富士通想定透析初回申し込み', 'Egmain-GX', 'テスト用', '1', '<root name="検査結果(その他細菌)">

    <item  name="電文種別" len="2" type="string"/>

    <item  name="レコード継続指示" len="1" type="string"/>

    <item  name="送信先システムコード" len="2" type="string"/>

    <item  name="発信元システムコード" len="2" type="string"/>

    <item  name="処理情報.処理年月日" len="8" type="string"/>

    <item  name="処理情報.処理時刻" len="6" type="string"/>

    <item  name="端末名" len="8" type="string"/>

    <item  name="利用者番号" len="8" type="string"/>

    <item  name="処理区分" len="2" type="string"/>

    <item  name="応答種別" len="2" type="string"/>

    <item  name="電文長" len="6" type="string"/>

    <item  name="エラーコード" len="5" type="string"/>

    <item  name="予備" len="12" type="string"/>

    <item  name="検査状態" len="2" type="string"/>

    <item  name="伝票情報.レポート種別" len="4" type="string"/>

    <item  name="伝票情報.文書番号" len="30" type="string"/>

    <item  name="版数" len="2" type="string"/>

    <item  name="枝番" len="4" type="string"/>

    <item  name="オーダ番号" len="8" type="string"/>

    <item  name="依頼日" len="8" type="string"/>

    <item  name="患者番号" len="10" type="string"/>

    <item  name="科コード" len="3" type="string"/>

    <item  name="入外区分" len="1" type="string"/>

    <item  name="病棟コード" len="3" type="string"/>

    <item  name="採取日" len="8" type="string"/>

    <item  name="採取時間" len="6" type="string"/>

    <item  name="依頼コメントコード" len="20" type="string"/>

    <item  name="ドクタコード" len="8" type="string"/>

    <item  name="フリーコメント" len="50" type="string"/>

    <item  name="フリーコメント" len="50" type="string"/>

    <item  name="画像フラグ" len="1" type="string"/>

    <item  name="生体情報.身長" len="5" type="string"/>

    <item  name="生体情報.体重" len="5" type="string"/>

    <item  name="生体情報.畜尿量" len="5" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <occ  name="検体情報" len="0" repeat="50" detail="検体情報詳細"/>

    <occ  name="結果情報" len="0" repeat="300" detail="結果情報詳細_空"/>

    <item  name="終端" len="1" type="string"/>

</root>', '{}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130006, '996996', 'other', 'send_time', 'S', 'cre', 'text     ', '定時一括送信機能（テスト）', 'fujitsu', 'テスト用', '1', '<root name="検査結果(pre)">

    <item  name="電文種別" len="2" type="string"/>

    <item  name="レコード継続指示" len="1" type="string"/>

    <item  name="送信先システムコード" len="2" type="string"/>

    <item  name="発信元システムコード" len="2" type="string"/>

    <item  name="処理情報.処理年月日" len="8" type="string"/>

    <item  name="処理情報.処理時刻" len="6" type="string"/>

    <item  name="端末名" len="8" type="string"/>

    <item  name="利用者番号" len="8" type="string"/>

    <item  name="処理区分" len="2" type="string"/>

    <item  name="応答種別" len="2" type="string"/>

    <item  name="電文長" len="6" type="string"/>

    <item  name="エラーコード" len="5" type="string"/>

    <item  name="予備" len="12" type="string"/>

    <item  name="検査状態" len="2" type="string"/>

    <item  name="伝票情報.レポート種別" len="4" key="レポート種別" type="string"/>

    <item  name="伝票情報.文書番号" len="30" type="string"/>

    <item  name="版数" len="2" type="string"/>

    <item  name="枝番" len="4" type="string"/>

    <item  name="オーダ番号" len="8" type="string"/>

    <item  name="依頼日" len="8" type="string"/>

    <item  name="患者番号" len="10" type="string"/>

    <item  name="科コード" len="3" type="string"/>

    <item  name="入外区分" len="1" type="string"/>

    <item  name="病棟コード" len="3" type="string"/>

    <item  name="採取日" len="8" type="string"/>

    <item  name="採取時間" len="6" type="string"/>

    <item  name="依頼コメントコード" len="20" type="string"/>

    <item  name="ドクタコード" len="8" type="string"/>

    <item  name="フリーコメント" len="50" type="string"/>

    <item  name="フリーコメント" len="50" type="string"/>

    <item  name="画像フラグ" len="1" type="string"/>

    <item  name="生体情報.身長" len="5" type="string"/>

    <item  name="生体情報.体重" len="5" type="string"/>

    <item  name="生体情報.畜尿量" len="5" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <occ  name="検体情報" len="0" repeat="50"/>

    <occ  name="結果情報" len="0" repeat="300"/>

    <item  name="終端" len="1" type="string"/>

</root>', '{"key": {"レポート種別": {"ER01": "検体検査", "ER02": "一般細菌", "ER03": "抗酸菌", "ER04": "その他細菌"}}}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130005, '996996', 'exam_rst', 'send_time', 'S', 'cre', 'text     ', '定時一括送信機能（透析初回申し込み用）', 'fujitsu', 'テスト用', '1', '<root name="検査結果(pre)">

    <item  name="電文種別" len="2" type="string"/>

    <item  name="レコード継続指示" len="1" type="string"/>

    <item  name="送信先システムコード" len="2" type="string"/>

    <item  name="発信元システムコード" len="2" type="string"/>

    <item  name="処理情報.処理年月日" len="8" type="string"/>

    <item  name="処理情報.処理時刻" len="6" type="string"/>

    <item  name="端末名" len="8" type="string"/>

    <item  name="利用者番号" len="8" type="string"/>

    <item  name="処理区分" len="2" type="string"/>

    <item  name="応答種別" len="2" type="string"/>

    <item  name="電文長" len="6" type="string"/>

    <item  name="エラーコード" len="5" type="string"/>

    <item  name="予備" len="12" type="string"/>

    <item  name="検査状態" len="2" type="string"/>

    <item  name="伝票情報.レポート種別" len="4" key="レポート種別" type="string"/>

    <item  name="伝票情報.文書番号" len="30" type="string"/>

    <item  name="版数" len="2" type="string"/>

    <item  name="枝番" len="4" type="string"/>

    <item  name="オーダ番号" len="8" type="string"/>

    <item  name="依頼日" len="8" type="string"/>

    <item  name="患者番号" len="10" type="string"/>

    <item  name="科コード" len="3" type="string"/>

    <item  name="入外区分" len="1" type="string"/>

    <item  name="病棟コード" len="3" type="string"/>

    <item  name="採取日" len="8" type="string"/>

    <item  name="採取時間" len="6" type="string"/>

    <item  name="依頼コメントコード" len="20" type="string"/>

    <item  name="ドクタコード" len="8" type="string"/>

    <item  name="フリーコメント" len="50" type="string"/>

    <item  name="フリーコメント" len="50" type="string"/>

    <item  name="画像フラグ" len="1" type="string"/>

    <item  name="生体情報.身長" len="5" type="string"/>

    <item  name="生体情報.体重" len="5" type="string"/>

    <item  name="生体情報.畜尿量" len="5" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="負荷情報.負荷物コード" len="2" type="string"/>

    <item  name="負荷情報.負荷量" len="4" type="string"/>

    <item  name="負荷情報.負荷時間" len="4" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <item  name="投与薬剤情報.投与薬剤コード" len="5" type="string"/>

    <item  name="投与薬剤情報.投与日" len="8" type="string"/>

    <item  name="投与薬剤情報.投与時間" len="6" type="string"/>

    <occ  name="検体情報" len="0" repeat="50"/>

    <occ  name="結果情報" len="0" repeat="300"/>

    <item  name="終端" len="1" type="string"/>

</root>', '{"key": {"レポート種別": {"ER01": "検体検査", "ER02": "一般細菌", "ER03": "抗酸菌", "ER04": "その他細菌"}}}', '1', '0', -1, '2019-12-13 05:44:54', '2019-12-13 05:44:54');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130004, '996996', 'profile', 'send_time', 'S', 'cre', 'text     ', '定時一括送信機能（患者プロファイル用）', 'fujitsu', 'テスト用', '1', '<root name="患者情報要求">

    <item  name="共通部.電文種別" len="2" value="const:VO"/>

    <item  name="共通部.レコード継続指示" len="1" value="const:E"/>

    <item  name="共通部.送信先システムコード" len="2" value="const:XX"/>

    <item  name="共通部.発信元システムコード" len="2" value="const:VN"/>

    <item  name="共通部.処理日時.処理年月日" len="8" value="$SYSDATE"/>

    <item  name="共通部.処理日時.処理時間" len="6" value="$SYSTIME"/>

    <item  name="共通部.端末名" len="8" value="const:VOSERVER"/>

    <item  name="共通部.利用者番号" len="8" value="const:        "/>

    <item  name="共通部.処理区分" len="2" value="const:01"/>

    <item  name="共通部.応答種別" len="2" value="$BLANK"/>

    <item  name="共通部.電文長" len="6" value="$LENGTH"/>

    <item  name="共通部.エラーコード" len="5" value="$BLANK"/>

    <item  name="共通部.予備" len="12" value="$BLANK"/>

    <item  name="内容部.患者情報.患者番号" len="10" value="$JOURNAL.hosp_pat_id"/>

    <item  name="終端" len="1" value="$CR"/>

</root>', '{"dataset": [{"patId": "patId", "sqlCode": -999}]}', '1', '0', -2, '2020-01-21 08:29:41.74', '2020-01-21 08:29:41.74');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130003, '996996', 'profile', '', 'S', 'cre', 'text     ', '富士通想定患者プロファイル', 'Medicom', 'プロファイル', '1', '<root name="患者情報要求">

    <item  name="共通部.電文種別" len="2" value="const:VO"/>

    <item  name="共通部.レコード継続指示" len="1" value="const:E"/>

    <item  name="共通部.送信先システムコード" len="2" value="const:XX"/>

    <item  name="共通部.発信元システムコード" len="2" value="const:VN"/>

    <item  name="共通部.処理日時.処理年月日" len="8" value="$SYSDATE"/>

    <item  name="共通部.処理日時.処理時間" len="6" value="$SYSTIME"/>

    <item  name="共通部.端末名" len="8" value="const:VOSERVER"/>

    <item  name="共通部.利用者番号" len="8" value="const:        "/>

    <item  name="共通部.処理区分" len="2" value="const:01"/>

    <item  name="共通部.応答種別" len="2" value="$BLANK"/>

    <item  name="共通部.電文長" len="6" value="$LENGTH"/>

    <item  name="共通部.エラーコード" len="5" value="$BLANK"/>

    <item  name="共通部.予備" len="12" value="$BLANK"/>

    <item  name="内容部.患者情報.患者番号" len="10" value="$JOURNAL.hosp_pat_id"/>

    <item  name="終端" len="1" value="$CR"/>

</root>', '{"dataset": [{"patId": "patId", "sqlCode": -999}]}', '1', '0', -2, '2020-01-21 08:29:41.74', '2020-01-21 08:29:41.74');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130002, '996996', 'rad_ord', '', 'S', 'cre', 'text', '富士通撮影依頼', 'fujitsu', '撮影依頼', '1', '<root name="検査依頼">

    <item  name="電文種別" value="const:VO"/>

    <item  name="レコード継続指示" value="const:E"/>

    <item  name="送信先システムコード" value="const:XX"/>

    <item  name="発信元システムコード" value="const:VN"/>

    <item  name="処理情報.処理年月日" value="$SYSDATE"/>

    <item  name="処理情報.処理時刻" value="$SYSTIME"/>

    <item  name="端末名" value="const:VOSERVER"/>

    <item  name="利用者番号" value="dataset:-27.staff_id"/>

    <item  name="処理区分" value="const:01"/>

    <item  name="応答種別" value="$BLANK"/>

    <item  name="電文長" value="$LENGTH"/>

    <item  name="エラーコード" value="$BLANK"/>

    <item  name="予備" value="$BLANK"/>

    <item  name="情報種別" value="const:04"/>

    <item  name="患者情報.患者番号" value="dataset:1.hosp_pat_id"/>

    <item  name="伝票情報.オーダ番号" value="$journal.coop_ord_no" padding_format="0"/>

    <item  name="伝票情報.文書番号(先頭8文字）" value="const:VOSERVER"/>

    <item  name="伝票情報.文書番号" value="$journal.ord_no" padding_format="0" padding_position="right"/>

    <item  name="伝票情報.文書番号(後2文字）" value="const:00"/>

    <item  name="伝票情報.文書版数" value="const:00"/>

    <item  name="伝票情報.関連オーダ番号" value="$BLANK"/>

    <item  name="伝票情報.オーダ日付" value="dataset:-23.exam_date"/>

    <item  name="伝票情報.オーダ時間" value="dataset:-23.exam_start_time"/>

    <item  name="伝票情報.保険パターン番号" value="const:10"/>

    <item  name="伝票情報.入外区分" value="dataset:-20.exam_in_out"/>

    <item  name="伝票情報.診療科コード" value="dataset:-11.course_cd"/>

    <item  name="伝票情報.病棟コード" value="dataset:-11.ward_cd"/>

    <item  name="伝票情報.利用者番号" value="dataset:-27.staff_id"/>

    <item  name="伝票情報.伝票コード" value="const:F001"/>

    <item  name="伝票情報.伝票名称" value="const:透析発生放射線"/>

    <item  name="予約情報.予約グループCD" value="$BLANK"/>

    <item  name="予約情報.予約枠コード(頭）" value="$BLANK"/>

    <item  name="予約情報.予約枠コード" value="$BLANK"/>

    <item  name="予約情報.予約開始日" value="$BLANK"/>

    <item  name="予約情報.予約開始時間" value="$BLANK"/>

    <item  name="予約情報.予約終了日" value="$BLANK"/>

    <item  name="予約情報.予約終了時間" value="$BLANK"/>

    <occ  name="明細行数" len="4" detail="撮影項目" sqlCode="-28"/>

    <item  name="終端" value="$XOD"/>

</root>', '{"dataset": [{"patId": "patId", "sqlCode": 1}, {"patId": "patId", "sqlCode": -20}, {"ordNo": "ordNo", "sqlCode": -26}, {"ordNo": "ordNo", "sqlCode": -23}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -26}, {"ordNo": "ordNo", "sqlCode": -28}], "dumpFileName": {"patId": "patId", "sqlCode": -102}}', '1', '0', 4, '2020-05-12 18:19:40.183', '2020-05-12 18:19:44.638');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-4130001, '996996', 'exam_ord', '', 'S', 'upd', 'text', '富士通検査依頼', 'fujitsu', '検体検査依頼', '1', '<root name="検査依頼">

    <item  name="電文種別" value="const:VO"/>

    <item  name="レコード継続指示" value="const:E"/>

    <item  name="送信先システムコード" value="const:XX"/>

    <item  name="発信元システムコード" value="const:VN"/>

    <item  name="処理情報.処理年月日" value="$SYSDATE"/>

    <item  name="処理情報.処理時刻" value="$SYSTIME"/>

    <item  name="端末名" value="const:VOSERVER"/>

    <item  name="利用者番号" value="dataset:-26.staff_id"/>

    <item  name="処理区分" value="const:02"/>

    <item  name="応答種別" value="$BLANK"/>

    <item  name="電文長" value="$LENGTH"/>

    <item  name="エラーコード" value="$BLANK"/>

    <item  name="予備" value="$BLANK"/>

    <item  name="情報種別" value="const:03"/>

    <item  name="患者情報.患者番号" value="dataset:1.hosp_pat_id"/>

    <item  name="伝票情報.オーダ番号" value="$journal.coop_ord_no" padding_format="0"/>

    <item  name="伝票情報.文書番号(先頭8文字）" value="const:VOSERVER"/>

    <item  name="伝票情報.文書番号" value="$journal.ord_no" padding_format="0" padding_position="right"/>

    <item  name="伝票情報.文書番号(後2文字）" value="const:00"/>

    <item  name="伝票情報.文書版数" value="const:00"/>

    <item  name="伝票情報.関連オーダ番号" value="$BLANK"/>

    <item  name="伝票情報.オーダ日付" value="dataset:-23.exam_date"/>

    <item  name="伝票情報.オーダ時間" value="dataset:-23.exam_start_time"/>

    <item  name="伝票情報.保険パターン番号" value="const:10"/>

    <item  name="伝票情報.入外区分" value="dataset:-20.exam_in_out"/>

    <item  name="伝票情報.診療科コード" value="dataset:-11.course_cd"/>

    <item  name="伝票情報.病棟コード" value="dataset:-11.ward_cd"/>

    <item  name="伝票情報.利用者番号" value="dataset:-26.staff_id"/>

    <item  name="伝票情報.伝票コード" value="const:E001"/>

    <item  name="伝票情報.伝票名称" value="const:透析発生検査"/>

    <item  name="予約情報.予約グループCD" value="$BLANK"/>

    <item  name="予約情報.予約枠コード(頭）" value="$BLANK"/>

    <item  name="予約情報.予約枠コード" value="$BLANK"/>

    <item  name="予約情報.予約開始日" value="$BLANK"/>

    <item  name="予約情報.予約開始時間" value="$BLANK"/>

    <item  name="予約情報.予約終了日" value="$BLANK"/>

    <item  name="予約情報.予約終了時間" value="$BLANK"/>

    <occ  name="明細行数" len="4" detail="検査項目" sqlCode="-25"/>

    <item  name="終端" value="$XOD"/>

</root>', '{"dataset": [{"patId": "patId", "sqlCode": 1}, {"patId": "patId", "sqlCode": -20}, {"ordNo": "ordNo", "sqlCode": -26}, {"ordNo": "ordNo", "sqlCode": -23}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -26}, {"ordNo": "ordNo", "sqlCode": -25}], "dumpFileName": {"patId": "patId", "sqlCode": -102}}', NULL, NULL, NULL, NULL, NULL);
