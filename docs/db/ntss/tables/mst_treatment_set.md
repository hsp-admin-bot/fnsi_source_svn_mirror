# mst_treatment_set

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_treatment_set`
- Logical name: 治療方法セットマスタ
- Physical name: `mst_treatment_set`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `treatment_set_cd`
- Column count: 13
- NOT NULL columns: 1

## Related Config / Notes

- [../config/mst_treatment_set.md](../config/mst_treatment_set.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 治療方法セットコード | treatment_set_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  |  |
|  | 治療方法セット名 | treatment_set_name | character varying |  |  |  |  |
|  | 治療方法コード | treatment_cd | integer |  |  |  | 治療方法マスタ.治療方法コード |
|  | 治療条件 | ind_cond_info | jsonb |  |  |  | ■Json構造_x000D_<br>{_x000D_<br>  "治療条件項目番号": (*1)_x000D_<br>  {_x000D_<br>    "value": 設定値, (*2)_x000D_<br>    "medicine_type": 薬剤区分, (*3)(*4)_x000D_<br>  }, ・・・_x000D_<br>}_x000D_<br>■概要_x000D_<br>(*1) 治療条件項目番号をキーとして設定_x000D_<br>       (※シート「@治療条件項目」を参照)_x000D_<br>(*2) 必須(項目によっては、値は null(or 空文字)も可)_x000D_<br>(*3) 登録が必要な治療条件項目の場合に設定_x000D_<br>(*4) 1: 通常薬剤、2: 調製薬剤_x000D_ |
|  | 投与薬剤 | ind_medi_info | jsonb |  |  |  | ■Json構造<br>[<br>  {<br>    "medicine_type": 薬剤区分, (*1)(*2)<br>    "cd": 薬剤(調整薬剤)コード, (*1)<br>    "amount": 数量, (*1)<br>    "timing_cd": 投与タイミングコード, (*1)<br>    "procedure_cd": 手技コード, (*1),<br>    "medicine_comment":コメント<br>  }, ・・・<br>]<br>■概要<br>(*1) 必須(項目によっては、値は null(or 空文字)も可)<br>(*2) 1: 通常薬剤、2: 調製薬剤 |
|  | 医療材料 | ind_equip_info | jsonb |  |  |  | ■Json構造<br>[<br>  {<br>    "cd": 医療材料コード, (*1)<br>    "needle_type": 穿刺針区分, (*2)<br>    "amount": 数量, (*1)<br>    "equip_type": (Number)医療材料区分 (*1)(*3)<br>  }, ・・・<br>]<br>■概要<br>(*1) 必須(項目によっては、値は null(or 空文字)も可)<br>(*2) 医療材料分類が「穿刺針」の場合に必要(0: 未指定、1: A針、2: V針、3: SN)<br>(*3) 0：医療材料、1：ダイアライザ |
|  | 指示コメント | ind_ind_comment_info | jsonb |  |  |  | ■Json構造<br>[<br>  {<br>    "no": 指示コメント番号, (*1)<br>    "content": 内容, (*2)<br>  }, ・・・<br>]<br>■概要<br>(*1) 指示コメントを識別するための番号(1 ～)<br>(*2) 必須(項目によっては、値は null(or 空文字)も可) |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 装置設定 | ind_device_set_info | jsonb |  |  |  | ※@mst_treatment_set参照 |
