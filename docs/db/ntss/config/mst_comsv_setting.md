# ＠mst_comsv_setting

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `＠mst_comsv_setting`
- Category: config/reference

## Content

| col1 | col2 | col3 |
| --- | --- | --- |
| /* 仮想端末メニュー表示設定 jsonb文字列 */ |  |  |
| title | (String) | 最大6桁（バイト） |
| no | (Number) | 固定（1～8） |
| code | (Number) | コンボボックスで選択した番号（0～33） |
| name | (String) | 最大12桁（バイト） |
| 以下、jsonb文字列（例） |  |  |
| {<br> "menu1_title": "ﾒﾆｭｰ1",<br> "menu1_item": [<br>  {<br>   "no": 1,<br>   "code": 1,<br>   "name": "愁訴処置"<br>  },<br>  {<br>   "no": 2,<br>   "code": 2,<br>   "name": "穿刺／回収"<br>  },<br>  {<br>   "no":3,<br>   "code": 3,<br>   "name": "酸素吸入"<br>  },<br>  {<br>   "no": 4,<br>   "code": 4,<br>   "name": "検査結果"<br>  },<br>  {<br>   "no": 5,<br>   "code": 5,<br>   "name": "ログ"<br>  },<br>  {<br>   "no": 6,<br>   "code": 6,<br>   "name": "終了予定"<br>  },<br>  {<br>   "no": 7,<br>   "code": 7,<br>   "name": "体重ﾄﾚﾝﾄ"<br>  },<br>  {<br>   "no": 8,<br>   "code": 8,<br>   "name": "投与薬剤"<br>  }<br> ],<br> "menu2_title": "ﾒﾆｭｰ2",<br> "menu2_item": [<br>  {<br>   "no": 1,<br>   "code": 9,<br>   "name": "抗凝固剤"<br>  },<br>  {<br>   "no": 2,<br>   "code": 10,<br>   "name": "禁忌"<br>  },<br>  {<br>   "no": 3,<br>   "code": 11,<br>   "name": "メモ"<br>  },<br>  {<br>   "no": 4,<br>   "code": 12,<br>   "name": "ｸﾞﾗﾌ1-1"<br>  },<br>  {<br>   "no": 5,<br>   "code": 13,<br>   "name": "ｸﾞﾗﾌ1-2"<br>  },<br>  {<br>   "no": 6,<br>   "code": 14,<br>   "name": "ｸﾞﾗﾌ1-3"<br>  },<br>  {<br>   "no": 7,<br>   "code": 15,<br>   "name": "ｸﾞﾗﾌ1-4"<br>  },<br>  {<br>   "no": 8,<br>   "code": 16,<br>   "name": "ｸﾞﾗﾌ1-5"<br>  }<br> ],<br> "menu3_title": "ﾒﾆｭｰ3",<br> "menu3_item": [<br>  {<br>   "no": 1,<br>   "code": 17,<br>   "name": "ﾚｰﾀﾞｰﾁｬｰﾄ"<br>  },<br>  {<br>   "no": 2,<br>   "code": 18,<br>   "name": "ｸﾞﾗﾌ2-1"<br>  },<br>  {<br>   "no": 3,<br>   "code": 19,<br>   "name": "ｸﾞﾗﾌ2-2"<br>  },<br>  {<br>   "no": 4,<br>   "code": 20,<br>   "name": "ｸﾞﾗﾌ2-3"<br>  },<br>  {<br>   "no": 5,<br>   "code": 21,<br>   "name": "ｸﾞﾗﾌ2-4"<br>  },<br>  {<br>   "no": 6,<br>   "code": 22,<br>   "name": "ｸﾞﾗﾌ2-5"<br>  },<br>  {<br>   "no": 7,<br>   "code": 23,<br>   "name": "指示／特記"<br>  },<br>  {<br>   "no": 8,<br>   "code": 24,<br>   "name": "CTRﾄﾚﾝﾄﾞ"<br>  }<br> ],<br> "menu4_title": "ﾒﾆｭｰ4",<br> "menu4_item": [<br>  {<br>   "no": 1,<br>   "code": 25,<br>   "name": "透析日報"<br>  },<br>  {<br>   "no": 2,<br>   "code": 26,<br>   "name": "ﾁｪｯｸﾘｽﾄ-1"<br>  },<br>  {<br>   "no": 3,<br>   "code": 27,<br>   "name": "ﾁｪｯｸﾘｽﾄ-2"<br>  },<br>  {<br>   "no": 4,<br>   "code": 28,<br>   "name": "ﾁｪｯｸﾘｽﾄ-3"<br>  },<br>  {<br>   "no": 5,<br>   "code": 29,<br>   "name": "ﾁｪｯｸﾘｽﾄ-4"<br>  },<br>  {<br>   "no": 6,<br>   "code": 30,<br>   "name": "ﾁｪｯｸﾘｽﾄ-5"<br>  },<br>  {<br>   "no": 7,<br>   "code": 31,<br>   "name": "ﾁｪｯｸﾘｽﾄ-6"<br>  },<br>  {<br>   "no": 8,<br>   "code": 32,<br>   "name": "ﾁｪｯｸﾘｽﾄ-7"<br>  }<br> ]<br>} |  |  |
| /* 次患者情報表示設定 jsonb文字列 */ |  |  |
| 表示対象として設定した最大10項目 |  |  |
| no | (Number) | 表示順（1～10） |
| code | (Number) | 表示対象の項目番号（1～99） |
| name | (String) | 最大16桁（バイト） |
| 以下、jsonb文字列（例） |  |  |
| {<br> "npat_item": [<br>  {<br>   "no": 1,<br>   "code": 2,<br>   "name": "患者名フリガナ"<br>  },<br>  {<br>   "no": 2,<br>   "code": 10,<br>   "name": "治療項目名"<br>  },<br>  {<br>   "no": 3,<br>   "code": 14,<br>   "name": "ダイアライザ名"<br>  },<br>  {<br>   "no": 4,<br>   "code": 91,<br>   "name": ""<br>  },<br>  {<br>   "no": 5,<br>   "code": 17,<br>   "name": "抗凝固剤名"<br>  },<br>  {<br>   "no": 6,<br>   "code": 18,<br>   "name": "ワンショット量"<br>  },<br>  {<br>   "no": 7,<br>   "code": 19,<br>   "name": "持続注入量"<br>  },<br>  {<br>   "no": 8,<br>   "code": 20,<br>   "name": "持続総量"<br>  },<br>  {<br>   "no": 9,<br>   "code": 92,<br>   "name": ""<br>  },<br>  {<br>   "no": 10,<br>   "code": 9,<br>   "name": "ＶＡ"<br>  }<br> ]<br>} |  |  |
| /* 透析日報表示設定 jsonb文字列 */ |  |  |
| 表示対象として設定した最大８項目 |  |  |
| no | (Number) | 表示順（1～8） |
| code | (Number) | 表示対象の項目番号（1～86） |
| name | (String) | 最大16桁（バイト） |
| 以下、jsonb文字列（例） |  |  |
| {<br> "report_item": [<br>  {<br>   "no": 1,<br>   "code": 1,<br>   "name": "透析開始時刻"<br>  },<br>  {<br>   "no": 2,<br>   "code": 2,<br>   "name": "透析終了時刻"<br>  },<br>  {<br>   "no": 3,<br>   "code": 16,<br>   "name": "透析時間"<br>  },<br>  {<br>   "no": 4,<br>   "code": 31,<br>   "name": "抗凝固剤"<br>  },<br>  {<br>   "no": 5,<br>   "code": 32,<br>   "name": "（凝）初回注入量"<br>  },<br>  {<br>   "no": 6,<br>   "code": 33,<br>   "name": "（凝）持続注入量"<br>  },<br>  {<br>   "no": 7,<br>   "code": 34,<br>   "name": "（凝）持続総量"<br>  }<br> ]<br>} |  |  |
