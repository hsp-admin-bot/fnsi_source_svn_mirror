# mst_pat_search_detail

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_pat_search_detail`
- Logical name: 詳細患者検索マスタ
- Physical name: `mst_pat_search_detail`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `search_cd`
- Column count: 9
- NOT NULL columns: 4

## Related Config / Notes

- [../config/mst_pat_search_detail.md](../config/mst_pat_search_detail.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 詳細患者検索コード | search_cd | bigserial |  | 1 |  | シーケンス |
|  | 利用者ID | user_id | bigint |  | 1 |  | 利用者マスタ.利用者ID（内部用ID） |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
|  | 詳細患者検索名 | search_name | character varying |  | 1 |  |  |
|  | 検索条件内容 | search_condition | jsonb |  |  |  | @mst_pat_search_detailシートで参考 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' |  |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
