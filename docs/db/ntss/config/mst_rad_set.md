# mst_rad_set

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_rad_set`
- Category: config/reference

## Content

| col1 | col2 | col3 |
| --- | --- | --- |
| 放射線検査項目情報 |  |  |
| [{ |  |  |
| ctl_no | Number | コード区分（1:方法　2:区分　3:部位　4:左右　5:体位　6:方向） |
| ctl_name | String | 区分名称（付帯情報名称） |
| item_cd | String | 放射線検査コード（連携コード） |
| item_class | String | 属性コード |
| }..] |  |  |
| ※コード区分分（常に6個）繰り返し |  |  |
