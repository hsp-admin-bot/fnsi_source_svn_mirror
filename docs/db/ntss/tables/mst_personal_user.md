# mst_personal_user

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_personal_user`
- Logical name: 利用者マスタ
- Physical name: `mst_personal_user`
- Prefix group: `master`
- User: `nkk6`
- Tablespace DB: `ntss_db6`
- Tablespace INDEX: `ntss_index6`
- Primary key definition: `user_id`
- Column count: 31
- NOT NULL columns: 3

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 利用者ID（内部用ID） | user_id | bigserial |  | 1 |  | シーケンス使用 |
|  | 施設コード | facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード |
|  | 利用者種別 | user_type | numeric | 2,0 |  |  | 0:一般ユーザ、1:日機装ユーザ、2:システム用アカウント |
|  | 管理者フラグ | administrator | numeric | 2,0 |  |  | 0:一般ユーザ、1:管理者ユーザ |
|  | 利用者名_姓 | user_last_name | character varying |  | 1 |  | 今までの利用者名(user_name)を姓名で分割<br>暗号化対象 |
|  | 利用者名_名 | user_first_name | character varying |  | 1 |  | 暗号化対象 |
|  | 利用者カナ名_姓 | user_last_name_kana | character varying |  |  |  | 暗号化対象 |
|  | 利用者カナ名_名 | user_first_name_kana | character varying |  |  |  | 暗号化対象 |
|  | 利用者英字名_姓 | user_last_name_alpha | character varying |  |  |  | 暗号化対象 |
|  | 利用者英字名_名 | user_first_name_alpha | character varying |  |  |  | 暗号化対象 |
|  | メールアドレス1 | user_email_address_1 | character varying |  |  |  | 暗号化対象 |
|  | メールアドレス2 | user_email_address_2 | character varying |  |  |  | 暗号化対象 |
|  | 内線番号 | extension_no | character varying |  |  |  | 暗号化対象 |
|  | 自宅番号 | home_no | character varying |  |  |  | 暗号化対象 |
|  | 携帯番号 | mobile_phone_no | character varying |  |  |  | 暗号化対象 |
|  | FAX番号 | fax_no | character varying |  |  |  | 暗号化対象 |
|  | 郵便番号3 | zipcd_3 | character varying |  |  |  | 暗号化対象 |
|  | 郵便番号4 | zipcd_4 | character varying |  |  |  | 暗号化対象 |
|  | 自宅住所 | address | character varying |  |  |  | 暗号化対象 |
|  | 自宅住所かな | address_kana | character varying |  |  |  | 暗号化対象 |
|  | 職種コード | job_cd | character varying |  |  |  | 暗号化対象 |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 院内コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
|  | 管理者への表示許可 | info_disp_to_admin | character varying | 1 |  | '0' | '0'：非表示、'1'：表示 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | FNW+で管理する施設内の一意なスタッフコード | fn_staff_cd | character varying | 10 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | 麻薬施用者免許証番号 | anesthesiologist_license_no | character varying |  |  |  | 暗号化対象 |
|  | サインイン日時 | signin_date | timestamp(3) |  |  |  |  |
