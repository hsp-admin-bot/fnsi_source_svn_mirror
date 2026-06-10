# ord_vital

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `ord_vital`
- Logical name: 透析バイタル情報
- Physical name: `ord_vital`
- Prefix group: `order-treatment`
- User: `nkk`
- Tablespace DB: `ntss_db`
- Tablespace INDEX: `ntss_index`
- Primary key definition: `ord_no,ctl_no`
- Column count: 14
- NOT NULL columns: 2

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意なオーダ番号 | ord_no | bigint |  | 1 |  | ord_main.ord_no |
|  | 版番号 | edition | integer |  |  |  | ord_main.edition |
| 1 | 管理番号 | ctl_no | smallint |  | 1 |  |  |
|  | 入力区分 | input_class | smallint |  |  |  | 0:通信サーバ 1:クライアント 2：連携 |
|  | 血圧区分 | bp_class | smallint |  |  |  | 0:設定無し 1:前血圧　2:後血圧 |
|  | 最高血圧 | bp_max | smallint |  |  |  |  |
|  | 最低血圧 | bp_min | smallint |  |  |  |  |
|  | 平均血圧 | bp_ave | smallint |  |  |  |  |
|  | 血糖値 | blood_sugar_level | smallint |  |  |  |  |
|  | 脈拍 | pulse | smallint |  |  |  |  |
|  | 体温 | temperature | numeric | 3,1 |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 発生日時 | occur_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
