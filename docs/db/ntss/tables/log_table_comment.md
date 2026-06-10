# log_table_comment

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `log_table_comment`
- Logical name: テーブル論理名設定テーブル
- Physical name: `log_table_comment`
- Prefix group: `log`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `tbl_name,col_name`
- Column count: 9
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | テーブル物理名 | tbl_name | character varying | 50 | 1 |  |  |
|  | テーブル論理名 | tbl_comment | character varying | 100 | 1 |  |  |
| 1 | コラム物理名 | col_name | character varying | 50 |  |  |  |
|  | コラム論理名 | col_comment | character varying | 100 |  |  |  |
|  | JSONフラグ | json_flg | character varying | 1 |  |  | 1：Json 0：Jsonがない |
|  | キーステップ | keystep | numeric |  |  |  | 例：<br>{<br>  a1:{<br>     b:{<br>        c:01<br>        }<br>   a2:{<br>      b:{<br>         d:01<br>      }<br>}<br>keystep=1場合<br>　jsonキー：c,d<br>上記以外場合<br>　jsonキー：a1.b.c,a2.b.d |
|  | PKフラグ | pk_flg | numeric |  |  |  | 1：PK　1以外：PKではない |
|  | 削除フラグ | delete_flg | numeric |  |  |  | 1：削除　1以外：削除しない |
|  | 治療情報履歴登録フラグ | ord_main_hst_ins_flg | numeric |  |  |  | 1：登録　1以外：登録しない |
