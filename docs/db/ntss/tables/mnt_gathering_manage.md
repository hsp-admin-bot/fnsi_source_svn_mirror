# mnt_gathering_manage

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mnt_gathering_manage`
- Logical name: データ収集管理
- Physical name: `mnt_gathering_manage`
- Prefix group: `maintenance-state`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `gathering_manage_no`
- Column count: 11
- NOT NULL columns: 3

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | データ収集管理番号 | gathering_manage_no | bigserial |  | 1 |  | シーケンス使用 |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | データ収集ステータス | gathering_status | numeric | 1,0 | 1 |  | ステータス<br>　-2：一部異常<br>　-1：異常<br>　0：依頼中<br>　1：処理中<br>　2：転送完了 |
|  | データ収集情報 | gathering_info | jsonb |  |  |  | 【※1】参照 |
|  | 操作情報 | ope_info | numeric | 1,0 |  |  | 0：自動収集<br>1：手動収集<br>2：失敗時の再要求（データ収集に失敗した装置のみ再要求し、失敗時のデータ収集管理番号を「親管理番号」カラムに格納） |
|  | 親管理番号 | parent_manage_no | bigint |  |  |  | 1～：親管理番号（データ収集に失敗したデータ収集管理番号） |
|  | 利用者ID | user_id | bigint |  |  |  | 利用者マスタ.利用者ID（内部用ID） |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
| "machine_no"：[型式コード][通信フォーマット][製造番号] |  |  | ★比較時はTrim後に比較すること |  |  |  |  |
| "machine_no"：[型式コード][通信フォーマット][製造番号] |  |  | ★比較時はTrim後に比較すること |  |  |  |  |
