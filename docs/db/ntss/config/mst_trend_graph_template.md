# mst_trend_graph_template

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_trend_graph_template`
- Category: config/reference

## Content

| col1 | col2 | col3 |
| --- | --- | --- |
| グラフ系列情報 |  |  |
| [{ |  |  |
| moni_cd | Number | 表示項目モニタデータコード |
| moni_name | String | 表示項目モニタデータ名称 |
| target_value | Number | 目標値 |
| limit_value_mode | String | 上下限値指定方法 ('0':数値 '1':%) |
| upper_value | Number | 上限値 |
| lower_value | Number | 下限値 |
| is_show_target_line | String | 目標線表示 ('0':しない '1':する) |
| line_color | String | 線色(16進表記) |
| axis_direction | Number | 使用縦軸(0:左、1:右) |
| }, |  |  |
| … |  |  |
| }] |  |  |
