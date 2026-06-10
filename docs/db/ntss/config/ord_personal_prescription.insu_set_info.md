# 処方情報.insu_set_info

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@処方情報.insu_set_info`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 | col5 | col6 |
| --- | --- | --- | --- | --- | --- |
| セット情報 |  |  |  |  |  |
| [{ |  |  |  |  | 保険の場合 |
| insu_class | String |  | 保険区分（０：保険） |  |  |
| insu_pat_name | String |  | 保険者名称 |  |  |
| insu_pat_no | String | 暗号化 | 保険者番号 | ８桁 |  |
| insu_kbn | String |  | 保険区分 | ０：被保険者、１：被扶養者 |  |
| insu_pat_mark | String | 暗号化 | 被保険者記号 |  |  |
| cki_class | String |  | 長期高額療養 | ０：対象外、１：対象者、２：１０００円対象者、３：２０００円対象者 |  |
| kki_class | String |  | 高額受給者又は後期高齢者療養 | ０：対象外、１：一般、２：７割給付 |  |
| und_six | String |  | 6歳未満 | ０：対象外、１：６歳未満 |  |
| futan-g | String |  | 負担率（外来） |  |  |
| futan-n | String |  | 負担率（入院） |  |  |
| insu_cd | String |  | 保険CD |  |  |
| insu_no | String | 暗号化 | 保険者番号 |  |  |
| insu_info_name | String | 暗号化 | 保険名称 |  |  |
| insu_info_name_short | String |  | 保険略称 |  |  |
| }, |  |  |  |  |  |
| { |  |  |  |  | 公費1の場合 |
| insu_class | String |  | 保険区分（１：公費） |  |  |
| insu_pub1_cd | String |  | 保険情報コード |  |  |
| insu_pub1_info_name | String |  | 保険名称 |  |  |
| insu_pub1_info_name_short | String |  | 保険略称 |  |  |
| insu_pub1_name | String | 暗号化 | 公費負担者名 |  |  |
| insu_pub1_no | String | 暗号化 | 公費負担者番号（8桁） |  |  |
| insu_pub1_pat_no | String | 暗号化 | 公費受給者番号 |  |  |
| insu_pub1_passbook_no | String | 暗号化 | 保険情報.障碍者手帳番号 |  |  |
| }, |  |  |  |  |  |
| { |  |  |  |  | 公費2の場合 |
| insu_class | String |  | 保険区分（１：公費） |  |  |
| insu_pub2_cd | String |  | 保険情報コード |  |  |
| insu_pub2_info_name | String |  | 保険名称 |  |  |
| insu_pub2_info_name_short | String |  | 保険略称 |  |  |
| insu_pub2_name | String |  | 公費負担者名 |  |  |
| insu_pub2_no | String |  | 公費負担者番号（8桁） |  |  |
| insu_pub2_pat_no | String |  | 公費受給者番号 |  |  |
| insu_pub2_passbook_no | String |  | 保険情報.障碍者手帳番号 |  |  |
| }, |  |  |  |  |  |
| { |  |  |  |  | 公費3の場合 |
| insu_class | String |  | 保険区分（１：公費） |  |  |
| insu_pub3_cd | String |  | 保険情報コード |  |  |
| insu_pub3_info_name | String |  | 保険名称 |  |  |
| insu_pub3_info_name_short | String |  | 保険略称 |  |  |
| insu_pub3_name | String |  | 公費負担者名 |  |  |
| insu_pub3_no | String |  | 公費負担者番号（8桁） |  |  |
| insu_pub3_pat_no | String |  | 公費受給者番号 |  |  |
| insu_pub3_passbook_no | String |  | 保険情報.障碍者手帳番号 |  |  |
| }, |  |  |  |  |  |
| { |  |  |  |  | 公費4の場合 |
| insu_class | String |  | 保険区分（１：公費） |  |  |
| insu_pub4_cd | String |  | 保険情報コード |  |  |
| insu_pub4_info_name | String |  | 保険名称 |  |  |
| insu_pub4_info_name_short | String |  | 保険略称 |  |  |
| insu_pub4_name | String |  | 負担者名 |  |  |
| insu_pub4_no | String |  | 公費負担者名 |  |  |
| insu_pub4_pat_no | String |  | 公費負担者番号（8桁） |  |  |
| insu_pub4_passbook_no | String |  | 公費受給者番号 |  |  |
|  |  |  | 保険情報.障碍者手帳番号 |  |  |
| } |  |  |  |  |  |
| }] |  |  |  |  |  |
