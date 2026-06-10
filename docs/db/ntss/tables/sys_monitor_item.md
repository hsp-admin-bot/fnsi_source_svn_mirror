# sys_monitor_item

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `sys_monitor_item`
- Logical name: モニタ項目
- Physical name: `sys_monitor_item`
- Prefix group: `system`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `moni_data_no`
- Column count: 14
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | モニタデータ番号 | moni_data_no | character varying | 5 | 1 |  | [moni_data_type] と [アドレス値] を連結した文字列をを設定する。<br>※[moni_data_type] をプレフィックスとして[アドレス値]に付加する。<br>　 <br>■共通 のモニタデータ<br>　'-'(ハイフン) + [アドレス値]<br><br>■透析装置のモニタデータ<br>　 [アドレス値]を設定<br>　※[moni_data_type] がnull である為、[アドレス値]を設定する。<br><br>■DAB のモニタデータ<br>　'A' + [アドレス値]<br><br>■DAD のモニタデータ<br>　'D' + [アドレス値]<br><br>■DRO のモニタデータ<br>　'R' + [アドレス値]<br><br>■特殊浄化 のモニタデータ<br>　'Z' + [アドレス値] |
|  | モニタデータ種別 | moni_data_type | character varying | 1 |  |  | '-' : 共通<br>null : 透析装置(※1)<br>'A' : DAB<br>'D' : DAD<br>'R' : DRO<br>'Z' : 特殊浄化<br><br>※1: null は文字列ではなく、何も設定しない事を指す. |
|  | モニタデータ項目名 | moni_data_name | character varying |  |  |  |  |
|  | モニタデータ短縮名 | moni_data_short_name | character varying |  |  |  |  |
|  | データ種別 | data_type | numeric | 1,0 |  | 0 | 0:文字列　<br>1:数値（整数）<br>2:数値（実数）<br>3:時間・時刻 |
|  | 小数部桁数 | decimal_figure | numeric | 2,0 |  |  |  |
|  | 単位 | unit | character varying |  |  |  |  |
|  | 最大値 | upper | numeric | 10,2 |  |  |  |
|  | 最小値 | lower | numeric | 10,2 |  |  |  |
|  | 表示有無 | is_disp | character varying | 1 |  |  | '0' : 非表示、'1' : 表示 |
|  | バイタル・モニタ区分 | vital_monitor_class | character varying | 1 |  |  | '1' : バイタル、'2' : モニタ<br><br>以下のモニタデータ項目番号は'1' : バイタルとする。<br>　'90' : 最高血圧<br>　'91' : 最低血圧<br>　'92' : 平均血圧<br>　'93' : 脈拍<br>　'94' : 体温 |
|  | 変換項目 | conv_item | jsonb |  |  |  | モニタデータの値により変換を行う場合に使用<br>例えば、治療モードの場合、以下の通りです。<br>{<br>  "0":"HD",<br>  "1":"ECUM",<br>  "2":"HDF",<br>  "3":"HF",<br>  "4":"HD+補液",<br>  "6":"AFBF",<br>  "7":"OHDF",<br>  "8":"OHF",<br>  "9":"特殊血液浄化",<br>  "10":"I-HDF"<br>}<br><br>モニタ情報を登録する画面では、この変換項目を選択肢として使用する想定。 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
