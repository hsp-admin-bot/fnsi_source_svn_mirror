# ord_main_restore

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `ord_main_restore`
- Logical name: 治療情報復元
- Physical name: `ord_main_restore`
- Prefix group: `order-treatment`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `ord_no,del_date`
- Column count: 89
- NOT NULL columns: 2

## Related Config / Notes

- [../config/ord_main.tmp_report_info.md](../config/ord_main.tmp_report_info.md)
- [../config/ord_main.addition_info.md](../config/ord_main.addition_info.md)
- [../config/sheet_8.md](../config/sheet_8.md)
- [../config/ind_device_set_info.md](../config/ind_device_set_info.md)
- [../config/ord_main_20180929.md](../config/ord_main_20180929.md)
- [../config/ord_main_20180905.md](../config/ord_main_20180905.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | システムで管理する一意なオーダ番号 | ord_no | bigserial |  | 1 |  |  |
| 1 | 削除日時 | del_date | timestamp(3) |  | 1 |  |  |
|  | システムで管理する一意な患者ID | pat_id | bigint |  |  |  |  |
|  | FNW+で管理する施設内の一意な患者ID | fn_pat_id | character varying | 12 |  |  | FNW+フィードバック用 |
|  | 治療日 | treat_date | character varying | 8 |  |  | YYYYMMDD形式 |
|  | 治療曜日 | treat_week | smallint |  |  |  | 1：月曜日 ～ 7：日曜日<br>※検索用 |
|  | 施設コード | facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード |
|  | 施設名 | facility_name | character varying | 40 |  |  | 施設マスタ.施設名 |
|  | 指示：VAコード | ind_va_cd | integer |  |  |  | VAマスタ.VAコード<br>※FNW+ではベッドとの条件不一致の検索に使用している<br>※別途、スケジュールテーブル(仮称)を作成してそこへ格納することも検討する<br>　　スケジュールテーブル(仮称)の目的は、クール・ベッド・治療時間などで予定が<br>　　埋まっている/埋まっていないのチェックに使用する |
|  | 指示：治療方法コード | ind_treatment_cd | integer |  |  |  | 治療方法マスタ.治療方法コード<br>※NTSSでは治療条件から除外する |
|  | 指示：治療方法名 | ind_treatment_name | character varying |  |  |  | ※一度削除したが復活(治療条件から除外するため)<br>治療方法マスタ.治療方法名 |
|  | 指示：クールコード | ind_kur_cd | bigint |  |  |  | クールマスタ.クールコード<br>※クール未登録の場合、 0 を登録する<br>※最新情報を参照する場合に使用 |
|  | 指示：クール名 | ind_kur_name | character varying |  |  |  | クールマスタ.クール名<br>※過去情報を参照する場合に使用<br><br>・条件送信前は空<br>・条件送信時にクール名展開<br>・未実施予定については過去日付切替り時に展開 |
|  | 指示：治療開始時刻 | ind_treat_start_time | character varying | 4 |  |  | HHMM形式<br>※NTSSでは治療条件から除する |
|  | 指示：ベッドコード | ind_bed_cd | bigint |  |  |  | ベッドマスタ.ベッドコード<br>※ベッド未登録の場合、0 を登録する<br>※最新情報を参照する場合に使用 |
|  | 指示：ベッド名 | ind_bed_name | character varying | ？ |  |  | ベッドマスタ.ベッド名<br>※過去情報を参照する場合に使用<br><br>・条件送信前は空<br>・条件送信時にベッド名展開<br>・未実施予定については過去日付切替り時に展開 |
|  | 装置モード | ind_device_mode | numeric | 5,2 |  |  |  |
|  | 指示：DW指示者情報 | ind_dw_user_info | jsonb |  |  |  | ■Json構造<br>{<br>  "ind_user_id": (Number)指示者コード(利用者マスタ.利用者ID),<br>  "ind_user_last_name": (String)指示者名_姓(利用者マスタ.利用者名_姓),<br>  "ind_user_first_name": (String)指示者名_名(利用者マスタ.利用者名_名),<br>  "upd_user_id": (Number)更新者コード(利用者マスタ.利用者ID),<br>  "upd_user_last_name": (String)更新者名_姓(利用者マスタ.利用者名_姓),<br>  "upd_user_first_name": (String)更新者名_名(利用者マスタ.利用者名_名)<br>}<br>■概要<br>条件送信時に、身体情報からind_dwにデータ展開するのに合わせてその指示者、更新者情報も展開する。利用場所は「指示受付指示承認 > 治療単位」 |
|  | 指示：治療予定指示者情報 | ind_schedule_user_info | jsonb |  |  |  | ■Json構造<br>{<br>  "ind_user_id": (Number)指示者コード(利用者マスタ.利用者ID),<br>  "ind_user_last_name": (String)指示者名_姓(利用者マスタ.利用者名_姓),<br>  "ind_user_first_name": (String)指示者名_名(利用者マスタ.利用者名_名),<br>  "upd_user_id": (Number)更新者コード(利用者マスタ.利用者ID),<br>  "upd_user_last_name": (String)更新者名_姓(利用者マスタ.利用者名_姓),<br>  "upd_user_first_name": (String)更新者名_名(利用者マスタ.利用者名_名)<br>}<br>■概要<br>治療予定新規作成、スケジュール情報(クール、治療開始時刻、ベッド)の変更、治療日の移動などの操作時に登録する。 |
|  | 指示：治療条件情報 | ind_cond_info | jsonb |  |  |  | ■Json構造<br>{<br>  "治療条件項目番号": (*1)<br>  {<br>    "value": (Number)設定値, (*2)<br>    "value_name_1": (String)翻訳1, (*3)(*4)<br>    "unit": (String)単位, (*3)(*5)<br>    "medicine_type": (Number)薬剤区分, (*5)(*6)<br>    "ind_user_id": (Number)指示者コード(利用者マスタ.利用者ID), (*2)<br>    "ind_user_last_name": (String)指示者名_姓(利用者マスタ.利用者名_姓), (*3)<br>    "ind_user_first_name": (String)指示者名_名(利用者マスタ.利用者名_名), (*3)<br>    "upd_user_id": (Number)更新者コード(利用者マスタ.利用者ID), (*2)<br>    "upd_user_last_name": (String)更新者名_姓(利用者マスタ.利用者名_姓), (*3)<br>    "upd_user_first_name": (String)更新者名_名(利用者マスタ.利用者名_名), (*3)<br>    "input_class": (Number)登録区分, (*2)(*7)<br>    "is_editable": (String)編集可否フラグ, (*2)(*8)<br>    "cop_order_no": (String)連携オーダ番号 (*9)<br>  }, ・・・<br>}<br>■概要<br>(*1) 治療条件項目番号をキーとして設定<br>       (※シート「@治療条件項目」を参照)<br>(*2) 必須(項目によっては、値は null(or 空文字)も可)<br>(*3) 条件送信以降、または過去日付切替り時に登録<br>(*4) value_name_1、value_name_2、… のように、治療条件項目ごとに随時設定<br>(*5) 登録が必要な治療条件項目の場合に設定<br>(*6) 1: 通常薬剤、2: 調製薬剤<br>(*7) 1: クライアントから登録、2: 連携から登録、3～: その他システムから登録<br>(*8) 0: 編集不可、1: 編集可能<br>(*9) 電子カルテからの予約オーダを登録する際に使用<br>　　　　※「00001」→「1」にならないよう、文字列で管理 |
|  | 指示：投与薬剤情報 | ind_medi_info | jsonb |  |  |  | ■Json構造<br>[<br>  {<br>    "no": (Number)識別番号, (*1)<br>    "class_cd": (Number)薬剤分類コード, (*3)<br>    "class_name": (String)薬剤分類名, (*3)<br>    "class_type": (Number)分類区分, (*3)<br>    "medicine_type": (Number)薬剤区分, (*2)(*4)<br>    "cd": (Number)薬剤(調整薬剤)コード, (*2)<br>    "name": (String)薬剤名, (*3)<br>    "short_name": (String)省略薬剤名, (*3)<br>    "unit": (String)単位, (*3)<br>    "amount": (Number)数量, (*2)<br>    "init_date": (String)初回投与日, (*2)(*8)<br>    "date_interval": (Number)投与間隔, (*2)(*9)<br>    "timing_cd": (Number)投与タイミングコード, (*2)<br>    "timing_name": (String)投与タイミング名, (*3)<br>    "procedure_cd": (Number)手技コード, (*2)<br>    "procedure_name": (String)手技名, (*3)<br>    "comment": (String)コメント, (*2)<br>    "ind_user_id": (Number)指示者コード(利用者マスタ.利用者ID), (*2)<br>    "ind_user_last_name": (String)指示者名_姓(利用者マスタ.利用者名_姓), (*3)<br>    "ind_user_first_name": (String)指示者名_名(利用者マスタ.利用者名_名), (*3)<br>    "upd_user_id": (Number)更新者コード(利用者マスタ.利用者ID), (*2)<br>    "upd_user_last_name": (String)更新者名_姓(利用者マスタ.利用者名_姓), (*3)<br>    "upd_user_first_name": (String)更新者名_名(利用者マスタ.利用者名_名), (*3)<br>    "input_class": (Number)登録区分, (*2)(*5)<br>    "is_editable": (String)編集可否フラグ, (*2)(*6)<br>    "cop_order_no": (String)連携オーダ番号 (*7)<br>  }, ・・・<br>]<br>■概要<br>(*1) 投与薬剤を識別するための番号<br>    [概要]<br>      ・新規登録時<br>          識別番号を発行し登録(指定期間内に登録する投与薬剤は同じ識別番号)<br>      ・編集時<br>          数量のみ変更  ：識別番号は変更しない<br>                            (期間内に存在する同識別番号の数量を変更する)<br>          数量以外も変更：新しい識別番号で登録し直す<br>                            (期間内に存在する識別番号の投薬を中止し、登録し直す)<br>      ・中止時<br>          対象となる識別番号を全て中止する<br>    ※識別番号はシーケンス（ord_main_ind_medi_info_no_seq）で管理<br>　　　<br>(*2) 必須(項目によっては、値は null(or 空文字)も可)<br>(*3) 条件送信以降、または過去日付切替り時に登録<br>(*4) 1: 通常薬剤、2: 調製薬剤<br>(*5) 1: クライアントから登録、2: 連携から登録、3～: その他システムから登録<br>(*6) 0: 編集不可、1: 編集可能<br>(*7) 電子カルテからの予約オーダを登録する際に使用<br>　　　　※「00001」→「1」にならないよう、文字列で管理<br>(*8) ISO8601形式<br>(*9) 0:"毎回"<br>      1:"毎週"<br>      2:"1回／2週"<br>      3:"1回／3週"<br>      4:"1回／4週"<br>      5:"1回／月：第1曜日"<br>      6:"1回／月：第2曜日"<br>      7:"1回／月：第3曜日"<br>      8:"1回／月：第4曜日"<br>      9:"1回／月：最終曜日"<br>     10:"1回／月：最終治療日"<br>※曜日パターン変更時の場合、対象の治療予定の投与薬剤は全中止を行う |
|  | 指示：医療材料情報 | ind_equip_info | jsonb |  |  |  | ■Json構造<br>[<br>  {<br>    "class_cd": (Number)医療材料分類コード, (*2)<br>    "class_name": (String)医療材料分類名, (*2)<br>    "class_type": (Number)分類区分, (*2)<br>    "cd": (Number)医療材料コード, (*1)<br>    "name": (String)医療材料名, (*2)<br>    "short_name": (String)省略医療材料名, (*2)<br>    "needle_type": (Number)穿刺針区分, (*3)<br>    "amount": (Number)数量, (*1)<br>    "unit": (String)単位, (*2)<br>    "ind_user_id": (Number)指示者コード(利用者マスタ.利用者ID), (*1)<br>    "ind_user_last_name": (String)指示者名_姓(利用者マスタ.利用者名_姓), (*2)<br>    "ind_user_first_name": (String)指示者名_名(利用者マスタ.利用者名_名), (*2)<br>    "upd_user_id": (Number)更新者コード(利用者マスタ.利用者ID), (*1)<br>    "upd_user_last_name": (String)更新者名_姓(利用者マスタ.利用者名_姓), (*2)<br>    "upd_user_first_name": (String)更新者名_名(利用者マスタ.利用者名_名), (*2)<br>    "input_class": (Number)登録区分, (*1)(*4)<br>    "is_editable": (String)編集可否フラグ, (*1)(*5)<br>    "cop_order_no": (String)連携オーダ番号, (*6)<br>    "equip_type": (Number)医療材料区分 (*1)(*7)<br>  }, ・・・<br>]<br>■概要<br>(*1) 必須(項目によっては、値は null(or 空文字)も可)<br>(*2) 条件送信以降、または過去日付切替り時に登録<br>(*3) 医療材料分類が「穿刺針」の場合に必要(0: 未指定、1: A針、2: V針、3: SN)<br>(*4) 1: クライアントから登録、2: 連携から登録、3～: その他システムから登録<br>(*5) 0: 編集不可、1: 編集可能<br>(*6) 電子カルテからの予約オーダを登録する際に使用。<br>　　　　※「00001」→「1」にならないよう、文字列で管理<br>(*7) 0：医療材料、1：ダイアライザ<br><br>※投与薬剤のように「識別番号」は設けない |
|  | 指示：指示コメント情報 | ind_ind_comment_info | jsonb |  |  |  | ■Json構造<br>[<br>  {<br>    "no": (Number)指示コメント番号, (*1)<br>    "content": (String)内容, (*2)<br>    "ind_user_id": (Number)指示者コード(利用者マスタ.利用者ID), (*2)<br>    "ind_user_last_name": (String)指示者名_姓(利用者マスタ.利用者名_姓), (*3)<br>    "ind_user_first_name": (String)指示者名_名(利用者マスタ.利用者名_名), (*3)<br>    "upd_user_id": (Number)更新者コード(利用者マスタ.利用者ID), (*2)<br>    "upd_user_last_name": (String)更新者名_姓(利用者マスタ.利用者名_姓), (*3)<br>    "upd_user_first_name": (String)更新者名_名(利用者マスタ.利用者名_名), (*3)<br>    "input_class": (Number)登録区分, (*2)(*4)<br>    "is_editable": (String)編集可否フラグ, (*2)(*5)<br>    "cop_order_no": (String)連携オーダ番号 (*6)<br>  }, ・・・<br>]<br>■概要<br>(*1) 指示コメントを識別するための番号(1 ～) ※画面で直接指定<br>    [概要]<br>      ・新規登録時、指示コメント番号を指定し、その番号で発行する<br>      ・編集/中止時、指定した番号に対して更新を行う<br>(*2) 必須(項目によっては、値は null(or 空文字)も可)<br>(*3) 条件送信以降、または過去日付切替り時に登録<br>(*4) 1: クライアントから登録、2: 連携から登録、3～: その他システムから登録<br>(*5) 0: 編集不可、1: 編集可能<br>(*6) 電子カルテからの予約オーダを登録する際に使用<br>　　　　※「00001」→「1」にならないよう、文字列で管理 |
|  | 指示：風袋補正 | ind_tare_info | jsonb |  |  |  | {<br>  "name_1": "項目1名称", "weight_1": 項目1重さ(数値),<br>  "name_2": "項目2名称", "weight_2": 項目2重さ(数値),<br>  "name_3": "項目3名称", "weight_3": 項目3重さ(数値),<br>  "name_4": "項目4名称", "weight_4": 項目4重さ(数値),<br>  "name_5": "項目5名称", "weight_5": 項目5重さ(数値)<br>}<br>※重さは、g 換算で登録する<br>　(画面上で kg で表示していたとしても g に換算して登録する)<br>※指示者が必要か？ |
|  | 指示：除水補正 | ind_off_water_info | jsonb |  |  |  | {<br>  "name_1": "項目1名称", "weight_1": 項目1重さ(数値),<br>  "name_2": "項目2名称", "weight_2": 項目2重さ(数値),<br>  "name_3": "項目3名称", "weight_3": 項目3重さ(数値),<br>  "name_4": "項目4名称", "weight_4": 項目4重さ(数値),<br>  "name_5": "項目5名称", "weight_5": 項目5重さ(数値)<br>}<br>※重さは、g 換算で登録する<br>　(画面上で kg で表示していたとしても g に換算して登録する)<br>※指示者が必要か？ |
|  | 指示：装置設定情報 | ind_device_set_info | jsonb |  |  |  | ■JSON構造<br>「@ind_device_set_info」シート参照 |
|  | 実績：FNW+透析番号 | rst_fn_dialysis_no | bigint |  |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意な透析番号 |
|  | 実績：関連透析番号 | rst_relation_dialysis_no | bigint |  |  |  | FNW+フィードバック用(実績マージ用)<br>準備回収モニタが透析実績をマージするときに関連する透析番号（マージ先） |
|  | 実績：版番号 | rst_edition | integer |  |  | 0 |  |
|  | 実績：版番号更新フラグ | rst_is_update_edition | character varying | 1 |  |  | 0：更新不可、1：更新可<br>- - - - - -<br>過去実績のみ参照<br>何らかの実績情報を編集した際に"1"に更新し、版番号 |
|  | 実績：登録区分 | rst_input_class | smallint |  |  |  | 1：通常(透析装置や通信サーバーなどを伴う治療)<br>2：クライアントで手入力して作成 |
|  | 実績：治療状況 | rst_dialysis_state | character varying | 1 |  | '0' | 0：条件送信前、1：条件送信済、2：条件送信確認済み、3：治療中、4：排液済、<br>5：後体重測定済み(実績未確定)、6：後体重確認済み(過去実績)<br>※要検討<br>※条件送信確認について：未確認で治療を開始した場合に「未確認」の状態が保持されないが問題はないのか：【TDC追記】 |
|  | 実績：治療方法コード | rst_treatment_cd | integer |  |  |  | 治療方法マスタ.治療方法コード<br>※NTSSでは治療条件から除外する |
|  | 実績：治療方法名 | rst_treatment_name | character varying |  |  |  | 治療方法マスタ.治療方法名 |
|  | 実績：クールコード | rst_kur_cd | bigint |  |  |  | クールマスタ.クールコード<br>※クール未登録の場合、 0 を登録する<br>※最新情報を参照する場合に使用 |
|  | 実績：クール名 | rst_kur_name | character varying |  |  |  |  |
|  | 実績：ベッドコード | rst_bed_cd | bigint |  |  |  | ベッドマスタ.ベッドコード<br>※ベッド未登録の場合、0 を登録する<br>※最新情報を参照する場合に使用 |
|  | 実績：ベッド名 | rst_bed_name | character varying |  |  |  |  |
|  | 実績：装置番号 | rst_machine_no | bigint |  |  |  | 装置マスタ.装置番号<br>※要確認<br>　　型式コード、製造番号にするべきかどうか |
|  | 実績：装置名 | rst_machine_name | character varying | 40 |  |  | 装置マスタ.装置名 |
|  | 実績：条件送信日時 | rst_cond_send_date | timestamp(3) |  |  |  |  |
|  | 実績：受付日時 | rst_accept_date | timestamp(3) |  |  |  | 前体重測定日時と同値 |
|  | 実績：治療開始日時 | rst_start_date | timestamp(3) |  |  |  |  |
|  | 実績：治療終了日時 | rst_end_date | timestamp(3) |  |  |  | 手動実績の場合、FNW+では必須項目だったが、null許容とする。<br>ただし、版番確定時には入力必須とする。 |
|  | 実績：帰宅日時 | rst_return_home_date | timestamp(3) |  |  |  | 後体重測定日時と同値 |
|  | 実績：入外区分 | rst_in_out_class | smallint |  |  |  | 0:外来、1:入院 |
|  | 実績：透析回数 | rst_dialysis_cnt | integer |  |  |  | 治療開始時に更新 |
|  | 実績：病棟コード | rst_ward_cd | integer |  |  |  |  |
|  | 実績：病棟名 | rst_ward_name | character varying |  |  |  |  |
|  | 実績：診療科コード | rst_course_cd | integer |  |  |  |  |
|  | 実績：診療科名 | rst_course_name | character varying |  |  |  |  |
|  | 実績：DW | rst_dw | numeric | 5,2 |  |  | 治療記録の治療条件で入力された場合にDWを更新 |
|  | 実績：穿刺者情報 | rst_puncture_user_info | jsonb |  |  |  | ■Json構造<br>{<br>  "user_id_1": 穿刺者コード1<br>  "user_last_name_1": 穿刺者名_姓1<br>  "user_first_name_1": 穿刺者名_名1<br>  "user_id_2": 穿刺者コード2<br>  "user_last_name_2": 穿刺者名_姓2<br>  "user_first_name_2": 穿刺者名_名2<br>  "date": 穿刺日時 (*1)<br>  "date_1":穿刺1登録日時：【TDC追記】<br>  "date_2":穿刺2登録日時：【TDC追記】<br>}<br>■概要<br>(*1) ISO8601形式：【TDC修正】 |
|  | 実績：返血者情報 | rst_return_user_info | jsonb |  |  |  | ■Json構造<br>{<br>  "user_id_1": 返血者コード1,<br>  "user_last_name_1": 返血者名_姓1,<br>  "user_first_name_1": 返血者名_名1,<br>  "user_id_2": 返血者コード2,<br>  "user_last_name_2": 返血者名_姓2,<br>  "user_first_name_2": 返血者名_名2,<br>  "date": 返血日時 (*1)<br>  "date_1":返血1登録日時：【TDC追記】<br>  "date_2":返血2登録日時：【TDC追記】<br>}<br>■概要<br>(*1) ISO8601形式：【TDC修正】 |
|  | 実績：担当者情報 | rst_charge_user_info | jsonb |  |  |  | ■Json構造<br>{<br>  "user_id_1": 担当者コード1,<br>  "user_last_name_1": 担当者名_姓1,<br>  "user_first_name_1": 担当者名_名1,<br>  "user_id_2": 担当者コード2,<br>  "user_last_name_2": 担当者名_姓2,<br>  "user_first_name_2": 担当者名_名2<br>  "date_1":担当者1登録日時：【TDC追記】<br>  "date_2":担当者2登録日時：【TDC追記】<br>}<br>■概要<br>(*1) ISO8601形式：【TDC修正】<br>- - - - - - - - - <br>※担当日時は画面上に存在しない<br>　【FNW+】<br>　　「担当者1」を登録した場合は「担当日時1」に現在日時が登録され、<br>　　「担当者2」を登録した場合は「担当日時2」に現在日時が登録される。<br>　　「担当日時」には登録した時の日時が登録される。<br>　　　※「担当日時」は「担当日時1、2」の存在する中での新しい日時が<br>　　　　　登録されている訳ではない<br>　　　　例）<br>　　　　　「担当者1」：スタッフ1、「担当日時1」：2018/09/01 09:00:00<br>　　　　　「担当者2」：スタッフ2、「担当日時2」：2018/09/01 11:30:00<br>　　　　　　　　　　　　　　　　　　　  「担当日時」：2018/09/01 11:30:00<br>　　　　　　↓<br>　　　　　「担当者1」：スタッフ1、「担当日時1」：2018/09/01 09:00:00<br>　　　　　「担当者2」：未登録、　「担当日時2」：未登録<br>　　　　　　　　　　　　　　　　　　　  「担当日時」：2018/09/01 11:30:00 (※変わらない)<br>　　　　　　↓<br>　　　　　「担当者1」：未登録、「担当日時1」：未登録<br>　　　　　「担当者2」：未登録、「担当日時2」：未登録<br>　　　　　　　　　　　　　　　　　　　  「担当日時」：未登録 (※変わる) |
|  | 実績：血液循環積算値 | rst_blood_circulate_total | numeric | 6,2 |  |  |  |
|  | 実績：透析運転時間 | rst_running_time | smallint |  |  |  |  |
|  | 実績：Kt/V | rst_kt_v | numeric | 4,2 |  |  |  |
|  | 実績：透析記録確認日時 | rec_set_date | timestamp(3) |  |  |  | YYYYMMDDHH24MISS形式 |
|  | 実績：送信管理番号 | send_ctl_no | bigint |  |  |  |  |
|  | 実績：血液浄化装置名称 | blood_purifier_name | character varying | 40 |  |  |  |
|  | 実績：プログラム補液引き残し量 | pull_leave_amount | numeric | 3,2 |  |  |  |
|  | 実績：治療条件情報 | rst_cond_info | jsonb |  |  |  | ■Json構造<br>　指示：治療条件情報と同じ |
|  | 実績：投与薬剤情報 | rst_medi_info | jsonb |  |  |  | ■Json構造<br>　指示：投与薬剤情報に以下を追加<br>  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -<br>  "effect_flg": 投与実施フラグ, ※0：未実施、1：実施済み<br>  "effect_date": 投与実施日時, ※ISO8601形式：【TDC修正】<br>  "effect_user_id": 投与実施者コード,<br>  "effect_user_last_name": 投与実施者名_姓,<br>  "effect_user_first_name": 投与実施者名_名 |
|  | 実績：医療材料情報 | rst_equip_info | jsonb |  |  |  | ■Json構造<br>　指示：医療材料情報と同じ |
|  | 実績：指示コメント情報 | rst_ind_comment_info | jsonb |  |  |  | ■Json構造<br>　指示：指示コメント情報と同じ |
|  | 実績：風袋補正 | rst_tare_info | jsonb |  |  |  | ■Json構造<br>　　前体重測定時、　後体重測定時のデータを保持<br><br>【ESM追記】<br>　　前体重測定時の風袋 : before<br>    後体重測定時の風袋 : after<br>{<br>  before: {<br>    "name_1": (String)"項目1名称", "weight_1": (Number)項目1重さ,<br>    "name_2": (String)"項目2名称", "weight_2": (Number)項目2重さ,<br>    "name_3": (String)"項目3名称", "weight_3": (Number)項目3重さ,<br>    "name_4": (String)"項目4名称", "weight_4": (Number)項目4重さ,<br>    "name_5": (String)"項目5名称", "weight_5": (Number)項目5重さ,<br>    "wheel_chair_cd" : (Number)"車いすマスタ.車いすコード",<br>    "wheel_chair_name": (String)"車いすマスタ.車いす名称",<br>    "wheel_chair_weight": (Number)"車いすマスタ.車いす重量"<br>  },<br>  after: { (beforeと構造同じ) }<br>}<br><br>※重量はグラム単位<br>※車いすを使用しない場合、車いすコード、名称、重量がすべてnull<br>※マスタ未登録の車いすを使用した場合、車いすコードがnull |
|  | 実績：除水補正 | rst_off_water_info | jsonb |  |  |  | ■Json構造<br>　指示：除水補正と同じ |
|  | 実績：装置設定情報 | rst_device_set_info | jsonb |  |  |  | ■Json構造<br>　指示：装置設定情報と同じ |
|  | 実績：体重測定記録番号 | weight_scale_no | bigint |  |  |  | 体重計測定記録.測定管理番号<br>●　体重計＋未登録車いすでの片方未測定の状態で、残りを測定する際に取得する情報元<br>　　　前体重・後体重が確定した時点でnullとなる |
|  | 実績：体重情報 | rst_weight_info | jsonb |  |  |  | ※治療記録画面の持ち方によって検討が必要<br>■Json構造<br>{<br>  "weight_measure_before": (Number)透析前体重測定値（風袋・車いすを含む重量）<br>  "weight_before": (Number)透析前体重,<br>  "weight_before_date": (String)前体重測定日時, (*1)<br>  "weight_measure_after": (Number)透析後体重測定値（風袋・車いすを含む重量）<br>  "weight_after": (Number)透析後体重,<br>  "weight_after_date": (String)後体重測定日時, (*1)<br>  "ctr": (Number)CTR,<br>  "ctr_measure_date": (String)CTR測定日時, (*1)<br>  "ctr_weight": (Number)CTR測定時体重,<br>  "water_removal_target": (Number)目標除水量,<br>  "water_removal_rst": (Number)実績除水量,<br>  "add_total": (Number)除水積算値,<br>  "add_water_total": (Number)補液積算値,<br>  "kt_v_measure": (Number)Kt/V測定値,<br>  "urr": (Number)URR,<br>  "weight_decreased": (Number)減少量<br>  "sttc_vns_prssr": (Number)静的静脈圧<br>  "iap_rt": (Number)IAP　Rate<br>  "ihdf_pll": (Number)IHDF引き残し量<br>  "recrcl_rt": (Json構造)再循環率測定（＠再循環率　を参照してください）<br>"re_loop_rate_main":(Number)治療記録で選択された再循環率のmni_monitorのシーケンス番号を格納<br><br>"reloop_info":(json)再循環率にコメントが入力された数分mni_monitorのシーケンス番号とコメントを紐づけて格納<br>[{<br>bio_moni_ctl_no: mni_monitorの番号<br>reloop_comment:入力したコメント<br>},…]<br>}<br>■概要<br>(*1) ISO8601形式：【TDC修正】 |
|  | 実績：バイタル情報 | rst_vital_info | jsonb |  |  |  | ※治療記録画面と装置側のデータの持ち方によって検討が必要<br>■Json構造<br>[<br>  {<br>    "bio_moni_ctl_no": (Number)生体モニタリング管理番号, (*1)<br>    "occur_date":  (String)発生日時, (*1)(*2)<br>    "bp_class":  (String)血圧区分, (*1)(*3)<br>    "bp_max":  (Number)最高血圧,<br>    "bp_min":  (Number)最低血圧,<br>    "bp_ave":  (Number)平均血圧,<br>    "blood_sugar_level":  (Number)血糖値,<br>    "pulse":  (Number)脈拍,<br>    "temperature":  (Number)体温,<br>    "is_del":  (String)削除フラグ  <br>  }, ・・・<br>]<br>■概要<br>(*1) 必須<br>(*2) ISO8601形式：【TDC修正】<br>(*3) 0: 設定無し、1: 前血圧、2: 後血圧<br>(*5) 血圧測定について(装置記録から取得、または測定時に記録)：【TDC追記】<br>　　　　最大管理番号は保持する必要がある(毎回配列をチェックして最大値+1は非効率)<br>(*6) 前血圧や後血圧が複数あった場合、どの管理番号の測定値をつかうかを設定する必要はないのか？：【TDC追記】 |
|  | 実績：愁訴情報 | rst_complaint_info | jsonb |  |  |  | ※治療記録画面と装置側のデータの持ち方によって検討が必要<br>■Json構造<br>[<br>  {<br>    "checkFlag":帳票出力区分,(*4)<br>    "ctl_no": 管理番号, (*1)<br>    "input_class": 入力区分, (*1)(*2)<br>    "row_no": 行番号, ※必要か？<br>    "occur_date": 発生日時, (*1)(*3)<br>    "comp_cd": 愁訴コード, (*1)<br>    "complaint": 愁訴内容 (*1)<br>  }, ・・・<br>]<br>■概要<br>(*1) 必須<br>(*2) 0: 通信サーバ、1: クライアント、2: 連携<br>(*3) ISO8601形式：【TDC修正】<br>(*4) 帳票出力区分【:帳票出力追加】 |
|  | 実績：愁訴処置情報 | rst_treatment_info | jsonb |  |  |  | ※治療記録画面と装置側のデータの持ち方によって検討が必要<br>■Json構造<br>[<br>  {<br>    "ctl_no": 管理番号,<br>    "row_no": 行番号,<br>    "occur_date": 発生日時,<br>    "treat_class": 処置区分,<br>    "treat_cd": 処置コード,<br>    "treat_name": 処置名,<br>    "medicine_cd": 薬剤コード,<br>    "medicine_name": 薬剤名,<br>    "amount": 数量,<br>    "unit": 単位,<br>    "procedure_cd": 手技コード,<br>    "procedure_name": 手技名,<br>    "treat_medicine_cd": 処置薬剤コード,<br>    "treat_medicine_name": 処置薬剤名,<br>    "oxygen_start": 酸素吸入開始日時,<br>    "oxygen_time": 酸素吸入時間,<br>    "oxygen_amount": 酸素吸入量,<br>    "oxygen_speed": 酸素速度,<br>    "input_class": 入力区分,<br>    "cop_order_no": 連携オーダ番号, (*1)<br>    "is_editable": 編集可能フラグ, (*2)<br>    "electrocardiogram_type": 心電編集種別 (*3),<br>    "checkFlag":帳票出力区分(*5)<br>　　"linkStartDate":酸素吸入関連番号(*6)<br>  }, ・・・<br>]<br>■概要<br>(*1) 電子カルテからの予約オーダを登録する際に使用<br>(*2) 0: 編集不可、1: 編集可能<br>(*3) 処置区分が 4 (心電)の場合、有効(0: 心電開始、1: 心電終了)<br>(*4) ISO8601形式：【TDC追記】<br>(*5) 帳票出力区分【:帳票出力追加】<br>(*6) 酸素吸入終了の場合、対応の酸素吸入開始のctl_noを記入する。 |
|  | 実績：愁訴処置者情報 | rst_treat_staff_info | jsonb |  |  |  | ※治療記録画面と装置側のデータの持ち方によって検討が必要<br>■Json構造<br>[<br>  {<br>    "ctl_no": 管理番号,<br>    "row_no": 行番号,<br>    "input_class": 入力区分,<br>    "occur_date": 発生日時,<br>    "treat_staff_cd": 処置者コード,<br>    "treat_staff_name": 処置者名,<br>    "cop_order_no": 連携オーダ番号, (*1)<br>    "is_editable": 編集可能フラグ (*2),<br>    "checkFlag":帳票出力区分,(*4)<br>  }, ・・・<br>]<br>■概要<br>(*1) 電子カルテからの予約オーダを登録する際に使用<br>(*2) 0: 編集不可、1: 編集可能<br>(*3) ISO8601形式：【TDC追記】<br>(*4) 帳票出力区分【:帳票出力追加】 |
|  | 実績：回診記録情報 | rst_rounds_info | jsonb |  |  |  | ■Json構造<br>{<br>  round_type_cd: number 種別コード,<br>  round_type_name: string 種別名,<br>  reg_date_time: string 起票日時（ISO8601）,<br>  ind_user_id: number 指示者ID,<br>  ind_user_last_name: string 指示者名（姓）,<br>  ind_user_first_name: string 指示者名（名）,<br>  reg_user_id: number 起票者ID,<br>  reg_user_last_name: string 起票者名（姓）,<br>  reg_user_first_name: string 起票者名（名）,<br>  content: string 内容,<br>  is_ind_comment_post: string 指示コメントに転記（'0': 転記しない, '1': 転記する）,<br>  ind_comment_no: number 指示コメント番号,<br>  posting_class: string 転記区分（'0': 継続, '1': 当日のみ）,<br>  created_user_id: number 登録者ID,<br>  created_user_last_name: string 登録者名（姓）,<br>  created_user_first_name: string 登録者名（名）,<br>  created_at: string 登録日時（ISO8601）,<br>  updated_user_id: number 更新者ID,<br>  updated_user_last_name: string 更新者名（姓）,<br>  updated_user_first_name: string 更新者名（名）,<br>  updated_at: string 更新日時（ISO8601）<br>} |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 指示：FNW+同日複数回 | fn_plural | numeric | 1,0 |  |  | FNW+フィードバック用 |
|  | 治療種別 | treat_type | numeric | 1,0 |  |  | 0： 1日,　1： 通常,　2： 隔日,　3： 隔週 |
|  | 実績：確定フラグ | is_confirm | character varying | 1 |  | '0' | 0'：未確定、'1'：確定 |
|  | 指示：DW | ind_dw | numeric | 5,2 |  |  | 条件送信時に身体情報のDWを展開する |
|  | 実績：特殊浄化回数 | rst_purification_cnt | integer |  |  |  |  |
|  | 加算情報 | addition_info | jsonb |  |  |  | @ord_main.addition_infoシートで参考 |
|  | 最終更新指示者ID | up_ind_user_id | bigint |  |  |  |  |
|  | 最終更新者ID | up_user_id | bigint |  |  |  |  |
|  | 初版確定日時 | rst_edition_date | timestamp(3) |  |  |  |  |
|  | 最新版確定日時 | cur_edition_date | timestamp(3) |  |  |  |  |
