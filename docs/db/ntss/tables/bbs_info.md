# bbs_info

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `bbs_info`
- Logical name: 掲示板登録情報
- Physical name: `bbs_info`
- Prefix group: `bbs`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `bbs_ctl_no`
- Column count: 32
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 掲示板管理番号 | bbs_ctl_no | bigserial |  | 1 |  |  |
|  | FNW+で管理する施設内の一意なシーケンスID | fn_seq_id | bigint |  |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | 施設コード | facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード |
|  | 対象患者 | pat_info | jsonb |  |  |  | {<br>  target: (String)対象（'0':個別、'1':全指定、'2':なし）,<br>  detail: [<br>    (Number)pat_id※患者ID（全指定の場合は空配列（[]）を登録）,・・・<br>  ]<br>} |
|  | 対象スタッフ | staff_info | jsonb |  |  |  | {<br>  target: [<br>    (Number)対象スタッフコード（全指定の場合は空配列（[]）を登録, ... <br>  ],<br>  read: [<br>    (Number)既読スタッフコード, ... <br>  ]<br>} |
|  | 機能コード | func_cd | character varying | 3 |  |  | 「機能コード一覧」シート参照 |
|  | 種別番号 | kind_no | bigint |  |  |  | 各機能の種別マスタの管理番号<br>掲示板種別マスタ,管理番号,<br>観察記録種別情報,管理番号, |
|  | 内容 | content | character varying |  |  |  |  |
|  | ファイル情報 | file_info | jsonb |  |  |  | [<br>　{<br>　　name： (String)ファイル名称,<br>　　path：(String)ファイルパス　<br>　}・・・<br>] |
|  | 掲載開始日時 | notice_start_date | character varying | 8 |  |  |  |
|  | 掲載終了日時 | notice_end_date | character varying | 8 |  |  |  |
|  | 起票者ID | reg_staff_id | bigint |  |  |  | mst_user,user_id |
|  | 起票者名 | reg_staff_name | character varying |  |  |  | 姓+名 |
|  | 最終更新者ID | upd_staff_id | bigint |  |  |  | mst_user,user_id |
|  | 最終更新者名 | upd_staff_name | character varying |  |  |  | 姓+名 |
|  | 遷移先機能パス | transition_router_path | character varying |  |  |  | routerのpush情報 |
|  | 登録元機能 | reg_func_class | smallint |  |  |  | 0: 掲示板 1: 患者イベント(観察記録) |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
|  | イベントタイトル | title | character varying |  |  |  |  |
|  | 施設カレンダーイベント開始日時 | notice_fac_cal_start_date | character varying | 8 |  |  |  |
|  | 施設カレンダーイベント終了日時 | notice_fac_cal_end_date | character varying | 8 |  |  |  |
|  | 掲示板表示フラグ | is_disp_bbs | character varying | 1 |  | 0 |  |
|  | 施設カレンダーイベント背景色 | color | character varying |  |  |  |  |
|  | 様式付きの内容 | html_content | varchar |  |  |  |  |
|  | 施設カレンダーイベント開始時刻 | notice_fac_cal_start_time | character varying | 4 |  |  |  |
|  | 施設カレンダーイベント終了時刻 | notice_fac_cal_end_time | character varying | 4 |  |  |  |
|  | 施設カレンダーイベント開始時刻入力フラグ | is_time_start_flg | character varying | 1 |  |  |  |
|  | 施設カレンダーイベント終了時刻入力フラグ | is_time_end_flg | character varying | 1 |  |  |  |
|  | 施設カレンダーイベント文字色 | font_color | character varying |  |  |  |  |
|  | 削除フラグ | is_del | character varying | 1 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  |  |  |
