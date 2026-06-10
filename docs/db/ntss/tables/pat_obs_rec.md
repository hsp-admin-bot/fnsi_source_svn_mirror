# pat_obs_rec

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `pat_obs_rec`
- Logical name: 患者観察記録情報
- Physical name: `pat_obs_rec`
- Prefix group: `patient`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `obs_rec_no`
- Column count: 16
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 管理番号 | obs_rec_no | bigserial |  | 1 |  |  |
|  | システムで管理する一意な患者ID | pat_id | bigint |  | 1 |  | pat_personal.pat_id |
|  | 登録施設コード | facility_cd | character varying | 6 |  |  |  |
|  | 起票日時 | rec_date | timestamp(3) |  |  |  |  |
|  | 更新回数 | up_cnt | smallint |  |  |  |  |
|  | 種別情報 | kind_info | jsonb |  |  | E'{"kind_no":null,"kind_update":null,"kind_name":null}' | 種別情報<br>{<br>  "kind_no":観察記録種別マスタ.種別番号　※種別番号<br>  "kind_update":観察記録種別マスタ.更新日時　※種別番号更新日時<br>  "kind_name":観察記録種別マスタ.種別名　※種別名<br>} |
|  | 起票者情報 | reg_staff_info | jsonb |  |  | E'{"reg_staff_cd":null,"reg_staff_update":null,"reg_staff_name":null}' | 起票者情報<br>{<br>  "reg_staff_cd":スタッフマスタ.スタッフコード　※起票者コード<br>  "reg_staff_update":スタッフマスタ.更新日時　※起票者コード更新日時<br>  "reg_staff_name":スタッフマスタ.スタッフ名　※起票者名<br>} |
|  | 編集者情報 | up_staff_info | jsonb |  |  | E'{"up_staff_cd":null,"up_staff_update":null,"up_staff_name":null}' | 編集者情報<br>{<br>  "up_staff_cd":スタッフマスタ.スタッフコード　※編集者コード<br>  "up_staff_update":スタッフマスタ.更新日時　※編集者コード更新日時<br>  "up_staff_name":スタッフマスタ.スタッフ名　※編集者名<br>} |
|  | 観察記録情報 | obs_rec_info | jsonb |  |  | E'{"detail1":null,"detail2":null,"detail3":null,"detail4":null}' | 観察記録内容<br>{<br>  "detail1":内容1　※SOAPの場合：SOAPのS、他の種別の場合：内容<br>  "detail2":内容2　※種別がSOAPの場合のみ使用（SOAPのOのデータ）<br>  "detail3":内容3　※種別がSOAPの場合のみ使用（SOAPのAのデータ）<br>  "detail4":内容4　※種別がSOAPの場合のみ使用（SOAPのPのデータ）<br>} |
|  | 掲示板管理番号 | bbs_ctl_no | bigint |  |  |  |  |
|  | システムで管理する一意なオーダ番号 | ord_no | bigint |  |  |  | 透析情報.オーダ番号 |
|  | 最新フラグ | is_newest | character varying | 1 |  | '0' | '0':過去データ、'1':最新データ |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | FNW+で管理する施設内の一意な観察記録用シーケンス番号 | fn_seq_id | bigint |  |  |  | FNW+フィードバック用 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
