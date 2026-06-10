# ord_personal_prescription

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `ord_personal_prescription`
- Logical name: 処方情報
- Physical name: `ord_personal_prescription`
- Prefix group: `order-treatment`
- User: `nkk6`
- Tablespace DB: `ntss_db6`
- Tablespace INDEX: `ntss_index6`
- Primary key definition: `ord_prescription_no`
- Column count: 39
- NOT NULL columns: 10

## Related Config / Notes

- [../config/ord_personal_prescription.insu_info.md](../config/ord_personal_prescription.insu_info.md)
- [../config/ord_personal_prescription.insu_pub_info.md](../config/ord_personal_prescription.insu_pub_info.md)
- [../config/ord_personal_prescription.insu_set_info.md](../config/ord_personal_prescription.insu_set_info.md)
- [../config/ord_personal_prescription.insu_self_info.md](../config/ord_personal_prescription.insu_self_info.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 処方オーダー番号 | ord_prescription_no | bigint |  | 1 |  | ord_prescription.ord_prescription_no |
|  | 施設コード | facility_cd | character varying | 6 | 1 |  | mst_facility.facility_cd |
|  | 患者ID | pat_id | bigint |  | 1 |  | pat_main.pat_id |
|  | 保険情報コード | insurance_cd | bigint |  |  |  | pat_insurance.insurance_cd |
|  | 公費負担者番号 | insu_pub_no | character varying |  |  |  | 暗号化対象<br>選択した保険が<br>公費の場合：pat_insurance.insu_pub_info.insu_pub_no<br>セットの場合：pat_insurance.insu_set_info.insu_pub1_cdのpat_insurance.insu_pub_info.insu_pub_no<br>insu_pub1_cd>insu_pub2_cd＞insu_pub3_cd＞insu_pub4_cdの優先で登録する<br>それ以外：NULL |
|  | 公費負担医療の受給者番号 | insu_pub_pat_no | character varying |  |  |  | 暗号化対象<br>選択した保険が<br>公費の場合：pat_insurance.insu_pub_info.insu_pub_pat_no<br>セットの場合：pat_insurance.insu_set_info.insu_pub1_cdのpat_insurance.insu_pub_info.insu_pub_pat_no<br>insu_pub1_cd>insu_pub2_cd＞insu_pub3_cd＞insu_pub4_cdの優先で登録する<br>それ以外：NULL |
|  | 保険者番号 | insu_no | character varying |  |  |  | 暗号化対象<br>選択した保険が<br>保険の場合：pat_insurance.insu_info.insu_no<br>セットの場合：pat_insurance.insu_set_info.insu_cdのpat_insurance.insu_info.insu_no<br>それ以外：NULL |
|  | 被保険者証・被保険者手帳記号 | insu_pat_mark | character varying |  |  |  | 暗号化対象<br>選択した保険が<br>保険の場合：pat_insurance.insu_info.insu_pat_mark<br>セットの場合：pat_insurance.insu_set_info.insu_cdのpat_insurance.insu_info.insu_pat_mark<br>それ以外：NULL |
|  | 被保険者証・被保険者手帳番号 | insu_pat_no | character varying |  |  |  | 暗号化対象<br>選択した保険が<br>保険の場合：pat_insurance.insu_info.insu_pat_no<br>セットの場合：pat_insurance.insu_set_info.insu_cdのpat_insurance.insu_info.insu_pat_no<br>それ以外：NULL |
|  | 被保険者 | is_insured | character varying | 1 |  |  | 0：OFF、1：ON<br>選択した保険が<br>保険の場合：pat_insurance.insu_info.insu_kbn=0の場合1、pat_insurance.insu_info.insu_kbn=1の場合0<br>公費の場合：1<br>セットの場合：insu_pub1_cd～insu_pub4_cdに設定がある場合は1、ない場合はpat_insurance.insu_set_info.insu_cdがpat_insurance.insu_info.insu_kbn=0の場合1、0の場合0<br>自費の場合：0 |
|  | 被扶養者 | is_dependent | character varying | 1 |  |  | 0：OFF、1：ON<br>選択した保険が<br>保険の場合：pat_insurance.insu_info.insu_kbn=0の場合0、pat_insurance.insu_info.insu_kbn=1の場合1<br>公費の場合：0<br>セットの場合：pat_insurance.insu_info.insu_kbn=0の場合0、pat_insurance.insu_info.insu_kbn=1の場合1<br>自費の場合：0 |
|  | 保険区分 | insu_kbn | character varying |  |  |  | is_insured=0 AND is_dependent＝0の場合：「被保険者　・　被扶養者」を格納<br>is_insured=1 AND is_dependent＝0の場合：「被保険者」を格納<br>is_insured=0 AND is_dependent＝1の場合：「被扶養者」を格納<br>is_insured=1 AND is_dependent＝1の場合：「被保険者　・　被扶養者」を格納 |
|  | 保険医ID | insu_dr_id | bigint |  |  |  | user_id |
|  | 保険医氏名 | insu_dr_name | character varying |  |  |  | 暗号化（[復号:mst_personal_user.user_last_name]＋[全角スペース]＋[復号:mst_personal_user.user_first_name]） |
|  | 保険医署名 | insu_dr_sign | character varying |  |  |  | 変更不可が1つでもある場合は保険医名と同じものを格納 |
|  | 疑義照会 | is_doubt | character varying | 1 | 1 |  | 0：OFF、1：ON |
|  | 情報提供 | is_information | character varying | 1 | 1 |  | 0：OFF、1：ON |
|  | 高一 | is_elderly | character varying | 1 | 1 |  | 0：OFF、1：ON |
|  | 高７ | is_elderly7 | character varying | 1 | 1 |  | 0：OFF、1：ON |
|  | ６歳未満 | is_child | character varying | 1 | 1 |  | 0：OFF、1：ON |
|  | 備考情報 | remarks | character varying |  |  |  | 「高一」「高７」「６歳未満」でチェックボックスONになっているものを「、」区切りで格納。<br>例)高一：ON、高７：OFF、６歳未満：ONの場合<br>高一、６歳未満 |
|  | 麻薬処方フラグ | is_anesthesia | character varying | 1 | 1 |  | 0：OFF、1：ON |
|  | 麻薬備考情報 | remarks_anesthesia | character varying |  |  |  | 麻薬処方を含むがONの場合には以下を格納する<br>麻薬施用者免許証番号：[復号:mst_personal_user.anesthesiologist_license_no][改行]<br>患者住所：[復号:pat_personal_main.pat_contact_info."address"] |
|  | 備考フリーコメント | remarks_free | character varying |  |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' |  |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | FNW+で管理する施設内の一意な薬剤グループコード | fn_ord_prescription_no | varchar |  |  |  |  |
|  | 名前 | insurance_name | character varying |  |  |  |  |
|  | 略称 | insu_name_short | character varying |  |  |  |  |
|  | 保険情報 | insu_info | jsonb |  |  |  | ＠insu_info参考 |
|  | 公費情報 | insu_pub_info | jsonb |  |  |  | ＠insu_pub_info参考 |
|  | セット情報 | insu_set_info | jsonb |  |  |  | ＠insu_set_info参考 |
|  | 自費情報 | insu_self_info | jsonb |  |  |  | ＠insu_self_info参考 |
|  | 保険メモ1 | memo1 | character varying |  |  |  |  |
|  | 保険メモ2 | memo2 | character varying |  |  |  |  |
|  | リフィル可 | is_refill | character varying | 1 | 1 |  | 0：OFF、1：ON |
|  | リフィル回数 | refill_num | integer |  |  |  |  |
