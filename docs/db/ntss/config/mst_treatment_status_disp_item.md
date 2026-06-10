# mst_treatment_status_disp_item

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `@mst_treatment_status_disp_item`
- Category: config/reference

## Content

| col1 | col2 | col3 | col4 | col5 | col6 | col7 | col8 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| ◇準備回収モニタ[FNW:7.2(0005)]での表示項目一覧と治療状況リスト/マップでの表示項目一覧 |  |  |  |  |  |  |  |
|  | FNW |  | 次期FN |  |  |  |  |
|  | 項目コード | 項目名 | 編集有無 | 次世代FN参照先テーブル名 | 参照先項目名 | JSONキー値 | 備考 |
|  | 0 | 確認 |  | ord_main | rst_dialysis_state |  | 値が「5:実績未確定」の場合のみ押下可能 |
|  | 10 | 透析開始 |  | ord_main | rst_start_date |  |  |
|  | 44 | 除水目標 |  | ord_main | rst_weight_info | water_removal_target |  |
|  | 11 | 終了予測 |  |  |  |  | 治療中のみ表示？<br>「ord_main.rst_start_date」：開始日時<br> +「mni_monitor.monitor_data.1：経過時間<br> +「mni_monitor.monitor_data.4」：残り時間 |
|  | 14 | 残り時間 |  | mni_monitor | monitor_data | 4：残り時間 | 「ord_no」が一致する一番最後の「data_type」=1のもの |
|  | 12 | 透析終了 |  | ord_main | rst_end_date |  |  |
|  | 35 | 後体重 |  | ord_main | rst_weight_info | weight_after |  |
|  | 42 | 後血圧 |  | ？ |  |  | ※後血圧の参照先が「ord_main」か「mni_monitor」か未確定 |
|  | 48 | 後体重確認 |  | ？ |  |  | ※何を表示しているか不明 |
|  | 2 | ベッド番号 | ※２ | ord_main | ind_bed_cd<br>/rst_bed_name |  | 条件送信前の場合は「ind_bed_cd」で<br>「mst_bed」を検索、「bed_name」を取得 |
|  | 3 | 患者ID | ※２ | ord_main | pat_id |  | 「pat_id」で「pat_personal_main」を検索、<br>「hosp_pat_id」を取得 |
|  | 5 | 状態 |  | ？ |  |  | ※何を表示しているか不明 |
|  | 6 | DW |  | ord_main | rst_dw |  | 条件送信前は「pat_id」で「pat_unique」を検索、「physical_info」の「dw」を取得？ |
|  | 7 | DWから |  | ？ |  |  | ※何を表示しているか不明 |
|  | 8 | 目標体重 |  | ord_main | rst_weight_info | water_removal_target | 条件送信前は「ind_cond_info」の「3」：目標体重を取得？ |
|  | 9 | 目標体重から |  | ？ |  |  | ※何を表示しているか不明 |
|  | 13 | 透析時間 |  | ord_main | ind_cond_info | 1：治療時間 | 「ord_no」が一致する一番最後の「data_type」=1のもの |
|  | 15 | 遅れ時間 |  | ？ |  |  | ※何を表示しているか不明 |
|  | 16 | 前体重 |  | ord_main | rst_weight_info | weight_before |  |
|  | 17 | 前血圧(最高) |  | ？ |  |  | ※前血圧の参照先が「ord_main」か「mni_monitor」か未確定 |
|  | 18 | 前血圧(最低) |  | ？ |  |  | ※前血圧の参照先が「ord_main」か「mni_monitor」か未確定 |
|  | 19 | 前血圧(平均) |  | ？ |  |  | ※前血圧の参照先が「ord_main」か「mni_monitor」か未確定 |
|  | 20 | 前血圧 |  | ？ |  |  | ※前血圧の参照先が「ord_main」か「mni_monitor」か未確定 |
|  | 21 | 前脈拍 |  | ？ |  |  | ※前血圧の参照先が「ord_main」か「mni_monitor」か未確定 |
|  | 22 | 現在血圧 |  | mni_monitor | monitor_data |  | 「ord_no」が一致する一番最後の「data_type」=2のもの |
|  | 23 | 担当者1 | リスト | ord_main | rst_charge_user_info | user_id_1 |  |
|  | 24 | 担当日時1 | ※１ | ord_main | rst_charge_user_info | date_1 |  |
|  | 25 | 担当者2 | リスト | ord_main | rst_charge_user_info | user_id_2 |  |
|  | 26 | 担当日時2 | ※１ | ord_main | rst_charge_user_info | date_2 |  |
|  | 27 | 穿刺者1 | リスト | ord_main | rst_puncture_user_info | user_id_1 |  |
|  | 28 | 穿刺日時1 | ※１ | ord_main | rst_puncture_user_info | date_1 |  |
|  | 29 | 穿刺者2 | リスト | ord_main | rst_puncture_user_info | user_id_2 |  |
|  | 30 | 穿刺日時2 | ※１ | ord_main | rst_puncture_user_info | date_2 |  |
|  | 31 | 返血者1 | リスト | ord_main | rst_return_user_info | user_id_1 |  |
|  | 32 | 返血日時1 | ※１ | ord_main | rst_return_user_info | date_1 |  |
|  | 33 | 返血者2 | リスト | ord_main | rst_return_user_info | user_id_2 |  |
|  | 34 | 返血日時2 | ※１ | ord_main | rst_return_user_info | date_2 |  |
|  | 36 | 前体重-後体重 |  | ord_main | rst_weight_info | weight_before<br>weight_after | 「weight_before」-「weight_after」 |
|  | 37 | 予想引き残し |  | ？ |  |  | ※何を表示しているか不明 |
|  | 38 | 引き残し |  | ord_main |  |  | 「rst_weight_info.weight_after」-「ind_cond_info.3」：目標体重 |
|  | 39 | 後血圧(最高) |  | ？ |  |  | ※後血圧の参照先が「ord_main」か「mni_monitor」か未確定 |
|  | 40 | 後血圧(最低) |  | ？ |  |  | ※後血圧の参照先が「ord_main」か「mni_monitor」か未確定 |
|  | 41 | 後血圧(平均) |  | ？ |  |  | ※後血圧の参照先が「ord_main」か「mni_monitor」か未確定 |
|  | 43 | 後脈拍 |  | ？ |  |  | ※後血圧の参照先が「ord_main」か「mni_monitor」か未確定 |
|  | 45 | 除水速度 |  | mni_monitor | monitor_data | 6：除水速度 | 「ord_no」が一致する一番最後の「data_type」=1のもの |
|  | 46 | 除水量現在値 |  | mni_monitor | monitor_data | 5：除水積算値 | 「ord_no」が一致する一番最後の「data_type」=1のもの |
|  | 47 | 達成率 |  | ？ |  |  | ※何を表示しているか不明 |
|  | 49 | 前体重測定時刻 |  | ord_main | rst_weight_info | weight_before_date |  |
|  | 50 | 終了予定 |  | ？ |  |  | ※何を表示しているか不明 |
|  | 51 | 前回後体重 |  | ord_main | rst_weight_info | weight_after | ※今回の治療の直近前の「ord_main」から取得<br>条件：「pat_id」が同じ、「rst_ialysis_state」>=5、<br>「treat_date」+「ind_treat_start_time」がより過去未満のもの |
|  | 52 | 増加量 |  | ？ |  |  | ※何を表示しているか不明 |
|  | 53 | 増加率 |  | ？ |  |  | ※何を表示しているか不明 |
|  | 54 | 血流量 |  | mni_monitor | monitor_data | 8：血流量 | 「ord_no」が一致する一番最後の「data_type」=1のもの |
|  | 55 | IP速度 |  | mni_monitor | monitor_data | 10：IP速度 | 「ord_no」が一致する一番最後の「data_type」=1のもの |
