# report_graph_setting

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@report_graph_setting`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 |
| --- | --- | --- | --- |
| ■帳票グラフ設定(report_graph_setting) |  |  |  |
|  | キー | 型 | 値 |
|  | is_bp | Boolean | true : 血圧情報<br>false : 血圧情報以外 |
|  | cd | String | モニタ項目コード |
|  | type | Number | 1 : モニタ項目(sys_monitor_item) の項目<br>2 : バイタル・モニタ項目追加マスタ(mst_add_monitor) の項目 |
|  | plot_type | String | プロット形状を表す文字列<br>　　　　　　　 ↓<br>  "△" : "triangle"<br>  "▲" : "triangle-b"<br>  "▽" : "triangle-down"<br>  "▼" : "triangle-down-b"<br>  "□" : "square"<br>  "■" : "square-b"<br>  "◇" : "diamond"<br>  "◆" : "diamond-b"<br>  "○" : "circle"<br>  "●" : "circle-b" |
|  | plot_color | String | プロット色(カラーコード) |
|  | plot_size | Numer | プロットサイズ |
|  | line_type | String | 線種を表す文字列<br>             ↓<br> 点線 : "Dash"<br> 実線 : "Solid" |
|  | line_color | String | 線色(カラーコード) |
|  | line_thickness | Numer | 線の太さ |
|  | max | Number | グラフ上限値 |
|  | min | Number | グラフ下限値 |
|  | show_check | Boolean | true : 表示<br>false : 非表示<br>※血圧情報のみ、初期値は３つとも「表示（true）」 |
|  | (※1) 未登録の場合はjson内に出現しない. |  |  |
|  | 以下、jsonb文字列（例） |  |  |
