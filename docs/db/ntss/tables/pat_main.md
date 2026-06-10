# pat_main

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `pat_main`
- Logical name: 患者基本情報
- Physical name: `pat_main`
- Prefix group: `patient`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `pat_id`
- Column count: 33
- NOT NULL columns: 1

## Related Config / Notes

- [../config/pat_main.addition_info.md](../config/pat_main.addition_info.md)
- [../config/device_set_info.md](../config/device_set_info.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意な患者ID | pat_id | bigint |  | 1 |  | pat_personal.pat_id |
|  | 登録施設コード | facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード |
|  | 同姓同名 | is_same | character varying | 1 |  |  | '0'：なし、'1'：あり |
|  | インプラント有無 | is_implant | character varying | 1 |  |  | '0'：なし、'1'：あり |
|  | 感染症有無 | is_infect | character varying | 1 |  |  | '0'：なし、'1'：あり |
|  | 糖尿病患者扱い | is_diabetes | character varying | 1 |  |  | '0'：対象外、'1'：対象 |
|  | 血糖検査有無 | is_blood_suger_exam | character varying | 1 |  |  | '0'：なし、'1'：あり |
|  | 車いす有無 | is_wheel_chair | character varying | 1 |  |  | '0'：なし、'1'：あり |
|  | 確定転入出状態 | in_out_current_state | character varying | 2 |  |  | 0:在院、1:導入予定、2:転入予定、3:転出、7:離脱、8:移植、9:一時転出、10:不明、11:死亡<br><br>【転入転出画面での操作】<br>・転入転出画面更新時に登録する。<br>※「患者転入出情報.転入出区分」値と「患者転入出情報.開始日」値から変換する<br>【ＤＢアプリでの自動更新】<br>・「予定転入出日」の当日 または 翌日の日時処理にて自動更新する。 |
|  | 予定転入出状態 | in_out_plan_state | character varying | 2 |  |  | 0:在院、1:導入予定、2:転入予定、3:転出、7:離脱、8:移植、9:一時転出、10:不明、11:死亡<br><br>【転入転出画面での操作】<br>・転入転出画面更新時に登録する。<br>※「患者転入出情報.転入出区分」値と「患者転入出情報.開始日」値から変換する<br>【ＤＢアプリでの自動更新】<br>・「予定転入出日」の当日 または 翌日の日時処理にて自動更新する。 |
|  | 予定転入出日時 | in_out_plan_date | timestamp(3) |  |  |  | ・転入転出画面更新時及びＤＢアプリ「予定転入出日」の当日 または 翌日の日時処理にて更新する。<br>※転入出情報が無ければNULLとする。<br>※上記以外は、「患者転入出情報.発生日時」の値を登録する。 |
|  | 患者メモ情報 | pat_memo_info | jsonb |  |  |  | [<br>  {<br>    "ctl_no":(Number)管理番号,<br>    "title":(String)タイトル,<br>    "content":(String)内容<br>  },・・・<br>] |
|  | 加算情報 | addition_info | jsonb |  |  |  | @pat_main.addition_infoシートで参考<br>レセプトメモ<br>[<br>  {<br>    "ctl_no":管理番号,<br>    "receipt_memo_code":レセプトメモコード,<br>    "is_add":加算有無　※'0'：加算なし、'1'：加算あり<br>    "reg_date":登録日時<br>  },・・・<br>]<br>※備考<br>レセプトメモ区分：'0'の場合、透析困難コメントマスタ情報からコード、更新日時、名称を取得<br>レセプトメモ区分：'1'の場合、レセプトメモマスタ情報からコード、更新日時、名称を取得<br><br>※同一項目(コードが一致する項目)の登録は許容しない<br>※透析困難コメントと同じような排他制御にはしない<br>※is_addが不要な場合は患者新規登録時に展開する必要はない<br>　　→データが存在する場合は加算あり扱い |
|  | 担当スタッフ情報 | charge_staff_info | jsonb |  |  |  | [<br>  {<br>    "ctl_no":(Number)管理番号,<br>    "disp_order":(Number)表示順,<br>    "staff_cd":(Number)スタッフマスタ.スタッフコード<br>    "is_main":(String)主治医<br>    "is_charge":(String)受持ち<br>    "is_puncture":(String)穿刺<br>  },・・・<br>] |
|  | 患者グループ情報 | pat_group_info | jsonb |  |  |  | [<br>  {<br>    "ctl_no":管理番号<br>    "pat_group_cd":患者グループマスタ.患者グループコード<br>  },･･･<br>]<br><br>↓ 10/13 打ち合わせ内容(DocBase)<br>患者グループについてはカスタムキーと統合する<br>↑ ここまで |
|  | 禁忌・アレルギー情報 | taboo_allergy_info | jsonb |  |  |  | [<br>  {<br>    "ctl_no":(Number)管理番号<br>    "disp_order":(Number)表示順<br>    "content":(String)内容<br>    "memo":(String)備考<br>    "category_class":(String)対象区分　※0:禁忌・アレルギー、1:薬剤、2:調製薬剤、3:医療材料、4:ダイアライザ、5:フリーワード<br>    "taboo_allergy_class": (String)'1':禁忌、'2':アレルギー<br>    "taboo_allergy_cd":(String)禁忌・アレルギーコード<br>  },・・・<br>]<br>※備考<br>TABOO_CLASS='0'の場合、禁忌・アレルギー.禁忌・アレルギーコード<br>TABOO_CLASS='1'の場合、薬剤マスタ.薬剤コード<br>TABOO_CLASS='2'の場合、調製薬剤マスタ.調製薬剤コード<br>TABOO_CLASS='3'の場合、医療材料マスタ.医療材料コード<br>TABOO_CLASS='4'の場合、ダイアライザマスタ.ダイアライザコード<br>TABOO_CLASS='5'の場合、null |
|  | 感染症情報 | infect_info | jsonb |  |  |  | [<br>  {<br>    "ctl_no":(Number)管理番号,<br>    "infection_cd":(Number)感染症コード,<br>    "infect":(String)結果コード,　※0：不明、1：(-)、2：(+)<br>    "exam_date":(String)検査日<br>    "up_date": (String)更新日時<br>  },・・・<br>]<br><br>※同一項目(コードが一致する項目)の登録は許容しない |
|  | インプラント情報 | implant_info | jsonb |  |  |  | [<br>  {<br>    "ctl_no":管理番号<br>    "disp_order":表示順<br>    "implant_cd":インプラントコード<br>    "reg_date":導入日<br>    "remove_date":除去日<br>  },・・・<br>] |
|  | 風袋補正情報 | tare_info | jsonb |  |  |  | {<br>  "1": {<br>         "name_1": "項目1名称", "weight_1": 項目1重さ(数値),<br>         "name_2": "項目2名称", "weight_2": 項目2重さ(数値),<br>         "name_3": "項目3名称", "weight_3": 項目3重さ(数値),<br>         "name_4": "項目4名称", "weight_4": 項目4重さ(数値),<br>         "name_5": "項目5名称", "weight_5": 項目5重さ(数値)<br>       },<br>  "2": {<br>         "name_1": "項目1名称", "weight_1": 項目1重さ(数値),<br>         "name_2": "項目2名称", "weight_2": 項目2重さ(数値),<br>         "name_3": "項目3名称", "weight_3": 項目3重さ(数値),<br>         "name_4": "項目4名称", "weight_4": 項目4重さ(数値),<br>         "name_5": "項目5名称", "weight_5": 項目5重さ(数値)<br>       },<br>  --- ※省略 ---<br>  "7": {<br>         "name_1": "項目1名称", "weight_1": 項目1重さ(数値),<br>         "name_2": "項目2名称", "weight_2": 項目2重さ(数値),<br>         "name_3": "項目3名称", "weight_3": 項目3重さ(数値),<br>         "name_4": "項目4名称", "weight_4": 項目4重さ(数値),<br>         "name_5": "項目5名称", "weight_5": 項目5重さ(数値)<br>       }<br>}<br>※キーの"1"～"7"は曜日を示す("1"：月曜日、"2"：火曜日、…、"7"：日曜日)<br>※重さは、g 換算で登録する(画面上で kg で表示していたとしても g に換算して登録する) |
|  | 除水補正情報 | off_water_info | jsonb |  |  |  | {<br>  "1": {<br>         "name_1": "項目1名称", "weight_1": 項目1重さ(数値),<br>         "name_2": "項目2名称", "weight_2": 項目2重さ(数値),<br>         "name_3": "項目3名称", "weight_3": 項目3重さ(数値),<br>         "name_4": "項目4名称", "weight_4": 項目4重さ(数値),<br>         "name_5": "項目5名称", "weight_5": 項目5重さ(数値)<br>       },<br>  "2": {<br>         "name_1": "項目1名称", "weight_1": 項目1重さ(数値),<br>         "name_2": "項目2名称", "weight_2": 項目2重さ(数値),<br>         "name_3": "項目3名称", "weight_3": 項目3重さ(数値),<br>         "name_4": "項目4名称", "weight_4": 項目4重さ(数値),<br>         "name_5": "項目5名称", "weight_5": 項目5重さ(数値)<br>       },<br>  --- ※省略 ---<br>  "7": {<br>         "name_1": "項目1名称", "weight_1": 項目1重さ(数値),<br>         "name_2": "項目2名称", "weight_2": 項目2重さ(数値),<br>         "name_3": "項目3名称", "weight_3": 項目3重さ(数値),<br>         "name_4": "項目4名称", "weight_4": 項目4重さ(数値),<br>         "name_5": "項目5名称", "weight_5": 項目5重さ(数値)<br>       }<br>}<br>※キーの"1"～"7"は曜日を示す("1"：月曜日、"2"：火曜日、…、"7"：日曜日)<br>※重さは、g 換算で登録する(画面上で kg で表示していたとしても g に換算して登録する) |
|  | 装置設定情報 | device_set_info | jsonb |  |  |  | 「@device_set_info」シート参照 |
|  | 治療進捗状態 | acceptance_status_info | jsonb |  |  |  | [<br>  {<br>    "ord_no":(Number)オーダー番号,<br>    "class": (String)治療情報.実績：治療状況,<br>    "treatment_time": (Number)治療情報.指示：治療条件情報(治療時間)<br>    "start_date_time": (String)治療情報.実績：治療開始日時(※1)<br>  }<br>]<br>※1 ISO8601形式 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 共通診療情報 | medical_care_info | jsonb |  |  | E'{"main_course_cd":null, "dialysis_course_cd":null, "ward_cd":null, "dialysis_count":null, "purification_count":null, "other_dialysis_count":null, "facility_cd":null, "dialysis_start_date":null, "hospital_start_date":null}' | {<br>  "main_course_cd":診療科マスタ.診療科コード　※主科コード,<br>  "dialysis_course_cd":(Number)診療科マスタ.診療科コード　※透析実施科コード,<br>  "ward_cd":(Number)病棟マスタ.病棟コード,<br>  "dialysis_count":(Number)透析回数,<br>  "purification_count":(Number)浄化治療回数,<br>  "other_dialysis_count":(Number)他施設透析回数,<br>  "facility_cd":(String)施設マスタ.施設コード　※導入施設コード,<br>  "dialysis_start_date":(String)透析導入日,<br>  "hospital_start_date":(String)当院開始日,<br>  "pat_dialysis_count":(String)自施設透析回数<br>}<br><br>↓ 10/13 打ち合わせ内容(DocBase)<br>診療情報は以下の2つのカラムで管理する<br>※「個人情報_患者情報・利用者情報.xlsx」参照<br>★データの持ち方については効率的な手段を採用する（YSK検討）<br>⇒禁忌情報、感染症情報、既往歴情報、受診歴情報、身体情報にも反映する<br>共通診療情報<br>固有診療情報<br>↑ ここまで |
|  | スケジュール延長最終日 | sch_ext_end_date | character varying | 8 |  |  | YYYYMMDD形式<br>スケジュール自動延長処理で作成された最終処理日<br><br>※基本的に月末日が登録される。<br>※終了日未設定の予定作成時やスケジュール自動延長処理にて登録する。<br>※終了日未設定の予定作成をすべて中止した場合はnullとする。<br>※値が登録されている状態で、終了日未指定の予定作成をする場合、この日付までの予定を作成する。 |
|  | スケジュール延長処理ステータス | sch_ext_status | character varying | 1 |  | '0' | '0':停止、'1':スケジュール自動延長処理中<br><br>※スケジュール自動延長処理中は、ユーザによる終了日未指定の予定操作を制限する。 |
|  | アクセスカード番号 | card_idm | character varying |  |  |  |  |
|  | 旧更新日時 | old_up_date | timestamp(3) |  |  |  |  |
|  | ホスト報知情報 | host_notification_info | jsonb |  |  |  | ※「@mst_device_set_info_default」シート参照 |
|  | 旧更新日時 | old_up_date | timestamp(3) |  |  |  |  |
|  | 車いすコード | wheel_chair_cd | bigint |  |  |  | 患者に割り当てた共用車いすのコード<br><br>※車いすマスタの個人所有とは別に、1つの車いすを複数患者に割り当てる用の項目<br>※割り当たっている車いすが個人所有に変えられた場合、車いすコードはnullに戻される |
