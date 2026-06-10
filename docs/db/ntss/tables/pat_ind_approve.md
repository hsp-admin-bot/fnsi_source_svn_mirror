# pat_ind_approve

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `pat_ind_approve`
- Logical name: 指示受け承認情報
- Physical name: `pat_ind_approve`
- Prefix group: `patient`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ord_no`
- Column count: 22
- NOT NULL columns: 1

## Related Config / Notes

- [../config/pat_ind_approve.md](../config/pat_ind_approve.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | オーダ番号 | ord_no | bigint |  | 1 |  |  |
|  | 指示受け者1 | check_user1_cd | bigint |  |  |  |  |
|  | 指示受け者2 | check_user2_cd | bigint |  |  |  |  |
|  | 指示承認者1 | approve_user1_cd | bigint |  |  |  |  |
|  | 指示承認者2 | approve_user2_cd | bigint |  |  |  |  |
|  | 指示受け日時1 | check_user1_time | timestamp(3) |  |  |  |  |
|  | 指示受け日時2 | check_user2_time | timestamp(3) |  |  |  |  |
|  | 指示承認日時1 | approve_user1_time | timestamp(3) |  |  |  |  |
|  | 指示承認日時2 | approve_user2_time | timestamp(3) |  |  |  |  |
|  | 登録日 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日 | up_date | timestamp(3) |  |  |  |  |
|  | 指示受け変更ありフラグ | is_content_changed | character varying | 1 |  |  | 0:内容変更なし、１：内容変更あり |
|  | 指示承認変更ありフラグ | is_content_appd_changed | character varying | 1 |  |  | 0:内容変更なし、１：内容変更あり |
|  | 治療単位指示受け時指示内容 | check_content | jsonb |  |  |  | @pat_ind_approveシートで参考 |
|  | 治療単位指示承認時指示内容 | approve_content | jsonb |  |  |  | @pat_ind_approveシートで参考 |
|  | 指示受けフラグ1 | is_user1_checked | character varying | 1 |  |  | １：チェック済、０：未チェック |
|  | 指示受けフラグ2 | is_user2_checked | character varying | 1 |  |  | １：チェック済、０：未チェック |
|  | 指示承認フラグ1 | is_user1_approved | character varying | 1 |  |  | １：承認済、０：未承認 |
|  | 指示承認フラグ2 | is_user2_approved | character varying | 1 |  |  | １：承認済、０：未承認 |
|  | 治療状況マップ指示変更ありフラグ | is_content_changed_for_map | character varying | 1 |  |  | 0:内容変更なし、１：内容変更あり<br><br>条件送信時、または治療状況マップでの確認時に0とする |
|  | 治療状況マップ確認時指示内容 | content_for_map | jsonb | 1 |  |  | @pat_ind_approveシートで参考<br><br>条件送信時、または治療状況マップでの確認時に記録 |
|  | 施設コード | facility_cd | character varying | 6 |  |  | mst_facility.facility_cd |
