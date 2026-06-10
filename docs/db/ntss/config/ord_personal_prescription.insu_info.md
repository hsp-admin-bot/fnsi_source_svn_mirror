# 処方情報.insu_info

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@処方情報.insu_info`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 | col5 |
| --- | --- | --- | --- | --- |
| 保険情報 |  |  |  |  |
| { |  |  |  |  |
| insu_no | String | 暗号化 | 保険者番号 |  |
| insu_pat_name | String | 暗号化 | 保険者名称 |  |
| insu_pat_no | String | 暗号化 | 被保険者番号 | ８桁 |
| insu_kbn | String |  | 保険区分 | ０：被保険者、１：被扶養者 |
| insu_pat_mark | String | 暗号化 | 被保険者記号 |  |
| cki_class | String |  |  | ０：対象外、１：対象者、２：１０００円対象者、３：２０００円対象者 |
| kki_class | String |  |  | ０：対象外、１：一般、２：７割給付 |
| und_six | String |  |  | ０：対象外、１：６歳未満 |
| futan-g | String |  | 負担率（外来） |  |
| futan-n | String |  | 負担率（入院） |  |
| } |  |  |  |  |
