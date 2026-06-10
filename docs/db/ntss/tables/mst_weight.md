# mst_weight

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_weight`
- Logical name: 体重計マスタ
- Physical name: `mst_weight`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `weight_cd`
- Column count: 26
- NOT NULL columns: 3

## Related Config / Notes

- [../config/mst_weight.md](../config/mst_weight.md)
- [../config/mst_weight_print.md](../config/mst_weight_print.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 体重計管理コード | weight_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
|  | 体重計番号 | weight_no | smallint |  | 1 |  |  |
|  | 体重計名称 | weight_name | character varying |  |  |  |  |
|  | 体重計接続ポート | port_name | character varying | 10 |  |  | ポート名（自動接続できそうならば不要） |
|  | 体重計機種 | device_class | numeric | 1,0 |  |  | 0:A&D、1:田中衡機、2:ヤマトハカリ |
|  | 前体重自動送信 | is_auto_send_before | character varying | 1 |  |  | 0':無効、'1':有効 |
|  | 後体重自動送信 | is_auto_send_after | character varying | 1 |  |  | 0':無効、'1':有効 |
|  | 前体重自動送信待ち時間 | wait_auto_send_before | smallint |  |  |  | 秒 |
|  | 後体重自動送信待ち時間 | wait_auto_send_after | smallint |  |  |  | 秒 |
|  | 前体重印刷初期状態 | is_default_print_before | character varying | 1 |  |  | 0':印刷しない、'1':印刷する |
|  | 後体重印刷初期状態 | is_default_print_after | character varying | 1 |  |  | 0':印刷しない、'1':印刷する |
|  | 使用プリンター | printer_class | smallint |  |  |  | 0:TM-88Ⅳ、1:TM-L90、2:KIOSK |
|  | 所属透析室 | bed_group_cd | integer |  |  |  | mst_room.bed_group_cd (group_class = 2) |
|  | カードリーダー有無 | is_has_card_reader | character varying | 1 |  |  | 0':なし、'1':あり |
|  | 体重測定チェック項目 | check_content | jsonb |  |  |  | ※@mst_weight |
|  | 印字設定項目 | print_setting | jsonb |  |  |  | ※@mst_weight |
|  | 配色設定項目 | color_setting | jsonb |  |  |  | ※@mst_weight |
|  | 音声再生設定項目 | audio_setting | jsonb |  |  |  | ※@mst_weight |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 測定値送信間隔 | data_send_interval | smallint |  |  |  | 秒<br>(田中衡機の場合、体重計アプリから画面にデータ送信間隔設定。田中衡機以外の場合NULL設定) |
|  | 初期データ表示種別 | data_select_type | character varying | 1 |  |  | 0'：最新値、'1'：最小値、'2'：最大値<br>(田中衡機以外の場合NULL設定) |
|  | 電文フォーマット | telegram_format | jsonb |  |  |  | ※@mst_weight |
