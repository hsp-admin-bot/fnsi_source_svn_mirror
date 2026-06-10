# mst_weight

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_weight`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 |
| --- | --- | --- | --- |
| 体重測定チェック項目 |  |  |  |
| [{ |  |  |  |
| ctl_no | Number | 識別子 |  |
| disp_order | Number | 表示順 |  |
| is_disable | String | "1": 使用しない その他：使用する（初期値） |  |
| name | String | 項目名 |  |
| use_condition | Number | 表示条件 0:常に表示 1:満たす場合に表示 2:満たさない場合に表示 |  |
| condition_left | String | 条件左辺 |  |
| condition_right | String | 条件右辺 |  |
| condition_ineq | Number | 条件比較式 0: > 1: >= 2: == 3: != 4: <= 5: < |  |
| before_word | String | 表示メッセージ前半 |  |
| after_word | String | 表示メッセージ後半 |  |
| calculate | String | 計算式 |  |
| decimal_point | Number | 小数点桁数 |  |
| is_check_warn | Boolean | 正常範囲チェック有無フラグ |  |
| min_warn | Number | 最小警告値 |  |
| max_warn | Number | 最大警告値 |  |
| is_disp_before | Boolean | 前体重画面表示フラグ |  |
| is_disp_after | Boolean | 後体重画面表示フラグ |  |
| sendable | Number | 条件送信制限 0:制限なし 1:正常範囲外確認チェック 2:正常範囲外送信不可 3:表示時確認チェック 4:表示時送信不可 |  |
| is_print | [Boolean,Boolean,Boolean,Boolean] | [前体重印字対象フラグ、後体重印字対象フラグ、スケジュール無し印字対象フラグ、患者未登録印字対象フラグ] |  |
| print_datatype | Number | 印字時のデータタイプ 0:number 1:date 2:text |  |
| print_default_format | String | 印字時の初期フォーマット 例：数値で少数2桁「3.2」 日付「YYYYMMDD」 |  |
| }..] |  |  |  |
| 印字設定項目 |  |  |  |
| レイヤ１ |  |  |  |
| before | JSON | 前体重印字設定 |  |
| after | JSON | 後体重印字設定 |  |
| no_shcedule | JSON | スケジュール未確定印字設定 |  |
| no_pat | JSON | 患者未確定印字設定 |  |
| レイヤ２ |  |  |  |
| [{ |  |  |  |
| ctl_no | Number | 識別子 |  |
| disp_order | Number | 表示順 |  |
| item_source | Number | 項目のソース　0:プリセットの印刷項目 1:検査項目 2:チェック設定項目 |  |
| item_cd | Number | ソースによって参照先が変わる |  |
| font_size | Number | 0: 小 1: 中 2: 大 |  |
| data_type | Number | 印字時のデータタイプ 0:number 1:date 2:text 3:日付+印刷位置 |  |
| data_format | String | フォーマット書式　（数値データ時で整数部3桁+小数2桁の場合 "3.2"、日付データの場合 YYYY/MM/DDなど |  |
| date_position | Number | 日付印字位置（検査項目用） 0:前 1:後 |  |
| before_word | String | 前方文字列 |  |
| after_word | String | 後方文字列 |  |
| calculate | String | 計算式（チェック設定項目使用時） |  |
| }..] |  |  |  |
| 配色設定項目 |  |  |  |
| { |  |  |  |
| form | String | フォーム背景色 #RRGGBB | いまのところ背景のみ |
| } |  |  |  |
| 音声ガイダンス設定項目 |  |  |  |
| { |  |  |  |
| pat_ok | String | 患者認識 "1":再生する "0": 再生しない |  |
| pat_ok_delay | Number | 患者認識再生遅延時間 |  |
| receive_weight | String | 体重読み込み時 "1":再生する "0": 再生しない |  |
| receive_weight_delay | Number | 体重読み込み時再生遅延時間 |  |
| send_ok | String | 送信完了 "1":再生する "0": 再生しない |  |
| send_ok_delay | Number | 送信完了再生遅延時間 |  |
| send_ng | String | 送信失敗 "1":再生する "0": 再生しない |  |
| send_ng_delay | Number | 送信失敗再生遅延時間 |  |
| } |  |  |  |
| 電文フォーマット |  |  |  |
| { |  |  |  |
| telegram_format | String | 電文フォーマット |  |
| } |  |  |  |
