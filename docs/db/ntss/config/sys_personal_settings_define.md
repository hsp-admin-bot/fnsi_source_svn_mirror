# sys_personal_settings_define

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@sys_personal_settings_define`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 | col5 |
| --- | --- | --- | --- | --- |
| 各JSON項目の設定方法 |  |  |  |  |
|  | 設定項目情報    item_info |  |  |  |
|  | { |  |  |  |
|  | identifier      :   string  // 設定項目ID |  |  |  |
|  | type            :   string  // 項目のタイプ。"number": 数値項目、"string": 文字列項目、"combo1":固定コンボ 、"combo2": 参照型コンボ |  |  |  |
|  | title           :   string  // 表示名 |  |  |  |
|  | validation      :  {        // バリデーション |  |  |  |
|  | max             :   number  // 最大値。設定不要の場合はnull |  |  |  |
|  | min             :   number  // 最小値。設定不要の場合はnull |  |  |  |
|  | digit           :   number  // 小数桁数。設定不要の場合は0 |  |  |  |
|  | required        :   boolean // 必須かどうか("true","false") |  |  |  |
|  | maxlength       :   number  // 最大桁数 |  |  |  |
|  | } |  |  |  |
|  | } |  |  |  |
|  | 固定コンボデータ    combo_data |  |  |  |
|  | { |  |  |  |
|  | combos          : [ |  |  |  |
|  | { |  |  |  |
|  | setting_identifier      :   string  // 定義元の設定項目ID |  |  |  |
|  | values      : [ |  |  |  |
|  | { |  |  |  |
|  | text    :   string  // 表示名 |  |  |  |
|  | value   :   any // 値 |  |  |  |
|  | }, … |  |  |  |
|  | }, … |  |  |  |
|  | ] |  |  |  |
|  | } |  |  |  |
|  | 参照型コンボデータ  reference_combo_def |  |  |  |
|  | { |  |  |  |
|  | combos          : [ |  |  |  |
|  | { |  |  |  |
|  | setting_identifier      :   string  // 定義元の設定項目ID |  |  |  |
|  | target_table            : {     // 参照先マスタ情報 |  |  |  |
|  | name                    :   string  // 参照マスタの物理名 |  |  |  |
|  | identifier              :   string  // 参照マスタのプライマリキーとなる列の物理名 |  |  |  |
|  | display_column          :   string  // ドロップダウンリストで表示する参照マスタの列の物理名 |  |  |  |
|  | referenced_column       :   string  // ドロップダウンリストで値とする参照マスタの列の物理名 |  |  |  |
|  | } |  |  |  |
|  | }, … |  |  |  |
|  | ] |  |  |  |
|  | } |  |  |  |
| 定義済の設定項目 |  |  |  |  |
|  | タブ定義コード | 設定項目情報 | 固定コンボデータ | 参照型コンボデータ |
|  | 1 | {<br>  "item_info": [<br>    {<br>      "identifier": "1",<br>      "type": "combo1",<br>      "title": "通知メッセージジャンプで既読",<br>      "validation": { "required": true }<br>    }<br>  ]<br>} | {<br>  "combos": [<br>    {<br>      "values": [<br>        { "text": "しない", "value": 0 },<br>        { "text": "する", "value": 1 }<br>      ],<br>      "setting_identifier": "1"<br>    }<br>  ]<br>} | なし |
|  | 8 | {<br> "item_info": []<br>} | {<br> "combos": []<br>} | {<br> "combos": []<br>} |
