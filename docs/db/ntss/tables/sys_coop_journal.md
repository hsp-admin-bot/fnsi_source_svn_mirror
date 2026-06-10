# sys_coop_journal

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_coop_journal`
- Logical name: 外部連携用ジャーナル
- Physical name: `sys_coop_journal`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ctl_no`
- Column count: 23
- NOT NULL columns: 10

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ctl_no | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | 電文種別 | coop_cd | character varying | 20 | 1 |  | 電文種別（機能）の名称 |
|  | 付帯情報（電文） | coop_cd_index | character varying | 10 | 1 | '' | （IBM)電文種別の付帯情報<br>レポート等にも使う? |
|  | 作成更新区分 | crud | character varying | 1 | 1 |  | C:新規   U:更新    D:削除 |
|  | 向き（送受信） | direction | character varying | 1 | 1 |  | S:送信　R:受信 |
|  | （次世代FN)オーダ番号 | ord_no | bigint |  |  |  | システムから付番したオーダ番号 |
|  | （連携先)オーダ番号 | coop_ord_no | character varying |  |  |  | カルテから付番されてきたオーダ番号 |
|  | 患者番号（連携用） | hosp_pat_id | character varying | 12 |  |  | hosp_pat_id |
|  | 患者番号（システム） | pat_id | bigint |  |  |  | pat_id |
|  | 変換処理ステータス | ana_result | character varying | 2 | 1 | '0' | 0:未処理<br>1:処理中<br>9:処理完了<br><br>S:スキップ<br>E1:内部エラー（NKK内部処理でのエラー）<br>E2:外部エラー（電カルからのエラーリターン。ないと思う） |
|  | 変換処理開始日時 | in_ana_date | timestamp(3) |  |  |  |  |
|  | 変換処理完了日時 | out_ana_date | timestamp(3) |  |  |  |  |
|  | 配信処理ステータス | coop_result | character varying | 2 | 1 | '0' | 0:未処理<br>1:処理中<br>8:応答待ち<br>9:処理完了<br><br>R:リトライ<br>S:スキップ<br>E1:内部エラー（NKK内部処理でのエラー９<br>E2:外部エラー（電カルからのエラーリターン） |
|  | 配信処理開始日時 | in_reg_date | timestamp(3) |  |  |  |  |
|  | 配信処理完了日時 | out_reg_date | timestamp(3) |  |  |  |  |
|  | 電文パス | dump_path | character varying |  |  |  | 電文ファイルの格納されている共有ﾌｫﾙﾀﾞへのリンク |
|  | 電文内容 | dump | bytea |  |  |  | 電文の中身 |
|  | 編集可否フラグ | is_editable | character varying | 1 | 1 | '1' | '0'：編集不可、'1'：編集可 |
|  | 削除フラグ | is_del | character varying | 1 | 1 | '0' | '0':通常、'1':削除 |
|  | 操作者ID | user_id | bigint |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
