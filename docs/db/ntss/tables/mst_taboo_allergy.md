# mst_taboo_allergy

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_taboo_allergy`
- Logical name: 禁忌・アレルギーマスタ
- Physical name: `mst_taboo_allergy`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `taboo_allergy_cd`
- Column count: 11
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 禁忌・アレルギーコード | taboo_allergy_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | FNW+で管理する施設内の一意な禁忌・アレルギーコード | fn_taboo_allergy_cd | character varying | 10 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | 内容 | content | character varying | 80 |  |  |  |
|  | 詳細 | detail_info | jsonb |  |  |  | [<br>  {<br>     "class": 禁忌対象区分<br>     "cd": 禁忌対象コード<br>     "name": 禁忌対象名<br>     "type": 薬剤区分<br>  }, …<br>]<br><br>◆禁忌対象区分<br>　'1'：薬剤<br>　'2'：調製薬剤<br>　'3'：医療材料<br>　'4'：ダイアライザ<br>　'5'：フリーワード<br><br>◆禁忌対象コード<br>　class='1'の場合、薬剤コード<br>　class='2'の場合、調製薬剤コード<br>　class='3'の場合、医療材料コード<br>　class='4'の場合、ダイアライザコード<br>　class='5'の場合、null<br><br>◆禁忌対象名<br>　class='1'～'4'の場合、""（空文字）<br>　class='5'の場合、<br>　マスタメンテナンス画面での入力値<br><br>◆薬剤区分<br>　class='1'～'5'の場合、null<br>　class='6'の場合、薬剤区分 |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 院内コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
