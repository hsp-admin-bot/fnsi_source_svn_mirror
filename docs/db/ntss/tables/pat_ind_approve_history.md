# pat_ind_approve_history

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `pat_ind_approve_history`
- Logical name: 指示受け・承認詳細
- Physical name: `pat_ind_approve_history`
- Prefix group: `patient`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ind_approve_history_no`
- Column count: 12
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 指示受け承認履歴番号 | ind_approve_history_no | bigserial |  | 1 |  |  |
|  | オーダ番号 | ord_no | bigint |  | 1 |  |  |
|  | 指示受け承認区分 | approve_kind | character varying | 1 |  |  | 1：指示受け1、2：指示受け2、3：指示承認1、4：指示承認2 |
|  | 変更前指示受け承認者 | approve_bef_id | bigint |  |  |  | 変更前の指示受け1,2、指示承認1,2で指定されたユーザーID |
|  | 変更後指示受け承認者 | approve_aft_id | bigint |  |  |  | 変更後の指示受け1,2、指示承認1,2で指定されたユーザーID |
|  | 操作者 | user_id | bigint |  |  |  | 登録したユーザーアカウント |
|  | 登録区分 | sign_type | character varying | 1 |  |  | 0：解除、1：設定 |
|  | 登録日 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日 | up_date | timestamp(3) |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0':非表示、'1':表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':有効、'1':削除 |
|  | 施設コード | facility_cd | character varying | 6 |  |  | mst_facility.facility_cd |
