# mst_weight_print

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_weight_print`
- Category: config/reference

## Content

| P2021より | ※実際これで足りるかどうかは検討が必要 |
| --- | --- |
| var mst_print = [{id:0, category: 0x0F, item_name: '（空行）', type:'space', print_format: '　', default_format: '', default_before_word: '', default_after_word: '' }, |  |
| {id:1, category: 0x0F, item_name: '現在日時', type:'date', print_format: '@data', default_format: 'YYYY/MM/DD hh:mm:ss', default_before_word: '', default_after_word: '' }, |  |
| {id:2, category: 0x07, item_name: 'ベッド番号', type:'text', print_format: 'ベッドNo. @data', default_format: 'xxx', default_before_word: 'ベッドNo. ', default_after_word: '' }, |  |
| {id:3, category: 0x07, item_name: '患者ID', type:'text', print_format: 'ID: @data', default_format: 'xxxxxxxxxxxx', default_before_word: 'ID: ', default_after_word: '' }, |  |
| {id:4, category: 0x07, item_name: '患者名', type:'text', print_format: '@data 様', default_format: 'xxxxxxxxxx', default_before_word: '', default_after_word: ' 様' }, |  |
| {id:5, category: 0x03, item_name: '透析時間', type:'date', print_format: '透析時間:@data', default_format: 'hh:mm', default_before_word: '透析時間:', default_after_word: '' }, |  |
| {id:6, category: 0x07, item_name: 'DW', type:'number', print_format: 'DW: @data kg', default_format: '3.2', default_before_word: 'DW: ', default_after_word: ' kg' }, |  |
| {id:7, category: 0x07, item_name: '目標体重', type:'number', print_format: '目標体重: @data kg', default_format: '3.2', default_before_word: '目標体重: ', default_after_word: ' kg' }, |  |
| {id:8, category: 0x0F, item_name: '測定値', type:'number', print_format: '測定値: @data kg', default_format: '3.2', default_before_word: '測定値: ', default_after_word: ' kg' }, |  |
| {id:9, category: 0x03, item_name: '透析【前】体重', type:'number', print_format: '【前】体重: @data kg', default_format: '3.2', default_before_word: '【前】体重: ', default_after_word: ' kg' }, |  |
| {id:10, category: 0x02, item_name: '透析【後】体重', type:'number', print_format: '【後】体重: @data kg', default_format: '3.2', default_before_word: '【後】体重: ', default_after_word: ' kg' }, |  |
| {id:11, category: 0x07, item_name: '前回透析【後】体重', type:'number', print_format: '前回【後】: @data kg', default_format: '3.2', default_before_word: '前回【後】: ', default_after_word: ' kg' }, |  |
| {id:12, category: 0x03, item_name: '透析【前】/DW', type:'number', print_format: '【前】体重/DW: @data kg', default_format: '3.2', default_before_word: '【前】体重/DW: ', default_after_word: ' kg' }, |  |
| {id:13, category: 0x02, item_name: '透析【後】/DW', type:'number', print_format: '【後】体重/DW: @data kg', default_format: '3.2', default_before_word: '【後】体重/DW: ', default_after_word: ' kg' }, |  |
| {id:14, category: 0x03, item_name: '体重増減', type:'number', print_format: '体重増減: @data kg', default_format: '3.2', default_before_word: '体重増減: ', default_after_word: ' kg' }, |  |
| {id:15, category: 0x02, item_name: '体重前後差', type:'number', print_format: '体重前後差: @data kg', default_format: '3.2', default_before_word: '体重前後差: ', default_after_word: ' kg' }, |  |
| {id:16, category: 0x03, item_name: '除水目標値', type:'number', print_format: '除水目標: @data kg', default_format: '3.2', default_before_word: '除水目標: ', default_after_word: ' kg' }, |  |
| {id:17, category: 0x03, item_name: '除水制限', type:'number', print_format: '除水制限: @data kg', default_format: '3.2', default_before_word: '除水制限: ', default_after_word: ' kg' }, |  |
| {id:18, category: 0x03, item_name: '引き残し', type:'number', print_format: '引き残し: @data kg', default_format: '3.2', default_before_word: '引き残し: ', default_after_word: ' kg' }, |  |
| {id:19, category: 0x03, item_name: '風袋補正値', type:'number', print_format: '風袋補正: @data kg', default_format: '3.2', default_before_word: '風袋補正: ', default_after_word: ' kg' }, |  |
| {id:20, category: 0x03, item_name: '除水補正値', type:'number', print_format: '除水補正: @data kg', default_format: '3.2', default_before_word: '除水補正: ', default_after_word: ' kg' }, |  |
| {id:21, category: 0x03, item_name: 'DWから', type:'number', print_format: 'DWから: @data kg', default_format: '3.2', default_before_word: 'DWから: ', default_after_word: ' kg' }, |  |
| {id:22, category: 0x03, item_name: '目標体重から', type:'number', print_format: '目標体重から: @data kg', default_format: '3.2', default_before_word: '目標体重から: ', default_after_word: ' kg' }, |  |
| {id:23, category: 0x03, item_name: '前回から', type:'number', print_format: '前回から: @data kg', default_format: '3.2', default_before_word: '前回から: ', default_after_word: ' kg' }, |  |
| {id:24, category: 0x07, item_name: 'BMI', type:'number', print_format: 'BMI: @data kg/m2', default_format: '3.1', default_before_word: 'BMI: ', default_after_word: ' kg/m2' }, |  |
| {id:35, category: 0x0F, item_name: '罫線', type:'hr', print_format: '', default_format: '', default_before_word: '', default_after_word: '' }, |  |
| {id:26, category: 0x0F, item_name: 'バーコード（NW-7）', type:'NW-7', print_format: '@data', default_format: '1234567890123', default_before_word: '', default_after_word: '' }, |  |
| {id:27, category: 0x0F, item_name: 'バーコード（JAN13）', type:'JAN13', print_format: '@data', default_format: '1234567890123', default_before_word: '', default_after_word: '' }, |  |
| {id:28, category: 0x07, item_name: '次回予定日', type:'date', print_format: '次回予定: @data', default_format: 'MM/DD hh:mm', default_before_word: '次回予定: ', default_after_word: '' }, |  |
| {id:29, category: 0x0F, item_name: '施設名称', type:'text', print_format: '@data', default_format: 'xxxxxxxx', default_before_word: '', default_after_word: '' }, |  |
| {id:30, category: 0x0F, item_name: '用紙カット', type:'cut', print_format: '＜用紙カットする＞', default_format: '', default_before_word: '', default_after_word: '' }] |  |
