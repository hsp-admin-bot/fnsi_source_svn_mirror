# mst_checklist

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_checklist`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 | col5 |
| --- | --- | --- | --- | --- |
| ■JSON情報 |  |  |  |  |
|  | カラム名 | 名称 | 値 | 説明 |
|  | checklist_settings | チェックリスト設定 | [<br> {<br>          list_cd: 1,<br>          list_name: '透析前準備',<br>          dialysis_prog_cd: 0,<br>          dialysis_prog_name: '透析開始前',<br>          is_use: '1',<br>          funclist:<br>          [<br>            {item_number: 1, func_class: 0, list_name: '浄化器', class_cd: null},<br>            {item_number: 2, func_class: 0, list_name: '回路', class_cd: null},<br>            {item_number: 3, func_class: 0, list_name: '血液浄化器', class_cd: null},<br>            {item_number: 4, func_class: 1, list_name: 'ダイアライザ', class_cd: 5},<br>            {item_number: 5, func_class: 1, list_name: '穿刺針', class_cd: 9},<br>            {item_number: 6, func_class: 1, list_name: '血液回路', class_cd: 13},<br>            {item_number: 7, func_class: 2, list_name: '吸着カラム', class_cd: 1111111107},<br>            {item_number: 8, func_class: 2, list_name: '穿刺針(SN)', class_cd: 1111111108},<br>            {item_number: 9, func_class: 2, list_name: '穿刺針(SN以外)', class_cd: 1111111109},<br>            {item_number: 10, func_class: 2, list_name: '血液回路', class_cd: 1111111110}<br>          ]<br>        },<br> …<br>] | リストコード（list_cd）：Number<br> 1～8で固定で使用<br> 初期状態で1～8の登録有り<br><br>リスト名（list_name）：String<br> <br>透析工程コード(dialysis_prog_cd)：Number<br> このチェックリストが入力可能な透析工程コード。<br> 透析工程マスタの透析工程コードをセットする。<br>　  0: 透析前<br>    1: 透析中<br>    2: 透析後<br>    3: 未使用<br><br>透析工程名(dialysis_prog_name)：String<br><br>使用可否(is_use)：String<br>　　'0':未使用<br>　　'1':使用<br><br>機能リスト(funclist)：Array<br>  項目番号(item_number)：Number<br>    1～10<br><br>　機能種別(func_class)：Number<br>　　0:通常リスト<br>　　1:治療条件<br>    2:医療材料<br>     3:投与薬剤<br><br>　リスト名(list_name)：String<br>　　通常リストの場合はチェックリスト項目名に表示<br>　　治療条件の場合は治療条件項目名<br>　　医療材料の場合は医療材料分類名<br>　    投与薬剤の場合は投与薬剤分類名<br><br>　分類コード(class_cd)：Number<br>　　未分類：-1<br>　　通常リスト:null<br>　　治療条件:治療条件項目番号<br> 　5:ダイアライザまたは吸着カラム(6),一次膜(7),二次膜(8)<br>     9:穿刺針(10,11含む)<br>     13:血液回路<br><br>    医療材料:医療材料分類コード<br>     ダイアライザは0<br>    投与薬剤:投与薬剤分類コード |
