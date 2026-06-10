# mst_mainte_detail_hst

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_mainte_detail_hst`
- Logical name: 日常・定期点検項目マスタ履歴
- Physical name: `mst_mainte_detail_hst`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `mainte_detail_cd`
- Column count: 15
- NOT NULL columns: 2

## Related Tables

- Related table: [../tables/mst_mainte_detail.md](../tables/mst_mainte_detail.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 点検詳細品目コード | mainte_detail_cd | bigserial |  | 1 |  | シーケンス |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | カテゴリコード | mainte_category_cd | bigint |  |  |  | 定期点検時：見出し |
|  | 内容１ | mainte_content_1 | character varying |  |  |  | 定期点検時：項目文 |
|  | 内容２ | mainte_content_2 | character varying |  |  |  | 定期点検時：基準文、部品名 |
|  | 内容３ | mainte_content_3 | character varying |  |  |  | 定期点検時：交換推奨時間 |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 版数 | edition_no | integer |  |  | 1 | 版数 |
|  | 用途 | mainte_class | character varying | 1 |  |  | 1:日常点検　2:定期点検 |
|  | 回答パターン | ans_pattern | character varying | 1 |  |  | 0:日常点検  1:定期点検  2:チェック |
|  | 補足コメント有無 | is_cmt | character varying | 1 |  |  | 0,コメントなし<br>1:コメント要 |
|  | 初期展開テキスト | ini_text | character varying |  |  |  | 補足コメント有無が１の時に補足コメント欄に初期表示するコメント。<br>改行して表示できるようにすること。<br>値が存在する場合、日常・点検画面にテキストエリア―を表現する |
