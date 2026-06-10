# mnt_machine_state

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mnt_machine_state`
- Logical name: 装置状態管理
- Physical name: `mnt_machine_state`
- Prefix group: `maintenance-state`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `facility_cd,machine_type_cd,machine_serial`
- Column count: 36
- NOT NULL columns: 3

## Related Config / Notes

- [../config/tmp_device_set_info.md](../config/tmp_device_set_info.md)
- [../config/mnt_machine_state_20181208.md](../config/mnt_machine_state_20181208.md)
- [../config/mnt_machine_state.md](../config/mnt_machine_state.md)
- [../config/mnt_machine_state_2.md](../config/mnt_machine_state_2.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 施設コード | facility_cd | character varying | 6 | 1 |  | 施設マスタ.施設コード |
| 1 | 型式コード | machine_type_cd | character varying | 3 | 1 |  | 型式マスタ.型式コード |
| 1 | 製造番号 | machine_serial | character varying | 8 | 1 |  | 装置マスタ.製造番号<br>★比較時はTrim後に比較すること |
|  | 機種 | model | character varying | 3 |  |  | 型式マスタ.機種 |
|  | 装置名 | machine_name | character varying | 40 |  |  | 装置マスタ.装置名 |
|  | ベッドコード | bed_cd | bigint |  |  |  | ベッドマスタ.ベッドコード |
|  | ベッド名 | bed_name | character varying |  |  |  | ベッドマスタ.ベッド名 |
|  | 工程状態 | process_state | character varying | 2 |  |  | ■新通信<br>01：プリセット、02：洗浄、03：酸洗、04：消毒、05：滞留、06：液置換、07：準備回収、08：ガスパージ、09：排液、10：停止、11：運転<br>■DAB<br>20：プリセット、21：透析、22：予備透析、23：液置換、24：薬液消毒、25：滞留消毒、26：熱水消毒、27：酸洗浄、28：洗浄、29：排液<br>■DAD<br>40：プリセット、41：給水、42：循環、43：移送待機、44：移送、45：排液、46：洗浄、47：消毒<br>■DRO<br>60：通常運転、61：夜間運転、62：熱水消毒運転、63：薬液消毒運転、64：強制冷却待機中、65：強制洗出し待機中<br>■共通<br>99：通信異常、電源OFF、異常 |
|  | 緊急発報件数 | m_notice_cnt | integer |  |  | 0 | 対象装置の全レコード（装置動作記録.対処有無）が「未対処」または「対応中」の件数 |
|  | 予防保守件数 | preventive_mainte_cnt | integer |  |  | 0 | 対象装置の全レコード（装置動作記録.対処有無）が「未対処」の件数 |
|  | 通信不良有無 | is_preventive_mainte | integer |  |  | 0 | 0：なし、1：あり<br>※工程状態が「99」の場合「あり」となる |
|  | 部品運転時間 | use_time | jsonb |  |  |  | 「@@mnt_machine_state」シート参照<br>最新値のみを登録する |
|  | 装置ステータス | machine_status | numeric | 3,0 |  |  | ■FNW+情報<br>0～255で、内容はビットごとに以下の意味を持つ。（クライアントでもモニタ表示に使用する。<br>Bit0:透析治療中<br>Bit1:洗消中<br>Bit2:準備中<br>Bit3:警報発生中<br>Bit4:警報処理後（警報の確認）<br>Bit5:報知発生中<br>Bit6:報知処理後（報知の確認）<br>Bit7:ログデータ有無 (クライアント未使用)<br><br>警報の場合、以下の表示となる。<br>警報発生(装置ブザー)→ Bit3 オン、Bit4 オフ<br>警報発生(装置ブザー解除)→ Bit3 オフ、Bit4 オン<br>警報解除(対処完了)→ Bit3 オフ、Bit4 オフ |
|  | 警報監視状態 | alarm_moni | character varying |  |  |  | ■FNW+情報<br>モニタ項目ごとの警報監視状態<br>0:監視しない<br>1:固定監視<br>2:自動監視（ホスト報知を行う）<br>装置で設定変更時に通信サーバにより書き込まれる |
|  | オフラインフラグ | is_offline | character varying | 1 |  | '0' | '0':オンライン、'1':オフライン |
|  | システムで管理する一意なオーダ番号 | ord_no | bigint |  |  |  | 透析情報.オーダ番号 |
|  | 次回透析オーダ番号 | next_ord_no | bigint |  |  |  | 透析情報.オーダ番号 |
|  | システムで管理する一意な患者ID | pat_id | bigint |  |  |  | 患者基本情報.システムで管理する一意な患者ID |
|  | 次患者ID | next_patid | bigint |  |  |  | ■FNW+情報<br>透析装置の排液操作で次患者の患者IDに変わる。<br>患者IDはクライアントで後体重測定→確認の操作が行われるまでそのまま。次患者読み込み通知と連動する。 |
|  | 次患者クールCD | next_kur_cd | bigint |  |  |  | ■FNW+情報<br>次患者のクールをＤＢアプリで設定する。 |
|  | 透析開始予定日時 | start_plan_date | timestamp(3) |  |  |  |  |
|  | 透析終了予定日時 | end_plan_date | timestamp(3) |  |  |  |  |
|  | 前体重測定日時 | weigh_before_date | timestamp(3) |  |  |  |  |
|  | 装置設定一時データ | tmp_device_set_info | jsonb |  |  |  | ■JSON構造<br>「@tmp_device_set_info」シート参照 |
|  | 条件送信日時 | cond_send_date | timestamp(3) |  |  |  | ■FNW+情報<br>条件送信が成功した日時 |
|  | 条件確認日時 | cond_set_date | timestamp(3) |  |  |  | ■FNW+情報<br>条件送信後に透析装置の「確認」操作でセット。確認を解除した場合にはNULLをセット。 |
|  | 患者確認済みフラグ | is_pat_verified | character varying | 1 |  | '0' | 0':未確認、'1':確認済み |
|  | 透析開始日時 | start_date | timestamp(3) |  |  |  |  |
|  | 透析終了日時 | end_date | timestamp(3) |  |  |  |  |
|  | 後体重測定日時 | weigh_after_date | timestamp(3) |  |  |  |  |
|  | 警報、注意発生中リスト | alarm_list | jsonb |  |  |  | 発生中の一覧のみが格納される<br>{<br>"モニタ項目番号"："発生状態"<br>,..<br>}<br>※設定値<br>モニタ項目番号[数字]：1～150<br>発生状態[数値2桁HEX]：<br> 0x01：注意下限、0x02：注意上限、<br> 0x04：警報下限、0x08：警報上限<br> 0x10：変化率注意下限、<br> 0x20：変化率注意上限、<br> 0x40：変化率警報下限、<br> 0x80：変化率警報上限<br> ※上記の組み合わせでそれぞれの桁で大きい順で優先表示 |
|  | 警報、注意発生中リスト | alarm_list | jsonb |  |  |  | 発生中の一覧のみが格納される<br>{<br>  "[項目キー]": 発生状態,<br>  ...<br>}<br><br>ケア報知間隔、血圧測定間隔の場合<br>項目キー <br>  ケア報知間隔 … "care_i"<br>  血圧測定間隔 … "bpmi"<br>発生状態<br>  発生中： 1, 未発生: 0 |
|  | サービス対応件数 | service_support_cnt | integer |  |  | 0 | mnt_motion_record の service_support_type が「'0'：未受付」「'1'：1次対応済み」件数を設定<br>設定はトリガ[tg_sync_mnt_motion_record]で行う |
|  | モニタデータ | monitor_data | jsonb |  |  |  | 「@mni_monitor」シート参照 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
