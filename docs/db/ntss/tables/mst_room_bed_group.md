# mst_room_bed_group

- Source workbook: `NTSSデータベース設計書.xlsm`
- Source sheet: `mst_room_bed_group`
- Logical name: ベッドグループ・透析室マスタ
- Physical name: `mst_room_bed_group`
- Prefix group: `master`
- User: `nkk5`
- Tablespace DB: `ntss_db5`
- Tablespace INDEX: `ntss_index5`
- Primary key definition: `room_bed_group_cd`
- Column count: 13
- NOT NULL columns: 1

## Columns

| PK order | Logical name | Physical name | Type | Length | NOT NULL | Default | Remarks |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 透析室・ベッドグループコード | room_bed_group_cd | serial |  | 1 |  |  |
|  | 施設コード | facility_cd | character varying | 6 |  |  | 施設マスタ.施設コード |
|  | 透析室・ベッドグループ名 | room_bed_group_name | character varying |  |  |  |  |
|  | ベッド一覧 | bed_list | jsonb |  |  |  | ここではベッドの表示順は管理しない<br>ベッドマスタの表示順を参照する |
|  | FNW+で管理する施設内の一意な透析室・ベッドグループ番号 | fn_room_bed_group_no | character varying | 3 |  |  | FNW+フィードバック用<br>FNW+で管理する施設内の一意なコード |
|  | グループ区分 | group_class | smallint |  |  |  | 1：ベッドグループ、2：透析室、3：その他<br><br>■概要<br>・1～3内でのベッドの重複可<br>・ベッドグループ間で同一のベッドが重複している場合にそのベッドのベッドグループの出力(帳票画面など)は、表示順で一番上のものを採用する<br>・透析室間も同様<br>・その他はベッドグループとしては出力しない<br>　(検索用としてのみ使用)<br>・fn_room_bed_group_noが空白の場合のみ変更を許容する。 |
|  | 院内コード1 | in_hospital_cd_1 | character varying | 20 |  |  |  |
|  | 院内コード2 | in_hospital_cd_2 | character varying | 20 |  |  |  |
|  | 院内コード3 | in_hospital_cd_3 | character varying | 20 |  |  |  |
|  | 表示フラグ | is_disp | character varying | 1 |  | '1' | '0'：非表示、'1'：表示 |
|  | 削除フラグ | is_del | character varying | 1 |  | '0' | '0':通常、'1':削除 |
|  | 登録日時 | reg_date | timestamp(3) |  |  |  |  |
|  | 更新日時 | up_date | timestamp(3) |  |  |  |  |
