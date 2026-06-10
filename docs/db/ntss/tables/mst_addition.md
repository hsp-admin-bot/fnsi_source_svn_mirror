# mst_addition

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_addition`
- Logical name: 加算マスタ
- Physical name: `mst_addition`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `addition_cd`
- Column count: 21
- NOT NULL columns: 1

## Related Config / Notes

- [../config/addition_tar_cd.md](../config/addition_tar_cd.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 加算コード | addition_cd | bigserial |  | 1 |  | シーケンス |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | FNWコード | fn_add_cd | character varying | 8 |  |  | FNW+のレセプトメモに相当 |
|  | 加算等名称 | addition_name | character varying | 256 |  |  |  |
|  | 加算略称 | addition_short_name | character varying | 20 |  |  |  |
|  | 登録区分 | addition_kind | character varying | 1 |  | 0 | '1':自動 '2':手動 |
|  | 種別区分 | addition_class | character varying | 2 |  | 1 | 1'：施設、'2'：患者（困）、'3'：患者（病）、'4'：ろ過、'5'：長時間、'6'：薬剤、'7'：処置（イベント）、'8'：処置（検査）、'9'：導入期、'10'：休日、'11'：時間外、'12'：汎用、'13'：慢性維持透析患者外来医学管理料<br>'1'：透析液水質確保加算、'2'：障害者加算、'3'：指定病名連動、'4'：指定治療方法加算、'5'：長時間加算、'6'：指定薬剤実施連動、'7'：指定患者イベント連動、'8'：検査依頼連動、'9'：導入期加算、'10'：休日加算、'11'：時間外加算、'12'：汎用、'13'：慢性維持透析患者外来医学管理料 |
|  | 算定間隔 | addition_span | character varying | 1 |  | 0 | 算定できる間隔を指定。<br>'0':月１回、'1':週１回、'2':1日、'3':毎回、'4':期限 |
|  | 算定回数上限 | addition_limit | integer |  |  | 1 | 算定間隔の算定できる期間内での算定回数上限。<br>nullまたは'0':上限なし。<br>n回/月、指定日から n日まで の2項目共通の項目。 |
|  | 算定番目 | add_cnt_1 | integer |  |  | 1 | 【１回時】何回目の透析時に算定するか　最終は99 |
|  | 算定対象コード | addition_tar_cd | jsonb |  |  |  | @addition_tar_cdシートで参考<br>addition_classが２の場合：画面で入力された困難Cdのリストが格納される<br>addition_classが３の場合：画面で入力された病名Cdのリストが格納される<br>addition_classが６の場合：画面で入力された薬剤Cdのリストが格納される<br>addition_classが７の場合：画面で入力された患者イベントCdのリストが格納される |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 院内コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
|  | 院内コード3 | in_hospital_cd_3 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0' : 非表示、'1' : 表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0' : 通常、'1' : 削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 算定回数上限型式 | addition_limit_type | character varying | 1 |  |  | '0' : 月初めの透祈・週初めの透析<br>'1' : 回目の透祈<br>'2' : 月最終の透折・週最終の透析 |
|  | 算定対象 | addition_cond | character varying | 1 |  |  | '0':毎回　'1':病名・コメント |
|  | 算定治療時間 | addition_dialysis_time | integer |  |  |  |  |
