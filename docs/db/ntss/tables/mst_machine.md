# mst_machine

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_machine`
- Logical name: 装置マスタ
- Physical name: `mst_machine`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd,machine_type_cd,machine_serial`
- Column count: 46
- NOT NULL columns: 5

## Related Config / Notes

- [../config/mst_machine.md](../config/mst_machine.md)
- [../config/mst_machine_20181207.md](../config/mst_machine_20181207.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
| 1 | 型式コード | machine_type_cd | character varying | 3 | 1 |  | 型式マスタ.型式コード |
| 1 | 製造番号 | machine_serial | character varying | 8 | 1 |  | 新通信：7桁<br>NX通信：8桁<br>医器工：8桁（ダミーの製造番号使用）<br>★製造番号が8桁未満の場合、右側に半角スペースをパディング<br>★比較時はTrim後に比較すること |
|  | 装置名 | machine_name | character varying | 40 |  |  |  |
|  | 装置番号 | machine_no | bigserial |  |  |  | 一意制約 |
|  | IPアドレス | ip_address | inet |  |  |  |  |
|  | ポート番号 | port | character varying | 5 |  |  | 医器工V4等との通信時に使用 |
|  | 通信フォーマット | com_format_cd | character varying | 1 |  |  | 「@mst_machine」シート参照 |
|  | 通信種別 | com_type | numeric | 1,0 |  |  | 0：通信なし(オフライン運用)、1：新通信、2：NX通信、3：医器工V4 |
|  | デバイスエッジ番号 | device_edge_no | numeric | 2,0 |  |  | デバイスエッジマスタ.デバイスエッジ番号 |
|  | データ収集可否 | is_ftp | character varying | 1 | 1 |  | 0：FTP収集しない、1：FTP収集する |
|  | 画像転送可否 | is_va | character varying | 1 | 1 |  | 0：VA画像を転送しない、1：VA画像を転送する |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 設置日 | setting_date | timestamp(3) |  |  |  |  |
|  | 廃棄日 | delete_date | timestamp(3) |  |  |  |  |
|  | バージョン | version | character varying | 20 |  |  |  |
|  | 装置オプション | machine_option | jsonb |  |  |  | ★@mst_machine |
|  | メモ | memo | character varying | 256 |  |  |  |
|  | 使用不可フラグ | is_disable | character varying | 1 |  |  | 0：使用可、1：使用不可 |
|  | 対応可否フラグ(HD) | is_support_hd | character varying | 1 |  |  | 装置モード(HD)の対応可否（0：未対応、1：対応） |
|  | 対応可否フラグ(ECUM) | is_support_ecum | character varying | 1 |  |  | 装置モード(ECUM)の対応可否（0：未対応、1：対応） |
|  | 対応可否フラグ(HDF) | is_support_hdf | character varying | 1 |  |  | 装置モード(HDF)の対応可否（0：未対応、1：対応） |
|  | 対応可否フラグ(HF) | is_support_hf | character varying | 1 |  |  | 装置モード(HF)の対応可否（0：未対応、1：対応） |
|  | 対応可否フラグ(HD+補液) | is_support_hd_ho | character varying | 1 |  |  | 装置モード(HD+補液)の対応可否（0：未対応、1：対応） |
|  | 対応可否フラグ(ECUM+補液) | is_support_ecum_ho | character varying | 1 |  |  | 装置モード(ECUM+補液)の対応可否（0：未対応、1：対応） |
|  | 対応可否フラグ(AFBF) | is_support_afbf | character varying | 1 |  |  | 装置モード(AFBF)の対応可否（0：未対応、1：対応） |
|  | 対応可否フラグ(OHDF) | is_support_ohdf | character varying | 1 |  |  | 装置モード(OHDF)の対応可否（0：未対応、1：対応） |
|  | 対応可否フラグ(OHF) | is_support_ohf | character varying | 1 |  |  | 装置モード(OHF)の対応可否（0：未対応、1：対応） |
|  | 対応可否フラグ(I-HDF) | is_support_i_hdf | character varying | 1 |  |  | 装置モード(I-HDF)の対応可否（0：未対応、1：対応） |
|  | 対応可否フラグ(特殊浄化) | is_support_blood_purify | character varying | 1 |  |  | 装置モード(特殊浄化)の対応可否（0：未対応、1：対応） |
|  | TMP初期補正中点(HD) | tmp_center_hd | integer |  |  |  | 装置モード(HD)の初期補正中点（単位：mmHg) |
|  | TMP初期補正中点(ECUM) | tmp_center_ecum | integer |  |  |  | 装置モード(ECUM)の初期補正中点（単位：mmHg) |
|  | TMP初期補正中点(HDF) | tmp_center_hdf | integer |  |  |  | 装置モード(HDF)の初期補正中点（単位：mmHg) |
|  | TMP初期補正中点(HF) | tmp_center_hf | integer |  |  |  | 装置モード(HF)の初期補正中点（単位：mmHg) |
|  | TMP初期補正中点(HD+補液) | tmp_center_hd_ho | integer |  |  |  | 装置モード(HD+補液)の初期補正中点（単位：mmHg) |
|  | TMP初期補正中点(OHDF) | tmp_center_ohdf | integer |  |  |  | 装置モード(OHDF)の初期補正中点（単位：mmHg) |
|  | TMP初期補正中点(OHF) | tmp_center_ohf | integer |  |  |  | 装置モード(OHF)の初期補正中点（単位：mmHg) |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | FNW+で管理する施設内の一意な装置番号 | fn_device_no | numeric | 10,0 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | 特殊浄化通信アプリ使用選択 | is_blood_purify_use | character varying | 1 |  | '1' | 0：使用可、1：使用不可 |
|  | 特殊浄化装置種別 | blood_purify_type | character varying | 1 |  | '5' | 1：ACH-Σ、2：KM-8900、3：プラソートiQ21、4：KM-9000、5：日機装透析装置 |
|  | FNW用装置区分 | fn_class_cd | character varying | 1 |  |  | 0':装置マスタ、'1':機械室装置マスタ |
|  | 連携コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 連携コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
