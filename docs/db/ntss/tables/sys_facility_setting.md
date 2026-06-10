# sys_facility_setting

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_facility_setting`
- Logical name: システム施設設定
- Physical name: `sys_facility_setting`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_setting_no`
- Column count: 12
- NOT NULL columns: 4

## Related Config / Notes

- [../config/sys_facility_setting.md](../config/sys_facility_setting.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設設定番号 | facility_setting_no | character varying | 4 | 1 |  | 旧mst_facility_settingの管理番号 |
|  | 設定名称 | setting_name | character varying | 256 |  |  | 旧mst_facility_settingの名称 |
|  | 初期値 | default_value | character varying |  |  |  |  |
|  | 入力分類 | input_type | numeric | 1 | 1 |  | 1:テキストボックス<br>2:数値型<br>3:ON/OFFトグル<br>4:プルダウンリスト（複数ケースより選択）<br>5:プルダウンリスト（mst_selectorから参照）<br>6:テキストエリア（複数行対応）<br>7:マルチセレクト（複数選択対応）<br>9:指示者選択用プルダウンリスト |
|  | オプション情報 | option_value | character varying |  |  |  | 入力方法<br>　2:数値型：最小と最大値定義<br>　4:プルダウンリスト：<br>　選択肢名称／選択時の格納値　を定義<br>　5:mst_selectorから参照：<br>　参照先のマスタ物理名称 を定義 |
|  | 機能名 | function_name | character varying | 256 |  |  | 機能名<br>旧機能コードと同じ用途に使用。<br>検索用名称として使用する |
|  | 操作権限可否 | maker_setting | numeric | 1 | 1 |  | 対象ユーザーの<br>mst_personal_user.user_typeに応じた操作権限設定<br><br>0：user_typeにかかわらず、操作可能<br>1：user_type=1 一覧表示で操作可／user_type=0は一覧非表示で操作不可<br>2：user_typeの設定内容に関わらず、非表示 |
|  | 設定説明 | description | character varying |  |  |  |  |
|  | 表示順 | disp_order | numeric | 5 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | システム利用表示区分 | system_use_disp | character varying | 1 | 1 |  | 当該施設設定を利用するシステムを設定する<br><br>1:ReMS<br>2:FNSi<br>3:共通<br><br>施設マスタのシステム利用設定が<br>FNSi＋ReMSの場合、共通・FNSi・ReMSの項目を表示。<br>FNSiの場合、共通・FNSiを表示。ReMSの項目を非表示。<br>ReMSの場合、共通・ReMSを表示。FNSiの項目を非表示。 |
