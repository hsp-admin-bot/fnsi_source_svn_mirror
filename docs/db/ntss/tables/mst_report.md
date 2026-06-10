# mst_report

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_report`
- Logical name: 帳票マスタ
- Physical name: `mst_report`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `report_cd`
- Column count: 17
- NOT NULL columns: 3

## Related Config / Notes

- [../config/mst_report.md](../config/mst_report.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | レポートCD | report_cd | bigserial |  | 1 |  | シーケンス使用 |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
|  | 帳票名 | report_name | character varying | 20 |  |  | 帳票の種類を一意に識別できる文字列 |
|  | 3ファイルのフルパス | report_path | jsonb |  |  |  | 3ファイルのフルパス<br><br>■Json構造<br>{<br>  "bucket": (String)S3上のバケット名<br>  "xlsx_zip": (String)帳票デザインExcel 圧縮ファイル名<br>  "report_zip": (String)Htmlと帳票定義.xml 圧縮ファイル名<br>  "xlsx_filename": (String)帳票デザインExcelファイル名<br>  "html_filename": (String)帳票デザインHtmlファイル名<br>  "xml_filename": (String)帳票定義Xmlファイル名<br>} |
|  | 帳票種別 | report_class | integer |  |  |  | 単患者帳票、透析レポートなどのレポート種類 |
|  | 帳票区分 | report_type | integer |  |  |  | 帳票種別を更に細分化した情報 |
|  | 抽出条件 | extraction_condition | jsonb |  |  |  | 帳票生成に必要な情報を取得するための抽出条件<br>「@mst_report」参照 |
|  | プリンター初期値 | default_printer | bigint |  |  |  | プリンターの初期選択値<br>プリンターマスタ.プリンターCD |
|  | 追加情報 | additional_info | jsonb |  |  |  | 帳票に関する追加情報<br>「@mst_report」参照 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 表示順 | disp_order | integer |  | 1 | 0 | 表示順 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 帳票更新履歴 | report_hst_info | jsonb |  |  |  | 帳票更新履歴<br><br>■Json構造<br>{<br>  "ctl_no":"1"<br>  "upd_date":"202010281745"<br>  "bucket": (String)S3上のバケット名<br>  "xlsx_zip": (String)帳票デザインExcel 圧縮ファイル名<br>  "report_zip": (String)Htmlと帳票定義.xml 圧縮ファイル名<br>  "xlsx_filename": (String)帳票デザインExcelファイル名<br>  "html_filename": (String)帳票デザインHtmlファイル名<br>  "xml_filename": (String)帳票定義Xmlファイル名<br>   "is_select":"1"   適用："1"、未適用："0"<br>    "upd_user_id: "XXXXX"<br>    "upd_user_name": "XXXXX"<br>} |
|  | 帳票設定 | report_setting | jsonb |  |  |  |  |
|  | 集計のデフォルトの値 | multi_total_defaul | character varying |  |  |  |  |
