# ＠＠mst_comsv_setting

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `＠＠mst_comsv_setting`
- Category: config/reference

## Content

| col1 | col2 | col3 |
| --- | --- | --- |
| /* 検査１グラフ表示設定 jsonb文字列 */ |  |  |
| no | (Number) | グラフ番号（1～5） |
| name | (String) | 最大10桁（バイト） |
| code1 | （？） | コンボボックスで選択した検査項目コード |
| code2 | （？） | コンボボックスで選択した検査項目コード |
| code3 | （？） | コンボボックスで選択した検査項目コード |
| 以下、jsonb文字列（例） |  |  |
| {<br> "graph1_item": [<br>  {<br>   "no": 1,<br>   "name": "検査１－１",<br>   "code1": "",<br>   "code2": "",<br>   "code3": ""<br>  },<br>  {<br>   "no": 2,<br>   "name": "検査１－２",<br>   "code1": "",<br>   "code2": "",<br>   "code3": ""<br>  },<br>  {<br>   "no": 3,<br>   "name": "検査１－３",<br>   "code1": "",<br>   "code2": "",<br>   "code3": ""<br>  },<br>  {<br>   "no": 4,<br>   "name": "検査１－４",<br>   "code1": "",<br>   "code2": "",<br>   "code3": ""<br>  },<br>  {<br>   "no": 5,<br>   "name": "検査１－５",<br>   "code1": "",<br>   "code2": "",<br>   "code3": ""<br>  }<br> ]<br>} |  |  |
| /* 検査２グラフ表示設定 jsonb文字列 */ |  |  |
| no | (Number) | グラフ番号（1～5） |
| name | (String) | 最大10桁（バイト） |
| graph1_name | (String) | 最大10桁（バイト） |
| code_bfr1 | （？） | コンボボックスで選択した検査項目コード |
| code_afr1 | （？） | コンボボックスで選択した検査項目コード |
| code_bar1 | （？） | コンボボックスで選択した検査項目コード |
| graph2_name | (String) | 最大10桁（バイト） |
| code_bfr2 | （？） | コンボボックスで選択した検査項目コード |
| code_afr2 | （？） | コンボボックスで選択した検査項目コード |
| code_bar2 | （？） | コンボボックスで選択した検査項目コード |
| 以下、jsonb文字列（例） |  |  |
| {<br> "graph2_item": [<br>  {<br>   "no": 1,<br>   "name": "検査２－１",<br>   "graph1_name": "グラフ－１",<br>   "code_bfr1": "",<br>   "code_afr1": "",<br>   "code_bar1": "",<br>   "graph2_name": "グラフ－２",<br>   "code_bfr2": "",<br>   "code_afr2": "",<br>   "code_bar2": ""<br>  },<br>  {<br>   "no": 2,<br>   "name": "検査２－２",<br>   "graph1_name": "グラフ－１",<br>   "code_bfr1": "",<br>   "code_afr1": "",<br>   "code_bar1": "",<br>   "graph2_name": "グラフ－２",<br>   "code_bfr2": "",<br>   "code_afr2": "",<br>   "code_bar2": ""<br>  },<br>  {<br>   "no": 3,<br>   "name": "検査２－３",<br>   "graph1_name": "グラフ－１",<br>   "code_bfr1": "",<br>   "code_afr1": "",<br>   "code_bar1": "",<br>   "graph2_name": "グラフ－２",<br>   "code_bfr2": "",<br>   "code_afr2": "",<br>   "code_bar2": ""<br>  },<br>  {<br>   "no": 4,<br>   "name": "検査２－４",<br>   "graph1_name": "グラフ－１",<br>   "code_bfr1": "",<br>   "code_afr1": "",<br>   "code_bar1": "",<br>   "graph2_name": "グラフ－２",<br>   "code_bfr2": "",<br>   "code_afr2": "",<br>   "code_bar2": ""<br>  },<br>  {<br>   "no": 5,<br>   "name": "検査２－５",<br>   "graph1_name": "グラフ－１",<br>   "code_bfr1": "",<br>   "code_afr1": "",<br>   "code_bar1": "",<br>   "graph2_name": "グラフ－２",<br>   "code_bfr2": "",<br>   "code_afr2": "",<br>   "code_bar2": ""<br>  }<br> ]<br>} |  |  |
| /* 検査レーダーチャート表示設定 jsonb文字列 */ |  |  |
| no | (Number) | グラフ番号（1～6） |
| code | （？） | コンボボックスで選択した検査項目コード |
| 以下、jsonb文字列（例） |  |  |
| {<br> "radar_item": [<br>  {<br>   "no": 1,<br>   "code": ""<br>  },<br>  {<br>   "no": 2,<br>   "code": ""<br>  },<br>  {<br>   "no": 3,<br>   "code": ""<br>  },<br>  {<br>   "no": 4,<br>   "code": ""<br>  },<br>  {<br>   "no": 5,<br>   "code": ""<br>  },<br>  {<br>   "no": 6,<br>   "code": ""<br>  }<br> ]<br>} |  |  |
| /* 仮想端末スタッフ一覧 jsonb文字列 */ |  |  |
| no | (Number) | 表示番号（1～320、設定なしは番号スキップ） |
| user_id | (Number) | コンボボックスで選択した処理者コード |
| 以下、jsonb文字列（例） |  |  |
| {<br> "staff_list": [<br>  {<br>   "no": 1,<br>   "user_id": 1 ※mst_user.user_id<br>  },<br>  {<br>   "no": 2,<br>   "user_id": 2<br>  },<br>  {<br>   "no": 3,<br>   "user_id": 3<br>  },<br>  {<br>   "no": 4,<br>   "user_id": 4<br>  },<br>  {<br>   "no": 5,<br>   "user_id": 5<br>  },<br>　　・・・・・<br>  {<br>   "no": 320,<br>   "user_id": 10<br>  }<br> ]<br>} |  |  |
