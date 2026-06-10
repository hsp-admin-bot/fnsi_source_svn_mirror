# mst_status_map_bed_layout

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_status_map_bed_layout`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 | col5 |
| --- | --- | --- | --- | --- |
| ■JSON情報 |  |  |  |  |
|  | カラム名 | 名称 | 値 | 説明 |
|  | bed_layout | ベッドレイアウト | canvas_size: {<br>  width: 800,<br>  height: 700,<br>},<br>obj_list: [<br>  {<br>    disp_order_no: 1,<br>    machine_type_cd: "001",<br>    machine_serial: "0000001",<br>    model: "004",<br>    name: "ベッド１",<br>    left: 20,<br>    top: 20,<br>    width: 200,<br>    height: 200,<br>  },<br>  {<br>    disp_order_no: 2,<br>    machine_type_cd: "099",<br>    machine_serial: "00000002",<br>    model: "001",<br>    name: 'DRO',<br>    left: 50,<br>    top: 125,<br>    width: 200,<br>    height: 500,<br>  },<br>  ...<br>] | ・canvas_size:レイアウト画面サイズ<br>    width: Number（幅）<br>    height: Number（高さ）<br><br>・obj_list：Array<br>    ベッド、機械室装置のリスト<br><br>・disp_order_no: Number<br>    表示順<br>・machine_type_cd: String<br>    型式<br>・machine_serial: String<br>    製造番号<br>・model: String<br>    オブジェクトの種類(型式マスタ．機種)<br>・name: String<br>    レイアウト編集中に表示される名称<br>・left: Number<br>    水平位置<br>・top: Number<br>    垂直位置<br>・width: Number<br>    幅<br>・height: Number<br>    高さ |
