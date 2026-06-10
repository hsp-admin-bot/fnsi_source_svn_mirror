# mnt_motion_record

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mnt_motion_record`
- Logical name: 装置動作記録
- Physical name: `mnt_motion_record`
- Prefix group: `maintenance-state`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `motion_record_no`
- Column count: 31
- NOT NULL columns: 3

## Related Config / Notes

- [../config/mnt_motion_record.md](../config/mnt_motion_record.md)
- [../config/mnt_motion_record_2.md](../config/mnt_motion_record_2.md)

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 装置動作記録番号 | motion_record_no | bigserial |  | 1 |  | シーケンス使用 |
|  | イベント発生日時 | event_reg_date | timestamp(3) |  |  |  |  |
|  | 緊急発報ステータス | m_notice_status | numeric | 1,0 |  |  | -1：異常<br>0：メール送信待ち<br>1：メール送信済み<br>2：メール送信対象なし<br>9：スキップ |
|  | 施設コード | facility_cd | character varying | 6 |  |  | 装置マスタ.施設コード |
|  | デバイスエッジ番号 | device_edge_no | numeric | 2,0 |  |  | デバイスエッジマスタ.デバイスエッジ番号 |
|  | 型式コード | machine_type_cd | character varying | 3 |  |  | 装置マスタ.型式コード |
|  | 製造番号 | machine_serial | character varying | 8 |  |  | 装置マスタ.製造番号<br>★比較時はTrim後に比較すること |
|  | 通信フォーマット | com_format_cd | character varying | 1 |  |  | 装置マスタ.通信フォーマット |
|  | データ種別 | data_type | numeric | 1,0 | 1 |  | 1：装置記録<br>2：緊急発報記録<br>3：予防保全/故障予知記録<br>4：自己診断結果<br>5：溶解記録<br>6：データ収集記録 |
|  | 自己診断種別 | test_type | numeric | 1,0 |  |  | 1：配管（UFRC）自己診断<br>2：漏血自己診断<br>3：透析液流量自己診断<br>4：濃度自己診断<br>5：配管テスト<br>6：希釈テスト<br>7：自己診断結果(通信共通V4) |
|  | データ収集管理番号 | gathering_manage_no | bigint |  |  |  | データ収集実行元のデータ収集管理.データ収集管理番号を登録する |
|  | メール送信日時 | email_send_date | timestamp(3) |  |  |  |  |
|  | メール本文 | email_text | character varying | 4000 |  |  |  |
|  | 装置記録コード | machine_record_cd | character varying | 4 |  |  | 装置記録：装置記録マスタ.装置記録コード<br>緊急発報記録：緊急発報マスタ.装置記録コード<br>予防保全/故障予知記録：予防保全マスタ.装置記録コードor【AI仕様検討時】<br>自己診断結果：NULL<br>溶解記録：NULL<br>データ収集記録：NULL |
|  | 装置記録メッセージ | machine_record_message | character varying | 256 |  |  | 装置記録：装置記録マスタ.装置記録メッセージ<br>緊急発報記録：緊急発報マスタ.装置記録メッセージ<br>予防保全/故障予知記録：予防保全マスタ.装置記録メッセージor【AI仕様検討時】<br>自己診断結果：下記参照<br>　自己診断種別が「1」：配管（UFRC）自己診断<br>　自己診断種別が「2」：漏血自己診断結果<br>　自己診断種別が「3」：透析液流量自己診断結果<br>　自己診断種別が「4」：濃度自己診断結果<br>　自己診断種別が「5」：配管テスト結果<br>　自己診断種別が「6」：希釈テスト結果<br>溶解記録：溶解記録<br>データ収集記録：下記参照<br>　【依頼失敗】装置データファイル収集<br>　※デバイスエッジとの通信不良時<br><br>　【成功】装置データファイル収集<br>　【対象ファイルなし】装置データファイル収集<br>　【取得失敗】装置データファイル収集<br>　【圧縮失敗】装置データファイル収集<br>　【FTP接続失敗】装置データファイル収集<br>　【転送失敗】装置データファイル収集<br>　※データ収集管理.データ収集情報(装置エラーコード(x0～x5))と紐付け |
|  | 内容 | contents | jsonb |  |  |  | 「@mnt_motion_record」「@@mnt_motion_record」シート参照<br><br>装置記録：NULL<br>緊急発報記録：NULL<br>予防保全/故障予知記録：NULLor【AI時根拠】<br>自己診断結果：自己診断結果データ<br>溶解記録：溶解記録データ<br>データ収集記録：ファイル名と保存場所のアドレスなど、ダウンロードに必要な情報<br> {<br>  "filename":"ファイル名",<br>  "path":"S3の格納先"<br> }<br>999(自己診断情報)：<br>[{<br>    key          Number  自己診断結果アドレス<br>    judge        String    判定('0'：判定しない、'1'：判定する)<br>    failure_low  Number  不合格下限<br>    caution_low  Number  注意点下限<br>    caution_up   Number  注意点上限<br>    failure_up   Number  不合格上限<br>},<br>{}..] |
|  | 装置記録補助データ | machine_record_aux_data | character varying | 256 |  |  | 補助データ1～4を区切り文字を使用して格納<br>※データ種別が「1」～「3」の場合に登録 |
|  | メールアドレス | email_address | character varying | 4000 |  |  | 緊急発報マスタ.メールアドレス |
|  | 宛先名称 | email_name | character varying | 4000 |  |  | 緊急発報マスタ.宛先名称 |
|  | 備考 | remarks | character varying | 4000 |  |  |  |
|  | 対処 | is_correction | character varying | 1 |  |  | '0'：未対処、'1'：対処済み、'2'：対応中 |
|  | 対処者 | user_id | bigint |  |  |  | 利用者マスタ.利用者ID<br>※対処者とデータ収集実行者の共用 |
|  | 対処日時 | is_correction_up_date | timestamp(3) |  |  |  | 対処を更新した日時 |
|  | サービス対応種別 | service_support_type | character varying | 1 | '0' |  | '0'：未受付<br>'1'：1次対応済み<br>'2'：サービス対応済み<br>'3'：サービス対象外 |
|  | サービス対応者 | service_support_user_id | bigint |  |  |  | 利用者マスタ.利用者ID |
|  | サービス対応日時 | service_support_up_date | timestamp(3) |  |  |  | サービス対応種別を更新した日時 |
|  | システムで管理する一意なオーダ番号 | ord_no | bigint |  |  |  | 透析情報.オーダ番号 |
|  | 装置記録区分 | log_type | smallint |  |  |  | 0：不明、1：警報、2：報知、3：操作、4：その他 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | レポート表示フラグ | report_disp_flg | character varying | 1 |  |  | '0'：レポートで非表示、'1'：レポートで表示 |
