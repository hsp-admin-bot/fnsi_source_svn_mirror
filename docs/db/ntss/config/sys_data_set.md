# sys_data_set

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@sys_data_set`
- Category: config/reference

## Content

| col1 | col2 | col3 |
| --- | --- | --- |
| 詳細（detail） |  |  |
| [{ |  |  |
| data_category | String | データカテゴリ |
| data_class | String | データクラス |
| data_code | String | データ項目コード(全体通して一意) |
| data_name | String | データ項目名 |
| field_name | String | フィールド名 |
| conv_table | JSON | 変換リスト：下記① |
| data_type | String | データ型 |
| preview | String | プレビューデータ |
| disp_format | String | 既定の書式 |
| can_calc | String | 計算式内使用可否 |
| facility_filter_type | String | 使用する施設指定/使用しない施設指定 |
| facility_table | String | 施設コード配列　（※要検討） |
| label_classes | Number[] | この項目が印刷できるラベル分類識別子の配列。<br>［帳票デザイナー］［分類別情報編集］で［分類別情報］項目のための設定。この項目が属するラベル分類を設定する。複数指定可。<br>ラベル分類と識別子の対応は、<br>ダイアライザ: 1, 吸着カラム: 2, 抗凝固剤: 3, 透析液: 4, 補液: 5, 1次膜・2次膜: 6, 薬剤: 7, 医材: 8, 穿刺針: 9。 |
| conv_sql | JSON | 取得した値を変数にして値を取得する他SQL設定（下記②） |
| filter_type | String | 適用できるフィルターの種類。例."Medicine", "Equip", "Event", ""(フィルタなし) など。 |
| },..] |  |  |
| ①conv_table |  |  |
| [{ |  |  |
| code | String | 値 |
| item | String | 候補　（例：”男”） |
| disp | String | 出力文字列　（例：”♂”） |
| },..] |  |  |
| ②conv_sql |  |  |
| { |  |  |
| sql_cd | Number | 実行するSQLコード（sys_data_set.sql_cd） |
| target_var | String | 他SQLに渡す際の変数名 |
| field_name | String | 他SQLから取得するデータ項目名 |
| } |  |  |
| 事前取得データ情報（pre_sql_info） |  |  |
| [{ |  |  |
| sql_cd | Number | 実行するSQLコード（sys_data_set.sql_cd） |
| replace_var | String | 取得するSQL変数名 |
| field_name | String | 他SQLから取得するデータ項目名 |
| },...] |  |  |
| 使用用途（use_application） |  |  |
| { |  |  |
| applications | Number配列 | [1, 2,...]。対象となるレコードを使用する機能<br>帳票=1, 患者イベントテンプレートマスタ=2, 患者イベント実績=3,連携=4,外部view共有=5 |
| } |  |  |
| 帳票種別（report_class） |  |  |
| { |  |  |
| classes | Number配列 | [1, 2,...]。対象となるレコードを使用する帳票種別。<br>透析レポート=1, 単患者帳票=2, 複数患者帳票=3, 準備リスト=4, 配布リスト(ベッド)=5, 配布リスト(物品)=6, 装置帳票=7, ラベル=8, 紹介状=9 |
| } |  |  |
| MongoDB関連 |  |  |
| MongoDB場合、項目「SQL」の設定： |  |  |
| collection | テーブル名 |  |
| eq | Where条件「=」 |  |
| ne | Where条件「<>」 |  |
| gt | Where条件「>」 |  |
| lt | Where条件「<」 |  |
| gte | Where条件「>=」 |  |
| lte | Where条件「<=」 |  |
| sort | ソート項目 |  |
| 例えば: | {"collection": "ind_history", "eq": {"pat_id": "000001", "facility_cd": "1"}, "gte": {"sort_no": "1"}, "lt": {"sort_no": "3"}，"sort": {"sort_no": "desc", "treatment_end_date": "asc"}} |  |
| 説明： | テーブル[ind_history]から、条件「(pat_id='000001' AND facility_cd = '1') AND (sort_no >=1 AND sort_no<3) 」が一致のデータを取得する。 |  |
|  | 取得したデータは「sort_no desc AND treatment_end_date asc」で並べ替えます。 |  |
