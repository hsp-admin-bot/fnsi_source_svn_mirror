# mnt_facility_cancel_manage

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mnt_facility_cancel_manage`
- Logical name: テーブル名(論理名)
- Physical name: `mnt_facility_cancel_manage`
- Prefix group: `maintenance-state`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ctl_no`
- Column count: 12
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | ctl_no | bigserial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  |  |
|  | 処理区分 | proc_class | character varying | 1 |  |  | 1: 施設解約<br>2: 期間外削除<br>3: ReMSのみ解約<br>4: FNSiのみ解約 |
|  | 処理対象期間 | proc_period | bigint |  |  |  | 削除対象の期間（月）mst_facilityと同じ。<br>当日-この月数、より前のデータが削除される<br>null: 全て |
|  | 処理開始日 | st_date | timestamp(3) |  |  |  | 施設解約：解約日<br>期間外削除：基準日 |
|  | 統計情報 | stats | jsonb |  |  |  | {<br>    "tables" : [<br>       "end": 終了日時<br>        "start": 開始日次<br>        "amount": 対象総数<br>        "deleted": 削除件数<br>        "db_class": sys_data_set.db_classに準ずる<br>        "db_name": データベース名<br>        "backup_start": バックアップ開始日時<br>        "backup_end": バックアップ終了日時<br>        "backup_path": バックアップ取得先<br>        "table_name": テーブル名<br>        "time_column_name": 期間外削除でするしきい値カラム<br>        "alias_column_name": 解約で使用するfacility_cdの別名カラム<br>    ]<br>} |
|  | ステータス | proc_status | character varying | 1 |  | '0' | '0': 処理待機 <br>'1' : バックアップ作成中<br>'2': バックアップ作成済<br>'3': 削除実行中<br>'9' : 完了 <br>'E' : エラー <br>'C': キャンセル |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 統計情報(NoSQLDB) | stats_nosql | jsonb |  |  |  | {<br>    "tables" : [<br>       "end": 終了日時<br>        "start": 開始日次<br>        "amount": 対象総数<br>        "deleted": 削除件数<br>        "backup_start": バックアップ開始日時<br>        "backup_end": バックアップ終了日時<br>        "backup_path": バックアップ取得先<br>        "table_name": テーブル名<br>    ]<br>} |
