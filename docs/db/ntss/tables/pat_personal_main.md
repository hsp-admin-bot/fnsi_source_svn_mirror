# pat_personal_main

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `pat_personal_main`
- Logical name: 患者個人情報
- Physical name: `pat_personal_main`
- Prefix group: `patient`
- User: `nkk6`
- Tablespace DB: `ntss_db6`
- Tablespace INDEX: `ntss_index6`
- Primary key definition: `pat_id`
- Column count: 40
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意な患者ID | pat_id | bigserial |  | 1 |  | シーケンス使用<br><br>↓ 10/24-26 打ち合わせ内容(DocBase)<br>システムで管理する一意な患者ID(pat_id)<br>型：character varing⇒bigserial<br>↑ここまで |
|  | FNW+で管理する施設内の一意な患者ID | fn_pat_id | character varying | 12 |  |  | FNW+フィードバック用 |
|  | 院内表示用の患者ID | hosp_pat_id | character varying | 12 |  |  | 本テーブルでのみ参照可<br>※0埋めしない<br><br>↓ 10/24-26 打ち合わせ内容(DocBase)<br>院内表示用患者ID(hosp_pat_id)<br>0詰めしない<br>↑ここまで |
|  | 日機装内で管理する一意な患者ID | nkk_pat_id | character varying | 20 |  |  | ↓ 10/24-26 打ち合わせ内容(DocBase)<br>患者新規登録時に格納しない<br>↑ここまで |
|  | 登録施設コード | facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード |
|  | 患者氏名(漢字姓) | pat_last_name | character varying |  |  |  |  |
|  | 患者氏名(漢字名) | pat_first_name | character varying |  |  |  |  |
|  | 患者氏名(カタカナ姓) | pat_last_name_kana | character varying |  |  |  |  |
|  | 患者氏名(カタカナ名) | pat_first_name_kana | character varying |  |  |  |  |
|  | 患者氏名(英字姓) | pat_last_name_alpha | character varying |  |  |  |  |
|  | 患者氏名(英字名) | pat_first_name_alpha | character varying |  |  |  |  |
|  | 患者誕生時氏名(旧姓)(漢字) | pat_birth_name | character varying |  |  |  |  |
|  | 患者誕生時氏名(旧姓)(カタカナ) | pat_birth_name_kana | character varying |  |  |  |  |
|  | 患者誕生時氏名(旧姓)(英字) | pat_birth_name_alpha | character varying |  |  |  |  |
|  | 生年月日(YYYYMMDD) | pat_birthday | character varying | 8 |  |  |  |
|  | 性別 | pat_sex | smallint |  |  |  | 0：不明、1：男性、2：女性 |
|  | 国籍 | nationality | character varying | 3 |  |  | JIS X 0304:2011 3文字国名コード<br><br>↓ 10/24-26 打ち合わせ内容(DocBase)<br>国名コード（ISO 3166-1 alpha-3）※主キー<br>患者情報に持つコード<br>↑ここまで |
|  | 血液型ABO | pat_blood_type_abo | smallint |  |  |  | 0：不明、1：A型、2：B型、3：O型、4：AB型 |
|  | 血液型RH | pat_blood_type_rh | smallint |  |  |  | 0：不明、1：Rh＋、2：Rh－ |
|  | 血液型亜型 | pat_blood_type_serovar | smallint |  |  |  | 11：A1、12：Aint、13：A2、14：A3、15：Ax、16：Am、17：Ael、18：Aend、21：B1、22：Bint、23：B2、24：B3、25：Bx、26：Bm、27：Bel、28：Bend |
|  | 入外区分 | in_out_class | smallint |  |  |  | 0'：外来、'1'：入院、'2'：死亡、'3'：-(不在)<br>※不在は以下のいずれかの状態を表す<br>・離脱<br>・移植<br>・通院拒否・不明<br>・転出 |
|  | 死亡患者 | is_die | character varying | 1 |  |  | '0'：対象外、'1'：対象 |
|  | 死因コード | die_cd | integer |  |  |  | ↓ 10/24-26 打ち合わせ内容(DocBase)<br>死因情報<br>型：JSON⇒character varing<br>備考<br>死因マスタは廃止。<br>病名マスタで管理。<br>枠があった方が統計情報の取得が楽<br>死因設定は１枠だけの制御が楽<br>↑ここまで<br><br>※コードの型についてはmst_disease.disease_cd(serial)からintegerとする |
|  | 死亡日 | die_date | timestamp(3) |  |  |  |  |
|  | 透析困難情報 | dial_diff_com_info | jsonb |  |  |  | [<br>  {<br>    "ctl_no":管理番号<br>    "dial_diff_cd":透析困難コメントマスタ.透析困難コメントコード<br>    "is_main":主たる透析困難コメントフラグ ※'0'：主たる透析困難コメントではない、'1'：主たる透析困難コメント,<br>    "is_dial_diff": 透析困難フラグ<br>    "reg_date":登録日時<br>  }, …<br>]<br><br>↓ 10/24-26 打ち合わせ内容(DocBase)<br>透析困難<br><br>JSON形式<br>更新日時（全体の更新日時）<br>情報(JSON)<br>コード<br>主たるフラグ<br>登録日時<br>　※構成は任せる<br><br>透析困難の全体で排他をかける。<br>↑ここまで<br><br>※"is_dial_diff": 透析困難フラグを追加 |
|  | 重症度コード | severity_cd | integer |  |  |  | ↓ 10/24-26 打ち合わせ内容(DocBase)<br>重症度マスタ<br>一覧編集(Mode1)<br>重症度コードの型：character varing⇒(big)serial<br>施設コードは主キーでなくてもよい。ただし、インデックスの設定は必要<br>↑ここまで |
|  | 搬送区分コード | transport_cd | integer |  |  |  | ↓ 10/24-26 打ち合わせ内容(DocBase)<br>搬送区分マスタ<br>一覧編集(Mode1)<br>搬送区分コードの型：character varing⇒(big)serial<br>施設コードは主キーでなくてもよい。ただし、インデックスの設定は必要<br>↑ ここまで |
|  | 本人連絡先情報 | pat_contact_info | jsonb |  |  | E'{"zip_cd":null,"address":null,"tel1":null,"tel2":null,"fax":null,"e_mail":null,"work_name":null,"work_address":null,"work_tel":null,"memo1":null,"memo2":null}' | {<br>  "zip_cd":郵便番号,<br>  "address":住所,<br>  "tel1":電話番号1,<br>  "tel2":電話番号2,<br>  "fax":Fax番号,<br>  "e_mail":メールアドレス,<br>  "work_name":勤務先名,<br>  "work_tel":勤務先電話番号,<br>  "memo1":メモ1,<br>  "memo2":メモ2<br>} |
|  | 連絡先情報 | other_contact_info | jsonb |  |  |  | [<br>  {<br>    "ctl_no":管理番号,<br>    "disp_order":表示順,<br>    "is_key_person":キーパーソン,<br>    "pat_id":患者ID(登録患者指定時),<br>    "last_name":姓,<br>    "first_name":名,<br>    "last_name_kana":セイ,<br>    "first_name_kana":メイ,<br>    "relation_cd":続柄コード,<br>    "relation_name":続柄名,<br>    "zip_cd":郵便番号,<br>    "address":住所,<br>    "tel1":電話番号1,<br>    "tel2":電話番号2,<br>    "fax":Fax番号,<br>    "e_mail":メールアドレス,<br>    "work_name":勤務先名,<br>    "work_tel":勤務先電話番号,<br>    "memo1":メモ1,<br>    "memo2":メモ2<br>  },・・・<br>] |
|  | 業者連絡先情報 | vendor_contact_info | jsonb |  |  |  | [<br>  {<br>    "ctl_no":管理番号,<br>    "disp_order":表示順,<br>    "company_name":会社名,<br>    "zip_cd":郵便番号,<br>    "address":住所,<br>    "company_tel":代表電話番号,<br>    "fax":代表FAX番号,<br>    "worker_last_name":担当者姓,<br>    "worker_first_name":担当者名,<br>    "worker_tel":担当者電話番号,<br>    "worker_e_mail":メールアドレス<br>    "memo1":メモ1,<br>    "memo2":メモ2<br>  },・・・<br>] |
|  | 保険情報 | insurance_info | jsonb |  |  |  | 保険情報<br>[<br>  {<br>    "insurance_no":保険者番号,<br>    "insurance_class":保険区分,　※0:不明、1:被保険者、2:被扶養者、3:無<br>    "insured_cd":被保険者記号,<br>    "insured_no":被保険者番号,<br>    "insurance_ratio":負担率,<br>    "pub_insu_no1":公費負担番号1,<br>    "pub_insu_no2":公費負担番号2,<br>    "pub_insu_rec_no1":公費負担医療受給者番号1,<br>    "pub_insu_rec_no2":公費負担医療受給者番号2,<br>    "insurance_memo1":保険メモ1,<br>    "insurance_memo2":保険メモ2,<br>    "disability_no":障害者手帳番号<br>  }, …<br>] |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 原疾患コード | primary_disease_cd | integer |  |  |  | 病名マスタ.病名コード |
|  | 臨時透析区分コード | temporary_dialysis_cd | integer |  |  |  | 臨時透析区分マスタ.臨時透析区分コード |
|  | 遠隔モニタリングサービス業者 | remote_monitor_service | integer |  |  |  | ビデオ通話の事業者 |
|  | 遠隔モニタリングサービス利用者ID | remote_monitor_user_id | character varying |  |  |  | ビデオ通話に使用するID |
|  | 遠隔モニタリングサービス利用者パスワード | remote_monitor_user_pw | character varying |  |  |  | ビデオ通話に使用するPW |
|  | (旧)更新日時 | old_up_date_personal | timestamp(3) |  |  |  |  |
