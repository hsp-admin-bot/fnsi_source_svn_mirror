# mst_treatment_status_disp_item

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_treatment_status_disp_item`
- Logical name: 治療状況レイアウト表示項目マスタ
- Physical name: `mst_treatment_status_disp_item`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `item_cd`
- Column count: 48
- NOT NULL columns: 4

## Related Config / Notes

- [../config/mst_treatment_status_disp_item.md](../config/mst_treatment_status_disp_item.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | レイアウト表示項目番号 | item_cd | integer |  | 1 |  |  |
|  | データ取得種別 | data_class | character varying | 1 | 1 | '0' | 0':参照先が本テーブル内容で完結するもの、<br>'1':状態によって取得先が変わるなど完結できないもの |
|  | 装置種別 | machine_class | character varying | 1 | 1 | '0' | 0':透析装置、'1':DAB、'2':DAD、'3':DRO |
|  | 項目名 | item_name | character varying |  | 1 |  |  |
|  | 参照先テーブル名 | table_name | character varying |  |  |  |  |
|  | 参照先フィールド名 | field_name | character varying |  |  |  |  |
|  | 参照先JSONキー名 | json_key_name | character varying |  |  |  |  |
|  | 表示順 | disp_order | integer |  |  | 0 | 表示順 |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | 0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | 単位 | unit | character varying |  |  |  |  |
| DWから | 当日の患者さんの前体重から患者のDWを減算した値。 |  |  |  |  |  |  |
| 目標体重から | 当日の患者さんの前体重から当日の目標体重を減算した値。 |  |  |  |  |  |  |
| 透析開始 | 透析前：対象クールマスタの標準開始時刻 |  |  |  |  |  |  |
|  | 透析中：透析装置運転開始時刻 |  |  |  |  |  |  |
| 終了予測 | 「ord_main.rst_start_date」：開始日時 +「mni_monitor.monitor_data.3」：除水完了予定時刻 |  |  |  |  |  |  |
|  | 「ord_main.rst_start_date」：開始日時 +「mni_monitor.monitor_data.4」：透析終了予定時刻 |  |  |  |  |  |  |
|  | 上記２時刻の遅いほうの時刻を表示しています。 |  |  |  |  |  |  |
|  | しかしながらお客からは「結局どちら時刻かわからない」とのお話がありましたので、個別に表示できるようにもしてほしいです。 |  |  |  |  |  |  |
| 遅れ時間 | 経過時間(モニタデータ)+終了予測 - 透析時間(透析条件)。 |  |  |  |  |  |  |
| 前体重-後体重 | (ord_main.rst_weight_infoのJSON -> weight_before) - (ord_main.rst_weight_infoのJSON -> weight_after) |  |  |  |  |  |  |
| 予想引き残し | (前体重－除水目標)－目標体重＋除水補正値合計。 |  |  |  |  |  |  |
|  | 除水目標値は条件送信時の値ではなく、モニタ値の除水目標。 |  |  |  |  |  |  |
| 引き残し | (ord_main.rst_weight_infoのJSON -> weight_after) - (ord_main.ind_cond_infoのJSON -> 3:目標体重) |  |  |  |  |  |  |
| 達成率 | 予定されている総除水量に対する除水量現在地の割合。 |  |  |  |  |  |  |
| 後体重確認 | ここはカラムのデータを表示していないです。 |  |  |  |  |  |  |
|  | 透析終了後、後体重を計測した患者さんの時に「確認」ボタンを可視化させ、このボタンをクリックした患者を透析完了として準備回収モニタから消しておりました。 |  |  |  |  |  |  |
|  | （このタイミングでFNWでは実績を確定させる第1版としておりました） |  |  |  |  |  |  |
|  | また、？？？患者の場合に、後から同じベッドに患者が（？？？含む）モニタに来たら「削除」ボタンとして可視化し、押すことでこのレコードが削除される仕組みになっています。 |  |  |  |  |  |  |
| 終了予定 | 透析前：対象クールマスタ標準開始時刻＋透析時間。透析中：透析送信運転開始時刻＋透析時間 |  |  |  |  |  |  |
|  | または透析前：透析開始予定時刻＋透析時間（透析開始予定時刻入力可の場合） |  |  |  |  |  |  |
| 増加量 | 前回後体重から今回前体重の増加分（前体重-前回後体重）。 |  |  |  |  |  |  |
| 増加率 | １）前回後体重から算出（((前体重 - 前回後体重) / 前回後体重) * 100）。 |  |  |  |  |  |  |
|  | ２）DWから算出（((前体重 - DW) / DW) * 100）。 |  |  |  |  |  |  |
|  | 上記の選択はシステム設定にて切り替え。初期値は１） |  |  |  |  |  |  |
| 前血圧(最高) | ord_main.rst_vital_info.bp_max | BP_CLASS=1でoccur_dateが最新のもの |  |  |  |  |  |
| 前血圧(最低) | ord_main.rst_vital_info.bp_min | BP_CLASS=1でoccur_dateが最新のもの |  |  |  |  |  |
| 前血圧(平均) | ord_main.rst_vital_info.bp_ave | BP_CLASS=1でoccur_dateが最新のもの |  |  |  |  |  |
| 前血圧 | ord_main.rst_vital_info.bp_max | BP_CLASS=1でoccur_dateが最新のもの |  |  |  |  |  |
| 前脈拍 | ord_main.rst_vital_info.pulse | BP_CLASS=1でoccur_dateが最新のもの |  |  |  |  |  |
| 後血圧(最高) | ord_main.rst_vital_info.bp_max | BP_CLASS=2でoccur_dateが最新のもの |  |  |  |  |  |
| 後血圧(最低) | ord_main.rst_vital_info.bp_min | BP_CLASS=2でoccur_dateが最新のもの |  |  |  |  |  |
| 後血圧(平均) | ord_main.rst_vital_info.bp_ave | BP_CLASS=2でoccur_dateが最新のもの |  |  |  |  |  |
| 後血圧 | ord_main.rst_vital_info.bp_max | BP_CLASS=2でoccur_dateが最新のもの |  |  |  |  |  |
| 後脈拍 | ord_main.rst_vital_info.pulse | BP_CLASS=2でoccur_dateが最新のもの |  |  |  |  |  |
| 前回後体重 | 該当の患者の直近の実績から後体重を取得する。 |  |  |  |  |  |  |
