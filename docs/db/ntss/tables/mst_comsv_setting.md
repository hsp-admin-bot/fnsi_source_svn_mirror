# mst_comsv_setting

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_comsv_setting`
- Logical name: 通信サーバー設定
- Physical name: `mst_comsv_setting`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `comsv_cd`
- Column count: 38
- NOT NULL columns: 3

## Related Config / Notes

- [../config/mst_comsv_setting.md](../config/mst_comsv_setting.md)
- [../config/mst_comsv_setting-detail.md](../config/mst_comsv_setting-detail.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 通信サーバー管理コード | comsv_cd | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
|  | デバイスエッジ番号 | device_edge_no | numeric | 2,0 | 1 |  |  |
|  | 新通信一斉時刻合わせ | is_timeset | character varying | 1 |  | '0' | '0':OFF（無効）、'1':ON（有効） |
|  | 新通信一斉時刻合わせ時刻 | timeset_time | character varying | 4 |  |  | 10:30 → '1030' |
|  | NX通信一斉時刻合わせ | is_timeset_nx | character varying | 1 |  | '0' | '0':OFF（無効）、'1':ON（有効） |
|  | NX通信一斉時刻合わせ時刻 | timeset_nx_time | character varying | 4 |  |  | 10:30 → '1030' |
|  | 仮想端末ログ時間 | lcd_log_time | character varying | 1 |  | '0' | '0':時刻、'1':経過 |
|  | 仮想端末ログ内容 | lcd_log_type | character varying | 1 |  | '0' | '0':ログ、'1':愁訴処置 |
|  | 仮想端末投与時間帯表示 | is_lcd_medi | character varying | 1 |  | '0' | '0':OFF（無効）、'1':ON（有効） |
|  | 排液判定待機時間 | end_wait_time | smallint |  |  |  | 秒 |
|  | 患者切り替えタイミング | pat_timing | character varying | 1 |  | '0' | '0':後体重測定、'1':実績初版確定 |
|  | お知らせ機能 | is_notice | character varying | 1 |  |  | '0':OFF（無効）、'1':ON（有効） |
|  | お知らせ機能補正時間 | notice_time | smallint |  |  |  | 秒 |
|  | ログのアップロード実施時刻 | log_upload_time | character varying | 4 |  |  | 10:30 → '1030' |
|  | オフライン運転自動開始時間 | offline_start_time | smallint |  |  |  | 秒 nullは手動のみ |
|  | オフライン運転自動終了 | is_offline_auto_end | character varying | 1 |  | 0' | 0':しない、'1':する |
|  | 日付変更時次患者更新時刻 | reload_next_pat_time | character varying | 4 |  | 0100' | 01:00 → '0100' |
|  | 次患者送信モード | next_pat_mode | smallint |  |  | 1 | １：施設すべてベッドを対象に期間内で直近の予定がある透析日の次患者を表示<br>２：ベッドごとの期間内の直近の次患者を表示 |
|  | 次患者検索期間 | next_pat_mode_range | smallint |  |  | 7 | 日 次患者送信モード1および2で検索する期間 |
|  | 装置生存監視時間 | device_timeout | smallint |  |  | 60 | 秒 |
|  | 治療中モニタ通知間隔 | treat_moni_interval | smallint |  |  | 900 | 秒 |
|  | 治療外モニタ通知間隔 | other_moni_interval | smallint |  |  | 3600 | 秒 |
|  | 仮想端末メニュー表示設定 | lcd_menu | jsonb |  |  |  | ※別紙参照（仮想端末メニュー） |
|  | 次患者情報表示設定 | lcd_npat | jsonb |  |  |  |  |
|  | 透析日報表示設定 | lcd_report | jsonb |  |  |  |  |
|  | 検査１グラフ表示設定 | lcd_graph1 | jsonb |  |  |  |  |
|  | 検査２グラフ表示設定 | lcd_graph2 | jsonb |  |  |  |  |
|  | 検査レーダーチャート表示設定 | lcd_radar | jsonb |  |  |  |  |
|  | 仮想端末スタッフ一覧 | lcd_staff_list | jsonb |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 投薬変更のお知らせ | is_notice_medi | character varying | 0 |  | '0' | 0':知らせない、'1':知らせ |
|  | 治療中リアルタイムモニタ通知間隔 | treat_realtime_monito_interval | smallint |  |  | 0 | 秒 |
|  | 治療外リアルタイムモニタ通知間隔 | other_realtime_monito_interval | smallint |  |  | 0 | 秒 |
|  | 次患者情報2段組表示 | next_pat_splitarea | character varying | 1 |  | '0' | 0':1段組、'1':2段組 |
