# mst_pat_event_data_template

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_pat_event_data_template`
- Category: config/reference

## Content

| col1 | col2 | col3 |
| --- | --- | --- |
| 項目情報 |  |  |
| [{ |  |  |
| format_class | Number | 項目フォーマット<br><br>0: テキスト<br>1: テキストエリア<br>2: 画像<br>3: リスト選択<br>4:ラジオボタン<br>5:日付<br>6:チェックボックス<br>7:添付ファイル<br>8:スコア計算<br>9.治療実績リンク<br>10:掲示板リンク |
| field_name | String | フィールド名称 |
| is_field_display | String | フィールド名表示フラグ '0':非表示 '1':表示 |
| is_rst_copy | String | 未来方向の予定にも実績を展開するフラグ '0':無効 '1':有効<br>（format_class=9,10では設定値を使用されない、常に無効） |
| item_json | JSON | 設定項目 |
| }..] |  |  |
| 設定項目 | テキスト |  |
| { |  |  |
| max_length | Number | 最大文字数 |
| default_value | String | デフォルト値 |
| sql_cd | Number | データ取得元 sys_data_set のシーケンス |
| source_field | String | データ取得元  sys_data_set のフィールド名称 |
| } |  |  |
| 設定項目 | テキストエリア |  |
| { |  |  |
| max_length | Number | 最大文字数 |
| default_value | String | デフォルト値 |
| is_formatting | String | 書式設定フラグ '0':不可能 '1':可能 |
| sql_cd | Number | データ取得元 sys_data_set のシーケンス |
| source_field | String | データ取得元  sys_data_set のフィールド名称 |
| } |  |  |
| 設定項目 | 画像 |  |
| { |  |  |
| image_num | Number | 画像数 |
| image_col_num | Number | 画像列数 |
| values | JSON配列 | 画像名称(画像数と同じ数の配列) |
| } |  |  |
|  | values |  |
| [{ |  |  |
| name | String | 画像名 |
| }...] |  |  |
| 設定項目 | リスト項目 |  |
| { |  |  |
| sql_cd | Number | データ取得元 sys_data_set のシーケンス |
| source_field | String | データ取得元  sys_data_set のフィールド名称 |
| values | JSON配列 | 下記 |
| } |  |  |
|  | values |  |
| [{ |  |  |
| name | String | リスト名 |
| score | Number | スコア |
| }...] |  |  |
| 設定項目 | ラジオボタン |  |
| { |  |  |
| values | JSON配列 | 下記 |
| } |  |  |
| [{ |  |  |
| name | String | 項目名 |
| score | Number | スコア |
| }...] |  |  |
| 設定項目 | 日付 |  |
| { |  |  |
| date_class | String | 日付デフォルト値<br>"0": 指定なし<br>"1":操作当日 |
| } |  |  |
| 設定項目 | チェックボックス |  |
| { |  |  |
| values | JSON配列 | 下記 |
| } |  |  |
| [{ |  |  |
| name | String | 項目名 |
| score | Number | スコア |
| }...] |  |  |
| 設定項目 | 添付ファイル |  |
| { |  |  |
| max_size | Number | 最大サイズ【KB】 |
| } |  |  |
| 設定項目 | スコア計算 |  |
| { |  |  |
| calc | String | 計算式 |
| unit | String | 単位 |
| } |  |  |
| 設定項目 | 治療実績リンク |  |
| { |  |  |
| } |  |  |
| 設定項目 | 掲示板リンク |  |
| { |  |  |
| kind_no | number | 掲示板種別（bbs-infoの同名カラムと同じ） |
| } |  |  |
